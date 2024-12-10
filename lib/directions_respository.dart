import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapa_flutter/.env.dart';
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
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key':
              googleApiKey, // Asegúrate de usar la variable correcta para la API Key
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
      print('Error fetching directions: $e');
      return null;
    }
  }
}
