import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:http/http.dart';

class Place {
  String alias;
  String streetNumber;
  String street;
  String sublocality;
  String city;
  String zipCode;
  LatLng location;
  String instructions;

  Place(
      {this.alias,
      this.streetNumber,
      this.street,
      this.sublocality,
      this.city,
      this.zipCode,
      this.location,
      this.instructions});

  @override
  String toString() {
    return 'Place(alias: $alias, street: $street, streetNumber: $streetNumber, sublocality:$sublocality, city: $city, zipCode: $zipCode, locatoin: $location, instructions: $instructions)';
  }

  static Place fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return Place(
        alias: json['alias'],
        street: json['street'],
        streetNumber: 'json',
        sublocality: json['sublocality'],
        city: json['city'],
        zipCode: json['zipCode'],
        instructions: json['instructions'],
        location: json['location'] is GeoPoint
            ? LatLng(json['location'].latitude, json['location'].longitude)
            : LatLng(
                json['location']['latitude'], json['location']['longitude']));
  }

  Map<String, dynamic> toJson() {
    return {
      "alias": this.alias,
      "street": this.street,
      "streetNumber": this.streetNumber,
      "sublocality": this.sublocality,
      "city": this.city,
      "zipCode": this.zipCode,
      "location": {
        "latitude": this.location.latitude,
        "longitude": this.location.longitude
      },
      "instructions": this.instructions
    };
  }
}

class Suggestion {
  final String placeId;
  final String address;
  final String description;

  Suggestion(this.placeId, this.address, this.description);

  @override
  String toString() {
    return 'Suggestion(address: $address, description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  final client = Client();
  final apiKey = 'AIzaSyDg31xCBpunPWmCeFkEHx8EQ2LzPR0uHyA';

  String sessionToken;
  String location = '';

  PlaceApiProvider({String sessionToken = 'empty'}) {
    sessionToken = sessionToken;
  }

  Future<List<Suggestion>> fetchSuggestions(String input) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=es-419&components=country:mx&key=$apiKey&sessiontoken=$sessionToken&location=$CITY_LATITUDE,$CITY_LONGITUDE&radius=18000';
    final response = await client.get(request);
    print(request);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions'].map<Suggestion>((p) {
          int idx = p['description'].indexOf(',');
          return Suggestion(
              p['place_id'],
              p['description'].substring(0, idx).trim(),
              p['description'].substring(idx + 1).trim());
        }).toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getAddressFromLatLng(LatLng location) async {
    final request =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&language=es-419&key=$apiKey';
    final response = await client.get(request);
    print(request);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        if (result['results'].length > 0) {
          return fromJson(result['results'][0]['address_components'],
              result['results'][0]['geometry']['location']);
        }
        return null;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId) async {
    final request =
        'https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&language=es-419&key=$apiKey';
    final response = await client.get(request);
    print(request);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return fromJson(result['results'][0]['address_components'],
            result['results'][0]['geometry']['location']);
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Place fromJson(List<dynamic> components, Map<String, dynamic> location) {
    // final components = json as List<dynamic>;
    // build result
    final place = Place();
    components.forEach((c) {
      final List type = c['types'];
      if (type.contains('street_number')) {
        place.streetNumber = c['long_name'];
      }
      if (type.contains('route')) {
        place.street = c['long_name'];
      }
      if (type.contains('sublocality')) {
        place.sublocality = c['long_name'];
      }
      if (type.contains('locality')) {
        place.city = c['long_name'];
      }
      if (type.contains('postal_code')) {
        place.zipCode = c['long_name'];
      }
    });
    place.street = "${place.street} ${place.streetNumber}";
    place.location = LatLng(location['lat'], location['lng']);
    return place;
  }
}
