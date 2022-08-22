import 'package:flutter/material.dart';
import 'package:jaipi/src/config/config.dart';
import 'package:jaipi/src/helpers/helpers.dart';
import 'package:jaipi/src/providers/providers.dart';
import 'package:jaipi/src/views/views.dart';
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
                  leading:
                      Icon(Icons.account_circle_outlined, color: Colors.yellow),
                  onTap: () {
                    launchScreen(context, Profile.routeName);
                  },
                )
              : ListTile(
                  title: Text("Tu perfil"),
                  leading:
                      Icon(Icons.account_circle_outlined, color: Colors.yellow),
                  onTap: () {
                    launchScreen(context, LoginView.routeName);
                  },
                )),
          ListTile(
            title: Text('Soporte'),
            leading: Icon(Icons.construction, color: Colors.yellow),
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
            title: Text("Metodos de pago "),
            leading: Icon(
              Icons.payments,
              color: Colors.yellow,
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text("Direcciones"),
            leading: Icon(
              Icons.place,
              color: Colors.yellow,
            ),
            onTap: () {
              launchScreen(context, AddressesView.routeName);
            },
          ),
          ListTile(
            horizontalTitleGap: 30,
            leading: Image.asset(
              "assets/images/coupon.png",
              height: 32,
              color: Colors.yellow,
            ),
            title: const Text(
              'Cuponera',
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {},
          ),
          ListTile(
            horizontalTitleGap: 30,
            leading: const Icon(
              Icons.directions_bike,
              color: Colors.yellow,
            ),
            title: const Text(
              'Quiero ser Jaipi Driver ',
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {},
          ),
          ListTile(
            horizontalTitleGap: 30,
            leading: const Icon(
              Icons.add_business,
              color: Colors.yellow,
            ),
            title: const Text(
              'Quiero ser  Aliado Jaipi ',
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {},
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
