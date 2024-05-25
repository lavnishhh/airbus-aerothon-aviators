import 'package:jeodezi/jeodezi.dart';
import 'package:latlong2/latlong.dart';

class AirportData {
  static final AirportData _instance = AirportData._internal();

  factory AirportData() {
    return _instance;
  }


  AirportData._internal();

  final List<Airport> airports = [];

  void setData(List<List<dynamic>> data){
    for(List<dynamic> raw in data){
      List<String> airport = raw.map((e) => e.toString()).toList();
      airports.add(Airport(airport[0], airport[1], airport[3], Coordinate(double.parse(airport[4]), double.parse(airport[5]))));
    }
    airports.sort((a, b) => a.name.compareTo(b.name));
  }

}

class Airport{
  final String code;
  final String name;
  final String country;
  final Coordinate location;
  Airport(this.code, this.name, this.country, this.location);

  LatLng toLatLng(){
    return LatLng(location.latitude, location.longitude);
  }

}