import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gps_receiver/project_widget.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final LatLng _initialCenter = const LatLng(0, 0);
  List<LatLng> _path = [];
  LatLng _startPoint = const LatLng(0, 0);
  bool _isProjectOpen = false;

  @override
  void initState() {
    super.initState();
    _parseLocationData();
  }

  void _parseLocationData() {
    String locationData = '''
    {"start_point":[
       34.052235,
        -118.243683
    ],
    "path": [
       [
        34.052235,
        -118.243683
      ],
      [
        34.052245,
        -118.243693
      ],
      [
        34.052255,
        -118.243703
      ],
      [
        34.052265,
        -118.243713
      ],
      [
        34.052275,
        -118.243723
      ],
      [
        34.052285,
        -118.243733
      ],
      [
        34.052295,
        -118.243743
      ],
      [
        34.052305,
        -118.243753
      ],
      [
        34.052315,
        -118.243763
      ],
      [
        34.052325,
        -118.243773
      ]
    ]}
    ''';

    Map<String, dynamic> data = jsonDecode(locationData);
    _startPoint = LatLng(data['start_point'][0], data['start_point'][1]);
    _path = List<LatLng>.from(data['path']
        .map((coordinates) => LatLng(coordinates[0], coordinates[1])));
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

  void _handleProjectWidgetClose() {
    setState(() {
      _isProjectOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (_) {},
            initialCameraPosition: CameraPosition(
              target: _startPoint,
              zoom: 10.0,
            ),
            markers: _path.isNotEmpty
                ? <Marker>{
                    Marker(
                      markerId: const MarkerId('start_point'),
                      position: _startPoint,
                    ),
                  }
                : <Marker>{},
            polylines: _path.isNotEmpty
                ? <Polyline>{
                    Polyline(
                      polylineId: const PolylineId('path'),
                      points: _path,
                      color: Colors.red,
                      width: 5,
                    ),
                  }
                : <Polyline>{},
          ),
          if (_isProjectOpen)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleProjectContainer,
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: MediaQuery.of(context).size.height * 0.05,
            right: _isProjectOpen
                ? MediaQuery.of(context).size.width * 0.05
                : -400,
            child: AnimatedOpacity(
              opacity: _isProjectOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: ProjectWidget(
                onSetupComplete: _handleProjectSetupComplete,
                onClose: _handleProjectWidgetClose, // Pass the onClose callback
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleProjectContainer,
              child: Icon(
                _isProjectOpen ? Icons.close : Icons.settings,
                size: 30,
                color: _isProjectOpen ? Colors.red : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
