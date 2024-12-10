import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationTrackingPage extends StatefulWidget {
  const LocationTrackingPage({super.key});

  @override
  _LocationTrackingPageState createState() => _LocationTrackingPageState();
}

class _LocationTrackingPageState extends State<LocationTrackingPage> {
  Stream<Position>? _positionStream;
  String _currentLocation = "Waiting for location...";
  GoogleMapController? _mapController;
  LatLng _currentLatLng = const LatLng(0.0, 0.0);
  Set<Marker> _markers = {}; // Marker set to update

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStream = null;
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    try {
      // Check location service availability
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateLocationStatus("Location services are disabled.");
        return;
      }

      // Request location permissions
      LocationPermission permission = await _checkLocationPermission();
      if (permission == LocationPermission.denied) return;

      // Start location tracking every 5 seconds
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // adjust based on requirement
        ),
      );

      _positionStream!.listen((Position position) {
        _updateLocationOnMap(position);
      });

      // Using Timer to update location every 5 seconds
      Timer.periodic(const Duration(seconds: 5), (timer) async {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        _updateLocationOnMap(position);
      });
    } catch (e) {
      _updateLocationStatus("Error tracking location: ${e.toString()}");
    }
  }

  Future<LocationPermission> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.deniedForever) {
        _updateLocationStatus(
          "Location permissions are permanently denied. Cannot access location.",
        );
      }
    }

    return permission;
  }

  void _updateLocationStatus(String message) {
    setState(() {
      _currentLocation = message;
    });
  }

  void _updateLocationOnMap(Position position) {
    setState(() {
      _currentLocation = "Latitude: ${position.latitude.toStringAsFixed(4)}, "
          "Longitude: ${position.longitude.toStringAsFixed(4)}";

      _currentLatLng = LatLng(position.latitude, position.longitude);

      // Add or update the marker on the map
      _markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLatLng,
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      };

      // Animate camera to new location
      _mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(_currentLatLng, 16));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Real-time Location Tracking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        elevation: 4,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng,
              zoom: 14,
            ),
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers, // Add the markers to the map
          ),

          // Overlay with location information
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _currentLocation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Stop Tracking Button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Stop Tracking",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
