import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jaipi/src/components/components.dart';
import 'package:jaipi/src/config/config.dart';
import 'package:jaipi/src/controllers/controllers.dart';
import 'package:jaipi/src/helpers/helpers.dart';
import 'package:jaipi/src/views/views.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

class DepartmentView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'department';

  final String department;

  DepartmentView({Key key, this.department}) : super(key: key);

  @override
  _DepartmentViewState createState() => _DepartmentViewState(department);
}

class _DepartmentViewState extends StateMVC<DepartmentView> {
  DepartmentController _con;

  _DepartmentViewState(String department)
      : super(DepartmentController(department)) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
          isLoading: _con.isLoading,
          child: _con.department == null
              ? Container()
              : SafeArea(
                  child: _con.department['name'] == 'Lo que quieras'
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Container(
                                padding: EdgeInsets.only(top: spacing_large),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CachedNetworkImage(
                                        imageUrl: _con.department['icon'],
                                        width: 100,
                                        height: 90),
                                    text(_con.department['name'],
                                        fontWeight: fontBold,
                                        fontSize: textSizeLarge),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(17.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    text(
                                        "Si cabe en nuestra maleta, te lo llevamos.",
                                        fontSize: textSizeLargeMedium,
                                        maxLine: null,
                                        isCentered: true),
                                    SizedBox(height: spacing_large),
                                    socialButton(
                                        whatsappColor,
                                        food_ic_whatsapp,
                                        "Solicitar servicio",
                                        whiteColor,
                                        whiteColor, () {
                                      Uri waUrl = Uri(
                                          scheme: "https",
                                          host: "wa.me",
                                          path: "52$WHATSAPPPHONE",
                                          queryParameters: {
                                            "text": "Hola Jaipi"
                                          });
                                      launch(waUrl.toString());
                                    },
                                        height: 60.0,
                                        iconSize: 32.0,
                                        fontSize: textSizeLargeMedium)
                                  ],
                                ),
                              ),
                            ])
                      : SingleChildScrollView(
                          child: Column(children: [
                          Container(
                            padding: EdgeInsets.only(top: spacing_large),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CachedNetworkImage(
                                    imageUrl: _con.department['icon'],
                                    width: 100,
                                    height: 90),
                                text(_con.department['name'],
                                    fontWeight: fontBold,
                                    fontSize: textSizeLarge),
                                SearchInputWidget(
                                  hintText:
                                      "Buscar ${_con.department['name'].toLowerCase()}",
                                ),
                              ],
                            ),
                          ),
                          mHeading("Categorías"),
                          SizedBox(
                            height: spacing_standard_new,
                          ),
                          Container(
                              width: double.infinity,
                              height: 80,
                              child: _con.categories != null &&
                                      _con.categories.length > 0
                                  ? ListView(
                                      padding: EdgeInsets.only(
                                          right: spacing_standard_new),
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      children: _con.categories
                                          .map((DocumentSnapshot doc) {
                                        return GestureDetector(
                                          onTap: () {
                                            launchScreen(
                                                context, CategoryView.routeName,
                                                arguments: doc['name']);
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              left: spacing_standard_new,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: doc['image'] != null
                                                      ? CachedNetworkImage(
                                                          imageUrl: doc['image']
                                                              ['url'],
                                                          height: 45,
                                                          width: 45,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.asset(
                                                          'assets/images/placeholder.png',
                                                          width: 45,
                                                          height: 45,
                                                        ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: spacing_standard),
                                                  child: Text(
                                                    doc['name'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  : Center(
                                      child: text("Aún no hay categorías",
                                          textColor: blackColor))),
                          SizedBox(
                            height: spacing_large,
                          ),
                          mHeading("Negocios"),
                          SizedBox(
                            height: spacing_large,
                          ),
                          _con.businesses != null && _con.businesses.length > 0
                              ? ListView.builder(
                                  primary: false,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: _con.businesses.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return BusinessItem(business: {
                                      ..._con.businesses[index].data(),
                                      "id": _con.businesses[index].id,
                                    });
                                  })
                              : Center(
                                  child: text("Espéralos muy pronto",
                                      textColor: blackColor),
                                )
                        ])),
                )),
    );
  }
}

class DeliveryForm {
  String where;
  String what;

  DeliveryForm({this.where, this.what});
}
