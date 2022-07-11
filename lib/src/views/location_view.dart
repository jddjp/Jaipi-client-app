import 'package:flutter/material.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/providers/location_provider.dart';
import 'package:jaipi/src/views/home_view.dart';
import 'package:provider/provider.dart';

class LocationView extends StatefulWidget {
  static const routeName = 'location';

  @override
  _LocationViewState createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(child: Container()),
                Icon(Icons.location_on, size: 100.0, color: Colors.grey[300]),
                SizedBox(
                  height: 40,
                ),
                text('Para comenzar necesitamos tu ubicación',
                    fontSize: textSizeNormal,
                    isLongText: true,
                    isCentered: true),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: text(
                      'Tu ubicación nos permite saber que tiendas y servicios están disponibles para ti.',
                      textColor: textSecondaryColor,
                      maxLine: null,
                      isCentered: true),
                ),
                Expanded(child: Container()),
                Center(
                  child: RaisedButton(
                    shape: StadiumBorder(),
                    color: appColorAccent,
                    textColor: appColorPrimary,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      child: Text('PERMITIR UBICACIÓN',
                          style: TextStyle(fontSize: 15.0)),
                    ),
                    onPressed: () {
                      Provider.of<LocationProvider>(context, listen: false)
                          .getLastPosition()
                          .then((value) {
                        launchScreen(context, HomeView.routeName);
                      });
                    },
                  ),
                ),
                SizedBox(height: spacing_standard_new),
                GestureDetector(
                  onTap: () {
                    Provider.of<LocationProvider>(context, listen: false)
                        .setDefaultPosition()
                        .then((value) {
                      launchScreen(context, HomeView.routeName);
                    });
                  },
                  child: Text(
                    "No permitir",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                Expanded(child: Container())
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
