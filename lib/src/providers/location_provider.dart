import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/services/google_places_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  SharedPreferences _prefs;
  LocationPermission _permission = LocationPermission.denied;
  bool _permissionChecked = false;
  Position _position;
  // Used for not location permission
  Position _defaultPosition =
      Position(latitude: CITY_LATITUDE, longitude: CITY_LONGITUDE);

  // Placemark get address => _address;
  // Place
  Place _place;

  // Get location
  LatLng location() {
    return LatLng(_position.latitude, _position.longitude);
  }

  bool isPermissionChecked() => _permissionChecked;

  bool hasPermission() =>
      _permission == LocationPermission.always ||
      _permission == LocationPermission.whileInUse;

  LocationProvider() {
    initialize();
  }

  void initialize() async {
    _prefs = await SharedPreferences.getInstance();

    /* if (_prefs.getString('userLocation') != null) {
      final userLocation = jsonDecode(_prefs.getString('userLocation'));
      setPosition(Position(
          latitude: userLocation['latitude'],
          longitude: userLocation['longitude']));
    } */

    _position = await _determinePosition();

    if (_prefs.getString('userPlace') != null) {
      final userPlace = jsonDecode(_prefs.getString('userPlace'));
      setPlace(Place.fromJson(userPlace));
    } else {
      setPlace(null);
    }
  }

  Future<Place> getLastPosition() async {
    try {
      _position = await _determinePosition();
      Place place = await PlaceApiProvider().getAddressFromLatLng(
          LatLng(_position.latitude, _position.longitude));
      await setPlace(place);
      return Future.value(place);
    } catch (e) {
      print(e);
    }
    notifyListeners();
    return Future.value();
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    _prefs = await SharedPreferences.getInstance();

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return _defaultPosition;
    }

    _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.deniedForever) {
      print(
          'Location permissions are permantly denied, we cannot request permissions.');
      return _defaultPosition;
    }

    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
      if (_permission != LocationPermission.whileInUse &&
          _permission != LocationPermission.always) {
        print('Location permissions are denied (actual value: $_permission).');
        return _defaultPosition;
      }
    }

    notifyListeners();

    return await Geolocator.getCurrentPosition();
  }

  /*
   * Used when user not allow location
   */
  Future<Position> setDefaultPosition() async {
    await setPlace(null);

    return Future.value();
  }

  /*
   * Set and save user position
   */
  /* Future<void> setPosition(Position position) async {
    if (position != null) {
      _position = position;
    } else {
      _position = _defaultPosition;
    }

    List<Placemark> placemarks =
        await placemarkFromCoordinates(_position.latitude, _position.longitude);
    // _address = placemarks[0];
    _prefs.setString('userLocation', jsonEncode(_position));
    notifyListeners();

    return Future.value();
  } */

  Future<void> setPlace(Place place) async {
    if (place != null) {
      _place = place;
    } else {
      _place = Place(
          street: "Sin dirección",
          sublocality: "Unknown",
          city: "Unknow",
          location: LatLng(CITY_LATITUDE, CITY_LONGITUDE));
    }

    // _currentStreet = _place.street;
    _prefs.setString('userPlace', jsonEncode(_place.toJson()));
    notifyListeners();

    return Future.value();
  }

  Future<LatLng> getLocation() async {
    // Determine user position
    if (_position == null) {
      _position = await _determinePosition();
    }

    if (_position != null) {
      return Future.value(LatLng(_position.latitude, _position.longitude));
    }

    return Future.value(LatLng(CITY_LATITUDE, CITY_LONGITUDE));
  }

  Place getAddress() {
    return _place;
  }

  String shortAddress() {
    if (_place != null) {
      return "${_place.street}, ${_place.sublocality}";
    }

    return "Cargando dirección...";
  }

  Future<Place> saveNewAddress(
      {@required Place place,
      @required LatLng location,
      String userStreet,
      String instructions,
      String alias}) async {
    // Save only if user is loggedin
    if (_prefs.getString('uid') != null) {
      DocumentReference client = FirebaseFirestore.instance
          .collection('users')
          .doc(_prefs.getString('uid'));

      await client.collection('addresses').add({
        "alias": alias != ""
            ? "${alias[0].toUpperCase()}${alias.substring(1)}"
            : null,
        "street": userStreet,
        "sublocality": place.sublocality,
        "city": place.city,
        "zipCode": place.zipCode,
        "instructions": instructions != "" ? instructions : null,
        "location": GeoPoint(location.latitude, location.longitude),
        "createdAt": FieldValue.serverTimestamp()
      });
    }

    place.street = userStreet;
    place.alias = alias;
    place.location = location;

    await setPlace(place);

    return Future.value(place);
  }

  /*
  * Get all user addresses 
  **/
  Stream<QuerySnapshot> getUserAddresses() {
    print(_prefs.getString('uid'));
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_prefs.getString('uid'))
        .collection('addresses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteAddress(docId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_prefs.getString('uid'))
        .collection('addresses')
        .doc(docId)
        .delete();
  }
}
