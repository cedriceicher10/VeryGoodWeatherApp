import 'package:flutter/material.dart';
import 'package:location/location.dart';

Location location = Location();

class UserLocation {
  double userLat = 0;
  double userLon = 0;

  Future<void> getLocation() async {
    // Adapted from: https://pub.dev/packages/location
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        Icons.assignment_return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    userLat = _locationData.latitude!;
    userLon = _locationData.longitude!;
  }
}
