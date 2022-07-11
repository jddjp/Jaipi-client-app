import 'package:cached_network_image/cached_network_image.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jaipi/src/components/business_item.dart';
import 'package:jaipi/src/components/offers_item.dart';
import 'package:jaipi/src/components/search_input_widget.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/providers/cart_provider.dart';
import 'package:jaipi/src/providers/location_provider.dart';
import 'package:jaipi/src/services/google_places_service.dart';
import 'package:jaipi/src/views/addresses_view.dart';
import 'package:jaipi/src/views/cart_view.dart';
import 'package:jaipi/src/views/department_view.dart';
import 'package:jaipi/src/views/tracking_view.dart';
import 'package:jaipi/src/views/drawer_view.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'home';

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<QuerySnapshot> _departmentSnapshot;
  Future<QuerySnapshot> _lastBusinessesSnapshot;
  Future<QuerySnapshot> _offersSnapshot;
  Place currentAddress;

  @override
  void initState() {
    // Query all categories
    _departmentSnapshot = FirebaseFirestore.instance
        .collection('departments')
        .where('active', isEqualTo: true)
        .orderBy('index')
        .get();
    _offersSnapshot = FirebaseFirestore.instance
        .collection('offers')
        .where('active', isEqualTo: true)
        .orderBy('index')
        .get();
    _lastBusinessesSnapshot = FirebaseFirestore.instance
        .collection('businesses')
        .where('active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .limit(10)
        .get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Change status bar color
    changeStatusColor(primaryColor);

    currentAddress = context.watch<LocationProvider>().getAddress();
    //print("////////ADDRESSS");
    //print(currentAddress);

    return Scaffold(
      backgroundColor: Color(0xFFFCFBFB),
      drawer: DrawerView(),
      bottomNavigationBar: context.watch<CartProvider>().hasOrderInProgress()
          ? Container(
              height: 80,
              decoration: boxDecoration(radius: 0),
              padding: EdgeInsets.all(spacing_standard_new),
              child: InkWell(
                onTap: () {
                  launchScreen(context, TrackingView.routeName,
                      arguments: context.read<CartProvider>().orderInProgress);
                  //context.read<CartProvider>().clearOrderInProgress();
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: spacing_standard_new),
                  decoration: boxDecoration(bgColor: appColorAccent),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        color: appColorPrimary,
                      ),
                      SizedBox(
                        width: spacing_standard,
                      ),
                      Expanded(
                        child: text("Hay un pedido en progreso",
                            textColor: appColorPrimary),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: appColorPrimary,
                      )
                    ],
                  ),
                ),
              ),
            )
          : Container(height: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(children: [
                Arc(
                  arcType: ArcType.CONVEX,
                  edge: Edge.BOTTOM,
                  height: (MediaQuery.of(context).size.width) / 25,
                  child: new Container(
                      height: (MediaQuery.of(context).size.height * 0.37),
                      width: MediaQuery.of(context).size.width,
                      color: primaryColor),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Builder(builder: (context) {
                        return IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: whiteColor,
                            ),
                            onPressed: () => Scaffold.of(context).openDrawer());
                      }),
                      Expanded(
                          child: GestureDetector(
                              onTap: () {
                                launchScreen(context, AddressesView.routeName);
                              },
                              child: RichText(
                                  text: TextSpan(children: [
                                WidgetSpan(
                                    child: Text(
                                  currentAddress != null
                                      ? "${currentAddress.street}"
                                      : "Cargando...",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white),
                                )),
                                WidgetSpan(
                                    child: Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: Colors.white,
                                ))
                              ])))),
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launchScreen(context, CartView.routeName);
                              // finish(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SearchInputWidget(position: 50.0, bgColor: whiteColor),
                Container(
                    transform: Matrix4.translationValues(0.0, 145.0, 0.0),
                    height: 120,
                    child: FutureBuilder<QuerySnapshot>(
                        future: _departmentSnapshot,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          return ListView(
                            padding: EdgeInsets.only(right: 16),
                            scrollDirection: Axis.horizontal,
                            children:
                                snapshot.data.docs.map((DocumentSnapshot doc) {
                              return GestureDetector(
                                onTap: () {
                                  // View department
                                  launchScreen(
                                      context, DepartmentView.routeName,
                                      arguments: doc.id);
                                },
                                child: Container(
                                  width: 93.0,
                                  margin: EdgeInsets.only(
                                    left: 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 30,
                                        child: CachedNetworkImage(
                                          imageUrl: doc['icon'],
                                          height: 60,
                                          width: 60,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        child: Text(
                                          doc['name'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        })),
              ]),
              Container(
                  padding: EdgeInsets.symmetric(vertical: spacing_standard_new),
                  child: FutureBuilder<QuerySnapshot>(
                      future: _offersSnapshot,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snap) {
                        if (snap.hasError) {
                          return Text('Something went wrong');
                        }
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snap.data.docs.length == 0) {
                          return SizedBox();
                        }
                        return Column(children: [
                          mHeading('Ofertas'),
                          SizedBox(height: spacing_standard_new),
                          CarouselSlider.builder(
                            itemCount: snap.data.docs.length,
                            options: CarouselOptions(
                              aspectRatio: 2.0,
                              enlargeCenterPage: true,
                              autoPlay: true,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return OffersItem(offers: {
                                ...snap.data.docs[index].data(),
                                "id": snap.data.docs[index].id
                              });
                            },
                          ),
                        ]);
                      })),
              Container(
                padding: EdgeInsets.symmetric(vertical: spacing_standard_new),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    mHeading('Últimos negocios'),
                    SizedBox(height: spacing_standard_new),
                    FutureBuilder(
                        future: _lastBusinessesSnapshot,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                              backgroundColor: appColorAccent,
                            ));
                          }

                          return ListView.builder(
                              primary: false,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return BusinessItem(business: {
                                  ...snapshot.data.docs[index].data(),
                                  "id": snapshot.data.docs[index].id
                                });
                              });
                        }),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
