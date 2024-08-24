import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier {
  LatLng _currentLocation = LatLng(0.0, 0.0); // Default location
  Map<String, List<LatLng>> _roverPaths = {};

  LatLng get currentLocation => _currentLocation;

  Map<String, List<LatLng>> get roverPaths => _roverPaths;

  void updateLocation(LatLng newLocation) {
    _currentLocation = newLocation;
    notifyListeners();
  }

  void updateRoverPath(String roverId, List<LatLng> path) {
    _roverPaths[roverId] = path;
    notifyListeners();
  }

  void addPathPoint(String roverId, LatLng point) {
    if (_roverPaths.containsKey(roverId)) {
      _roverPaths[roverId]?.add(point);
    } else {
      _roverPaths[roverId] = [point];
    }
    notifyListeners();
  }
}
