import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;

  const Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  factory Directions.fromMap(Map<String, dynamic> map) {
    if ((map['routes'] as List).isEmpty) ;

    final data = Map<String, dynamic>.from(map['routes'][0]);

    // Obtener los límites (bounds)
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']), // Corregido
    );

    // Obtener distancia y duración
    String distance = '';
    String duration = '';
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'] ?? ''; // Asegurando que no sea nulo
      duration = leg['duration']['text'] ?? ''; // Asegurando que no sea nulo
    }

    // Obtener puntos de la polilínea
    List<PointLatLng> polylinePoints = [];
    if (data['overview_polyline'] != null) {
      polylinePoints =
          PolylinePoints().decodePolyline(data['overview_polyline']['points']);
    }

    return Directions(
      bounds: bounds,
      polylinePoints: polylinePoints,
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}
