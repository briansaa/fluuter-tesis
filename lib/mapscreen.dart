import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'directions_respository.dart';
import 'directions_model.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(-12.046374, -77.042793), // Lima
    zoom: 6.0,
  );

  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;

  @override
  void initState() {
    super.initState();
    _setInitialMarkers();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  void _setInitialMarkers() async {
    final limaPosition = LatLng(-12.046374, -77.042793); // Lima
    final cuscoPosition = LatLng(-13.53195, -71.96746); // Cusco

    setState(() {
      _origin = Marker(
        markerId: const MarkerId('origin'),
        infoWindow: const InfoWindow(title: 'Lima'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: limaPosition,
      );
      _destination = Marker(
        markerId: const MarkerId('destination'),
        infoWindow: const InfoWindow(title: 'Cusco'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: cuscoPosition,
      );
    });

    // Obtener direcciones entre Lima y Cusco
    final directions = await DirectionsRepository().getDirections(
      origin: limaPosition,
      destination: cuscoPosition,
    );
    setState(() => _info = directions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Google Maps'),
        actions: [
          if (_origin != null)
            _buildCameraButton(_origin!.position, 'Lima', Colors.green),
          if (_destination != null)
            _buildCameraButton(_destination!.position, 'Cusco', Colors.red),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination!,
            },
            polylines: _info != null
                ? {
                    Polyline(
                      polylineId: const PolylineId('overview_polyline'),
                      color: Colors.red,
                      width: 5,
                      points: _info!.polylinePoints
                          .map((e) => LatLng(e.latitude, e.longitude))
                          .toList(),
                    ),
                  }
                : {},
          ),
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0),
                  ],
                ),
                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () {
          if (_info != null) {
            _googleMapController.animateCamera(
              CameraUpdate.newLatLngBounds(_info!.bounds, 100.0),
            );
          } else {
            _googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(_initialCameraPosition),
            );
          }
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  Widget _buildCameraButton(LatLng position, String label, Color color) {
    return TextButton(
      onPressed: () => _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 14.5, tilt: 50.0),
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: color,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
