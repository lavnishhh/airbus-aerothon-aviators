import 'dart:math';
import 'dart:core';

import 'package:flutter_map/flutter_map.dart';
import 'package:jeodezi/jeodezi.dart';
import 'package:jeodezi/src/coordinates.dart';
import 'package:latlong2/latlong.dart';

class MathHelper{
  final greatCircle = GreatCircle();
  List<Coordinate> calculateGeodesicPolyline(Coordinate origin, Coordinate destination, int n) {
    double bearing = greatCircle.bearing(origin, destination);
    double distance = greatCircle.distance(origin, destination);
    List<Coordinate> polyline = [];
    for(int part = 0; part <= n; part++){
      polyline.add(greatCircle.destination(startPoint: origin, bearing: bearing, distance: distance * part / n));
    }
    return polyline;
  }

  LatLng getPlanePosition(Coordinate origin, Coordinate destination, double fraction){
    double bearing = greatCircle.bearing(origin, destination);
    double distance = greatCircle.distance(origin, destination) * fraction;
    Coordinate planePosition = greatCircle.destination(startPoint: origin, bearing: bearing, distance: distance);
    return LatLng(planePosition.latitude, planePosition.longitude);
  }

  List<LatLng> calculatePlaneBounds(Coordinate origin, Coordinate destination, double fraction, double size){
    LatLng planePosition = getPlanePosition(origin, destination, fraction);

    //update bearing based on current plane location
    double bearing = greatCircle.bearing(Coordinate(planePosition.latitude, planePosition.longitude), destination);

    //trig variables
    double radRotation = (bearing - 90) * pi / 180;
    double cosr = cos(radRotation);
    double sinr = sin(radRotation);

    LatLng topLeft = rotate(LatLng(size, -size), planePosition, radRotation, cosr, sinr);
    LatLng topRight = rotate(LatLng(size, size), planePosition, radRotation, cosr, sinr);
    LatLng bottomLeft = rotate(LatLng(-size, size), planePosition, radRotation, cosr, sinr);
    LatLng bottomRight = rotate(LatLng(-size, -size), planePosition, radRotation, cosr, sinr);

    return [topLeft, topRight, bottomLeft, bottomRight];
  }

  LatLng rotate(LatLng point, LatLng center, double radRotation, double cosr, double sinr) {
    final dx = point.longitude * cosr - point.latitude * sinr;
    final dy = point.longitude * sinr + point.latitude * cosr;
    return LatLng(center.latitude + dx, center.longitude + dy);
  }
}

//
// class Polar {
//   final double radius;
//   final double latitude;
//   final double longitude;
//
//   Polar(this.radius, this.latitude, this.longitude);
//
//   Cartesian toCartesian() {
//     double latRad = latitude * (pi / 180);
//     double lonRad = longitude * (pi / 180);
//     double x = radius * cos(latRad) * cos(lonRad);
//     double y = radius * cos(latRad) * sin(lonRad);
//     double z = radius * sin(latRad);
//     return Cartesian(x, y, z);
//   }
// }
//
// class Cartesian {
//   final double x;
//   final double y;
//   final double z;
//
//   Cartesian(this.x, this.y, this.z);
//
//   Polar toPolar() {
//     double radius = sqrt(x * x + y * y + z * z);
//     double latitude = atan2(z, sqrt(x * x + y * y)) * (180 / pi);
//     double longitude = atan2(y, x) * (180 / pi);
//     return Polar(radius, latitude, longitude);
//   }
// }