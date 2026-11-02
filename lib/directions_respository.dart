import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapa_flutter/config.dart';
import 'package:mapa_flutter/directions_model.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    if (googleApiKey.isEmpty) {
      debugPrint('Falta GOOGLE_MAPS_API_KEY: usa --dart-define=GOOGLE_MAPS_API_KEY=...');
      return null;
    }
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': googleApiKey,
        },
      );

      if (response.statusCode == 200) {
        return Directions.fromMap(response
            .data); // Asegúrate de que la respuesta tenga los datos correctos
      } else {
        // Aquí podrías manejar el error si el código de estado no es 200
        throw Exception('Failed to load directions');
      }
    } catch (e) {
      debugPrint('Error al obtener la ruta: $e');
      return null;
    }
  }
}
