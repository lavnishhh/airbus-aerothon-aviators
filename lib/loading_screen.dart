import 'dart:convert';
import 'dart:io';

import 'package:airbus_aerothon_aviators/airport_data.dart';
import 'package:airbus_aerothon_aviators/map_screen.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    initialize().then((value) => {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>const MapScreen()))
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<bool> initialize() async {
    final raw = await rootBundle.loadString('assets/airport_volume_airport_locations.csv');
    List<List<dynamic>> fields = const CsvToListConverter().convert(raw);
    AirportData().setData(fields);
    return true;
  }
  
}
