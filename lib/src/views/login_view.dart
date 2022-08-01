import 'dart:io' show Platform;

import 'package:clippy_flutter/arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaipi/src/components/components.dart';
import 'package:jaipi/src/config/config.dart';
import 'package:jaipi/src/helpers/helpers.dart';
import 'package:jaipi/src/providers/providers.dart';
import 'package:jaipi/src/views/views.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  static const routeName = 'login';

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    changeStatusColor(primaryColor);
    var width = MediaQuery.of(context).size.width;
    Widget socialButton(var color, var icon, var value, var iconColor,
        var valueColor, VoidCallback onPressed) {
      return SizedBox(
        width: double.infinity,
        height: 50.0,
        child: FlatButton.icon(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(color: whiteColor)),
          color: color,
          onPressed: onPressed,
          icon: SvgPicture.asset(icon, color: iconColor, width: 18, height: 18),
          label: Text(
            value,
            style: TextStyle(fontSize: textSizeMedium, color: valueColor),
          ),
        ),
      );
    }

    return Scaffold(
      body: LoadingOverlay(
        isLoading: Provider.of<LoginProvider>(context).isLoading(),
        child: Stack(
          children: <Widget>[
            Container(
              height: width * 0.6,
              width: width,
              padding: EdgeInsets.only(top: 60, bottom: 60),
              color: appColorPrimary,
              child: Center(
                child: Image.asset("assets/images/logo.png"),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: width * 0.5),
              child: Stack(
                children: <Widget>[
                  Arc(
                    arcType: ArcType.CONVEY,
                    edge: Edge.TOP,
                    height: (MediaQuery.of(context).size.width) / 10,
                    child: new Container(
                        height: (MediaQuery.of(context).size.height),
                        width: MediaQuery.of(context).size.width,
                        color: whiteColor),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(spacing_standard_new),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: width * 0.1),
                        text("Ingresar",
                            fontWeight: fontBold, fontSize: textSizeLarge),
                        SizedBox(height: width * 0.12),
                        socialButton(
                            Color(0xFF4285f4),
                            food_ic_google_fill,
                            "Iniciar sesión con Google",
                            whiteColor,
                            whiteColor, () {
                          Provider.of<LoginProvider>(context, listen: false)
                              .login("google")
                              .then((value) {
                            launchScreen(
                                context, CompleteProfileView.routeName);
                          });
                        }),
                        SizedBox(height: width * 0.05),
                        socialButton(
                            facebookColor,
                            food_ic_fb,
                            "Iniciar sesión con Facebook",
                            whiteColor,
                            whiteColor, () {
                          Provider.of<LoginProvider>(context, listen: false)
                              .login("facebook")
                              .then((value) {
                            launchScreen(
                                context, CompleteProfileView.routeName);
                          });
                        }),
                        Platform.isIOS
                            ? SizedBox(height: width * 0.05)
                            : Container(),
                        Platform.isIOS
                            ? socialButton(
                                appleColor,
                                food_ic_apple,
                                "Iniciar sesión con Apple",
                                whiteColor,
                                whiteColor, () {
                                Provider.of<LoginProvider>(context,
                                        listen: false)
                                    .login("apple")
                                    .then((value) {
                                  if (Platform.isIOS) {
                                    Provider.of<LoginProvider>(context,
                                            listen: false)
                                        .checkLoginState()
                                        .then((value) {
                                      // Redirect and remove all screens
                                      Navigator.pushNamedAndRemoveUntil(context,
                                          HomeView.routeName, (route) => false);
                                    });
                                  } else {
                                    launchScreen(
                                        context, CompleteProfileView.routeName);
                                  }
                                });
                              })
                            : Container(),
                        SizedBox(height: width * 0.05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                height: 0.5,
                                color: textPrimaryColor,
                                width: width * 0.07,
                                margin:
                                    EdgeInsets.only(right: spacing_standard)),
                            text(food_lbl_or_use_your_mobile_email,
                                textAllCaps: true, fontSize: textSizeSMedium),
                            Container(
                                height: 0.5,
                                color: textPrimaryColor,
                                width: width * 0.07,
                                margin:
                                    EdgeInsets.only(left: spacing_standard)),
                          ],
                        ),
                        SizedBox(height: width * 0.07),
                        DefaultButton(
                          text: "Usar número de teléfono",
                          press: () {
                            launchScreen(context, CreateAccountView.routeName);
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
