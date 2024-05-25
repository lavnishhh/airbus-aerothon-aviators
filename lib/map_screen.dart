import 'package:airbus_aerothon_aviators/airport_data.dart';
import 'package:airbus_aerothon_aviators/math.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jeodezi/jeodezi.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  List<LatLng> lineCoordinates = [];
  Airport selectedOrigin = AirportData().airports.firstWhere((element) => element.code == 'DEL');
  Airport selectedDestination = AirportData().airports.firstWhere((element) => element.code == 'BLR');
  MapController mapController = MapController();
  double sliderValue = 0.5;

  double size = 1;

  @override
  void initState() {
    super.initState();
  }

  void setCamera(){
    // mapController.fitCamera(CameraFit.bounds(bounds: LatLngBounds(selectedOrigin.toLatLng(), selectedDestination.toLatLng()), padding: const EdgeInsets.all(300)));
    mapController.fitCamera(CameraFit.coordinates(coordinates: [selectedOrigin.toLatLng(), selectedDestination.toLatLng()], padding: const EdgeInsets.fromLTRB(400, 100, 100, 100)));
  }

  @override
  Widget build(BuildContext context) {

    lineCoordinates = MathHelper().calculateGeodesicPolyline(selectedOrigin.location, selectedDestination.location, 50).map((e) => LatLng(e.latitude, e.longitude)).toList();

    List<LatLng> planeBounds = MathHelper().calculatePlaneBounds(selectedOrigin.location, selectedDestination.location, sliderValue, size);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialZoom: 3,
              onMapReady: (){
                setCamera();
              },
              onMapEvent: (MapEvent mapEvent){
                if(mapEvent.toString().contains('Zoom')){
                  setState(() {
                    size = 3 / mapController.camera.zoom;
                  });
                }
              }
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: lineCoordinates,
                    color: Colors.blue,
                    strokeWidth: 2
                  ),
                ],
              ),
              OverlayImageLayer(
                overlayImages: [
                  RotatedOverlayImage(
                    topLeftCorner: planeBounds[0],
                    bottomLeftCorner: planeBounds[3],
                    bottomRightCorner: planeBounds[2],
                    imageProvider: const NetworkImage('https://cdn-icons-png.flaticon.com/512/565/565360.png'),
                  ),
                ],
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    // onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                  ),
                ],
              ),
            ],
          ),
          // Expanded(child: Container(color: Colors.grey,)),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              child: SizedBox.expand(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownSearch<String>(
                          items: AirportData().airports.map((e) => "${e.name} (${e.code})").toList(),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Origin",
                              hintText: "country in menu mode",
                            ),
                          ),
                          onChanged: (value){
                            String code = value!.split(" ").last.substring(1,4);
                            setState(() {
                              selectedOrigin = AirportData().airports.firstWhere((element) => element.code == code);
                              setCamera();
                            });
                          },
                          selectedItem: "${selectedOrigin.name} (${selectedOrigin.code})",
                        ),
                        const SizedBox(height: 10,),
                        DropdownSearch<String>(
                          items: AirportData().airports.map((e) => "${e.name} (${e.code})").toList(),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Destination",
                              hintText: "country in menu mode",
                            ),
                          ),
                          onChanged: (value){
                            String code = value!.split(" ").last.substring(1,4);
                            setState(() {
                              selectedDestination = AirportData().airports.firstWhere((element) => element.code == code);
                              setCamera();
                            });
                          },
                          selectedItem: "${selectedDestination.name} (${selectedDestination.code})",
                        ),
                        const SizedBox(height: 10,),
                        const Divider(),
                        const SizedBox(height: 10,),
                        const Text("Flight positon"),
                        Slider(
                            value: sliderValue,
                            divisions: 100,
                            onChanged: (double value){
                              setState(() {
                                sliderValue = value;
                              });
                            }
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
