import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jaipi/src/config/config.dart';
import 'package:jaipi/src/helpers/helpers.dart';
import 'package:jaipi/src/providers/providers.dart';
import 'package:jaipi/src/services/services.dart';
import 'package:provider/provider.dart';

class AddressConfirmationView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'address_condirmation';

  final Place place;

  AddressConfirmationView({Key key, @required this.place}) : super(key: key);

  @override
  AddressConfirmationViewState createState() => AddressConfirmationViewState();
}

class AddressConfirmationViewState extends State<AddressConfirmationView> {
  bool _isLoading = false;
  // User values
  Place _userPlace;
  LatLng _userLocation;
  //
  final streetNameController = TextEditingController();
  final sublocalityController = TextEditingController();
  final instructionsController = TextEditingController();
  final aliasController = TextEditingController();
  //

  @override
  Widget build(BuildContext context) {
    changeStatusColor(Colors.white);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: text("Confirma tu dirección"),
        backgroundColor: whiteColor,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 300,
                  child: MapPage(
                      confirmLocation: widget.place.location,
                      onChange: (LatLng location) async {
                        setState(() {
                          _isLoading = true;
                          _userLocation = location;
                        });
                        PlaceApiProvider()
                            .getAddressFromLatLng(location)
                            .then((userPlace) {
                          setState(() {
                            _isLoading = false;
                            _userPlace = userPlace;
                            streetNameController.text = userPlace.street;
                            sublocalityController.text = userPlace.sublocality;
                          });
                        });
                      }),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/images/pin.png",
                    width: 100,
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                  child: Container(
                margin: EdgeInsets.all(spacing_standard_new),
                child: Column(
                  children: <Widget>[
                    buildStreetFormField(),
                    SizedBox(
                      height: spacing_standard,
                    ),
                    buildSubFormField(),
                    SizedBox(
                      height: spacing_standard,
                    ),
                    buildInstructionsFormField(),
                    SizedBox(
                      height: spacing_standard,
                    ),
                    buildAliasFormField(),
                    SizedBox(
                      height: spacing_large,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 56.0,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        color: appColorAccent,
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          Place newAddress = await Provider.of<
                                  LocationProvider>(context, listen: false)
                              .saveNewAddress(
                                  place: _userPlace,
                                  location: _userLocation,
                                  userStreet: streetNameController.text,
                                  alias: aliasController.text,
                                  instructions: instructionsController.text);
                          await Provider.of<CartProvider>(context,
                                  listen: false)
                              .setAddress(newAddress);

                          setState(() {
                            _isLoading = false;
                          });
                          int count = 0;
                          Navigator.of(context).popUntil((_) => count++ >= 2);
                        },
                        child: _isLoading
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    right: 12, top: 6, bottom: 6),
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      appColorAccent),
                                ),
                              )
                            : Text(
                                "Confirmar",
                                style: TextStyle(
                                  fontSize: textSizeMedium,
                                  color: appColorPrimary,
                                ),
                              ),
                      ),
                    )
                  ],
                ),
              )),
            )
          ],
        ),
      ),
    );
  }

  TextFormField buildStreetFormField() {
    return TextFormField(
      controller: streetNameController,
      validator: (value) {
        if (value.isEmpty) {
          return "Por favor ingresa tu dirección";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Dirección",
        hintText: "Ingresa tu dirección",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildSubFormField() {
    return TextFormField(
      controller: sublocalityController,
      validator: (value) {
        if (value.isEmpty) {
          return "Por favor ingresa tu dirección";
        }
        return null;
      },
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Colonia/Localidad",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildInstructionsFormField() {
    return TextFormField(
      controller: instructionsController,
      decoration: InputDecoration(
        labelText: "Instrucciones",
        hintText: "Agrega instrucciones o casa, piso, apartamento...",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildAliasFormField() {
    return TextFormField(
      controller: aliasController,
      decoration: InputDecoration(
        labelText: "Alias",
        hintText: "Casa, Oficina, Trabajo, etc.",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

Padding editTextStyle(var hintText) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: TextFormField(
      style: TextStyle(fontSize: textSizeMedium, fontWeight: fontRegular),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        hintText: hintText,
        filled: true,
        fillColor: food_white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(color: food_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(color: food_view_color, width: 1.0)),
      ),
    ),
  );
}

class MapPage extends StatefulWidget {
  final void Function(LatLng) onChange;
  final LatLng confirmLocation;

  MapPage({@required this.onChange, @required this.confirmLocation});

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  BitmapDescriptor pinLocationIcon;
  List<Marker> _markers = [];
  String currentAddress = '';
  LatLng userLocation;
  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    userLocation = widget.confirmLocation;
    CameraPosition initialLocation =
        CameraPosition(zoom: 18, bearing: 30, target: userLocation);
    return GoogleMap(
      // myLocationEnabled: false,
      // compassEnabled: true,
      markers: Set.from(_markers),
      // onTap: _handleTap,
      initialCameraPosition: initialLocation,
      onMapCreated: (GoogleMapController controller) {
        //controller.setMapStyle(Utils.mapStyles);
        _controller.complete(controller);
        /* setState(() {
          _markers.add(Marker(
              markerId: MarkerId('value'),
              position: pinPosition /*, icon: pinLocationIcon*/));
        }); */
      },
      onCameraMove: (position) {
        // print(position.target);
        userLocation = position.target;
      },
      onCameraIdle: () async {
        // you can use the captured location here. when the user stops moving the map.
        widget.onChange(userLocation);
      },
    );
  }

  /* _handleTap(LatLng tappedPoint) {
    // Trigger onChange location
    widget.onChange(tappedPoint);

    // Add marker to map
    setState(() {
      _markers = [];
      _markers.add(Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange)));
    });
  } */
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}
