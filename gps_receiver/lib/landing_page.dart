import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gps_receiver/project_setup_dialog.dart';
import 'package:gps_receiver/project_widget.dart';
import 'package:gps_receiver/services.dart'; // Import your services
import 'package:gps_receiver/models/rover_details.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final LatLng _initialCenter = const LatLng(0, 0);
  List<LatLng> _path = [];
  List<LatLng> _completed_path = [];
  LatLng _startPoint = const LatLng(0, 0);
  bool _isProjectOpen = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchMissionData(String roverId, String missionId) async {
    try {
      print('Fetching mission data...');
      if (_mapController == null) {
        print('_mapController is not initialized yet.');
        return; // Exit if _mapController is not ready
      }

      final response =
          await Services.getRequest('rovers/$roverId/missions/$missionId');
      final data = jsonDecode(response.body);
      print(data);
      print('line 39');

      if (data != null) {
        print('Mission data fetched successfully.');
        setState(() {
          _startPoint =
              LatLng(data['starting_point'][0], data['starting_point'][1]);
          _path = List<LatLng>.from(data['path']
              .map((coordinates) => LatLng(coordinates[0], coordinates[1])));

          _completed_path = List<LatLng>.from(data['compleated']
              .map((coordinates) => LatLng(coordinates[0], coordinates[1])));
          print('Print Path : $_completed_path');
        });
        _moveToStartPoint();
      } else {
        print('No data found.');
      }
    } catch (e) {
      print('Error fetching mission data: $e');
    }
  }

  void _moveToStartPoint() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _startPoint,
            zoom: 22.0, // Set default zoom level to 22
          ),
        ),
      );
    } else {
      print('MapController is not initialized.');
    }
  }

  void _toggleProjectContainer() {
    setState(() {
      _isProjectOpen = !_isProjectOpen;
    });
  }

  void _handleProjectSetupComplete(ProjectSetupData setupData) {
    // Logic to handle project setup data
    // Example: Update map markers or perform other operations
  }

  void _onSelectionChanged(RoverDetails roverDetails, bool isSelected) {
    if (isSelected && roverDetails.missionAssigned != 'N/A') {
      _fetchMissionData(roverDetails.roverId, roverDetails.missionAssigned);
    } else {
      setState(() {
        _startPoint = _initialCenter;
        _path = [];
        _completed_path = [];
      });
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _initialCenter,
              zoom: 10.0, // Set default zoom level
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _initialCenter,
                zoom: 10.0, // Set initial zoom level
              ),
              markers: {
                if (_startPoint !=
                    LatLng(0, 0)) // Add marker if start point is set
                  Marker(
                    markerId: MarkerId('start_point'),
                    position: _startPoint,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure), // Set icon for marker
                  ),
              },
              polylines: {
                if (_path.isNotEmpty)
                  Polyline(
                    polylineId: const PolylineId('mission_path'),
                    points: _path,
                    color: Colors.yellow,
                    width: 5,
                  ),
                if (_completed_path.isNotEmpty)
                  Polyline(
                    polylineId: const PolylineId('completed_path'),
                    points: _completed_path,
                    color: Colors.green,
                    width: 8,
                  ),
              }),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: MediaQuery.of(context).size.height * 0.05,
            right: _isProjectOpen
                ? MediaQuery.of(context).size.width * 0.05
                : -MediaQuery.of(context).size.width * 0.55, // Move off-screen
            child: Container(
              width: 500,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ProjectWidget(
                onSetupComplete: _handleProjectSetupComplete,
                onClose: _toggleProjectContainer,
                onSelectionChanged: _onSelectionChanged, // Pass the callback
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            child: GestureDetector(
              onTap: _toggleProjectContainer,
              child: AnimatedRotation(
                turns: _isProjectOpen ? 0.25 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(_isProjectOpen ? Icons.close : Icons.settings,
                    size: 30,
                    color: _isProjectOpen ? Colors.red : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
