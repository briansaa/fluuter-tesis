import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapa_flutter/directions_model.dart';
import 'package:mapa_flutter/loginpage.dart';
import 'package:mapa_flutter/homepage.dart';

void main() {
  group('Directions.fromMap', () {
    test('devuelve null cuando la API no encuentra ruta', () {
      expect(Directions.fromMap({'routes': [], 'status': 'ZERO_RESULTS'}), isNull);
    });

    test('lee límites, distancia, duración y polilínea', () {
      final directions = Directions.fromMap({
        'routes': [
          {
            'bounds': {
              'northeast': {'lat': -12.04, 'lng': -77.02},
              'southwest': {'lat': -12.12, 'lng': -77.05},
            },
            'legs': [
              {
                'distance': {'text': '9.8 km'},
                'duration': {'text': '25 min'},
              }
            ],
            'overview_polyline': {'points': '_p~iF~ps|U_ulLnnqC_mqNvxq`@'},
          }
        ],
      });

      expect(directions, isNotNull);
      expect(directions!.totalDistance, '9.8 km');
      expect(directions.totalDuration, '25 min');
      expect(directions.polylinePoints, hasLength(3));
      expect(directions.bounds.northeast.latitude, -12.04);
    });
  });

  testWidgets('el login vuelve al inicio (antes navegaba a una ruta inexistente)', (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/login',
      routes: {
        '/': (_) => const HomePage(),
        '/login': (_) => const LoginPage(),
      },
    ));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });
}
