import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jaipi/src/components/components.dart';
import 'package:jaipi/src/config/config.dart';
import 'package:jaipi/src/helpers/helpers.dart';
import 'package:jaipi/src/providers/providers.dart';
import 'package:jaipi/src/services/services.dart';
import 'package:jaipi/src/views/views.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int _actualPage = 0;

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
    double screenWidth = MediaQuery.of(context).size.width;
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
                        child: text(
                          "Hay un pedido en progreso",
                          textColor: appColorPrimary,
                        ),
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
          : BottomAppBar(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.cyan[50],
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(100),
                ),
                width: double.maxFinite,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                          color: food_color_yellow,
                          icon: Icon(
                            Icons.home,
                            color: food_color_yellow,
                          ),
                          iconSize: 20,
                          onPressed: () {
                            launchScreen(context, HomeView.routeName);
                          }),
                      const Text(
                        'Inicio',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Roboto',
                          fontSize: 8,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Proximamente',
                        icon: Icon(
                          Icons.percent,
                          color: food_color_yellow,
                        ),
                        onPressed: () {},
                      ),
                      const Text(
                        'Ofertas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Roboto',
                          fontSize: 8,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Proximamente',
                        icon: Icon(
                          Icons.star,
                          color: food_color_yellow,
                        ),
                        onPressed: () {},
                      ),
                      const Text(
                        'Favoritos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Roboto',
                          fontSize: 8,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.handyman_outlined,
                          color: food_color_yellow,
                        ),
                        onPressed: () {
                          Uri waUrl = Uri(
                              scheme: "https",
                              host: "wa.me",
                              path: "52$WHATSAPPPHONE",
                              queryParameters: {
                                "text":
                                    "Hola, ¿Quiero unirme a su equipo o ser aliado?"
                              });
                          launch(waUrl.toString());
                        },
                      ),
                      const Text(
                        'Soporte',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Roboto',
                          fontSize: 8,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.person_outline,
                          color: food_color_yellow,
                        ),
                        onPressed: () {
                          launchScreen(context, LoginView.routeName);
                        },
                      ),
                      const Text(
                        'Mi perfil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Roboto',
                          fontSize: 8,
                        ),
                      ),
                    ]),
              ),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(children: [
                Container(
                  height: (MediaQuery.of(context).size.height * 0.37),
                  width: MediaQuery.of(context).size.width,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Builder(
                        builder: (context) {
                          return IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: primaryColor,
                            ),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          );
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            launchScreen(context, AddressesView.routeName);
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                    child: Text(
                                  currentAddress != null
                                      ? "${currentAddress.street}"
                                      : "Cargando...",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )),
                                WidgetSpan(
                                  child: Icon(
                                    Icons.arrow_drop_down_outlined,
                                    color: appColorAccent,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.shopping_cart,
                              color: primaryColor,
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
                // TODO: Cambiar el color de buscar (En espera de respuesta)
                SearchInputWidget(
                  position: 60.0,
                  bgColor: food_color_blue_gradientsearch,
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, 180.0, 0.0),
                  height: 70,
                  child: FutureBuilder<QuerySnapshot>(
                    future: _departmentSnapshot,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            snapshot.data.docs.map((DocumentSnapshot doc) {
                          return GestureDetector(
                            onTap: () {
                              // View department
                              launchScreen(
                                context,
                                DepartmentView.routeName,
                                arguments: doc.id,
                              );
                            },
                            child: Card(
                              color: primaryColor,
                              margin: EdgeInsets.only(left: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(spacing_standard_new),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 30,
                                    child: CachedNetworkImage(
                                      imageUrl: doc['icon'],
                                      height: 40,
                                      width: 40,
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width: 90,
                                    margin: EdgeInsets.all(10),
                                    alignment: Alignment.center,
                                    child: Text(
                                      doc['name'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12.0,
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
                    },
                  ),
                ),
              ]),
              Container(
                  padding: EdgeInsets.symmetric(vertical: spacing_middle),
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
                              viewportFraction: 0.5,
                              aspectRatio: 3.0,
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
                            return BusinessItem(
                              business: {
                                ...snapshot.data.docs[index].data(),
                                "id": snapshot.data.docs[index].id
                              },
                            );
                          },
                        );
                      },
                    ),
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
