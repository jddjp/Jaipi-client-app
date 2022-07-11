import 'package:flutter/material.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/providers/login_provider.dart';
import 'package:jaipi/src/views/addresses_view.dart';
import 'package:jaipi/src/views/complete_profile_view.dart';
import 'package:jaipi/src/views/login_view.dart';
import 'package:jaipi/src/views/profile_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerView extends StatelessWidget {
  static const routeName = 'drawer';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.symmetric(vertical: 20),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Image.asset('assets/images/logo.png'),
            ),
            decoration: BoxDecoration(color: appColorPrimary),
          ),
          (context.watch<LoginProvider>().isLoggedIn()
              ? ListTile(
                  title: Text(context.watch<LoginProvider>().isCompleted()
                      ? context.watch<LoginProvider>().currentUser['name']
                      : "Completar perfil"),
                  leading: Icon(Icons.account_circle_outlined,
                      color: appColorPrimary),
                  onTap: () {
                    launchScreen(context, Profile.routeName);
                  },
                )
              : ListTile(
                  title: Text("Iniciar sesión"),
                  leading: Icon(Icons.account_circle_outlined,
                      color: appColorPrimary),
                  onTap: () {
                    launchScreen(context, LoginView.routeName);
                  },
                )),
          ListTile(
            title: Text("Direcciones"),
            leading: Icon(
              Icons.place,
              color: appColorPrimary,
            ),
            onTap: () {
              launchScreen(context, AddressesView.routeName);
            },
          ),
          ListTile(
            title: Text('Soporte'),
            leading: Icon(Icons.help_outline, color: appColorPrimary),
            onTap: () {
              Uri waUrl = Uri(
                  scheme: "https",
                  host: "wa.me",
                  path: "52$WHATSAPPPHONE",
                  queryParameters: {
                    "text": "Hola, ¿Estoy contactando con el soporte de jaipi?"
                  });
              launch(waUrl.toString());
            },
          ),
          ListTile(
            title: Text('Acerca de'),
            leading: Icon(Icons.info_outline, color: appColorPrimary),
            //launchScreen(context, AboutPage.routeName),
            onTap: () => Navigator.pushNamed(context, 'about'),
          ),
          (context.watch<LoginProvider>().isLoggedIn()
              ? ListTile(
                  title: Text('Cerrar sesión'),
                  leading: Icon(Icons.subdirectory_arrow_left_rounded,
                      color: appColorPrimary),
                  onTap: () {
                    Provider.of<LoginProvider>(context, listen: false).logout();
                    //launchScreen(context, LoginView.routeName);
                  },
                )
              : Container()),
        ],
      ),
    );
  }
}
