import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class DistanceApiProvider {
  final client = Client();
  final apiKey = 'AIzaSyDg31xCBpunPWmCeFkEHx8EQ2LzPR0uHyA';

  String location = '';

  Future<double> getDistance(LatLng origin, LatLng destination) async {
    final request =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origin.latitude},${origin.longitude}&destinations=${destination.latitude},${destination.longitude}&language=es-419&key=$apiKey';
    final response = await client.get(request);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        if (result['rows'][0] != null) {
          if (result['rows'][0]['elements'] != null) {
            if (result['rows'][0]['elements'][0] != null) {
              if (result['rows'][0]['elements'][0]['status'] == 'OK') {
                print(result['rows'][0]['elements'][0]['distance']['value']);
                return double.parse(result['rows'][0]['elements'][0]['distance']['value'].toString());
              }
            }
          }
        }
        return 0;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
