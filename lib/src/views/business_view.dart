import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jaipi/src/components/item_widget.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/config/images.dart';
import 'package:jaipi/src/controllers/business_controller.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/helpers/utils_helper.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/providers/cart_provider.dart';
import 'package:jaipi/src/services/search_delegate.dart';
import 'package:jaipi/src/views/cart_view.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:jaipi/src/models/item_model.dart';

class BusinessView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'business';
  final String businessId;

  BusinessView({Key key, this.businessId}) : super(key: key);

  @override
  _BusinessViewState createState() => _BusinessViewState(businessId);
}

class _BusinessViewState extends StateMVC<BusinessView> {
  BusinessController _con;

  _BusinessViewState(String businessId)
      : super(BusinessController(businessId)) {
    _con = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Provider.of<CartProvider>(context, listen: false).setBusiness(widget.businessId);
  }

  @override
  Widget build(BuildContext context) {
    double expandHeight = MediaQuery.of(context).size.height * 0.3;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: food_app_background,
      body: LoadingOverlay(
        isLoading: _con.isLoading,
        child: SafeArea(
          child: _con.business == null
              ? Container()
              : NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        expandedHeight:
                            _con.business['cover'] != null ? expandHeight : 0,
                        floating: true,
                        forceElevated: innerBoxScrolled,
                        pinned: true,
                        titleSpacing: 0,
                        backgroundColor: Colors.white,
                        actionsIconTheme: IconThemeData(opacity: 0.0),
                        title: Container(
                          height: 60,
                          child: Container(
                            width: width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                innerBoxScrolled == true
                                    ? text(_con.business['name'],
                                        fontWeight: fontSemibold,
                                        fontSize: textSizeNormal)
                                    : Container(),
                                IconButton(
                                  icon: Icon(Icons.search,
                                      color: innerBoxScrolled == true
                                          ? textPrimaryColor
                                          : Colors.white),
                                  onPressed: () {
                                    showSearch(
                                        context: context,
                                        delegate: CustomSearchDelegate(
                                            business: _con.business));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            height: expandHeight,
                            child: _con.business['cover'] != null
                                ? CachedNetworkImage(
                                    imageUrl: _con.business['cover']['url'],
                                    height: expandHeight,
                                    fit: BoxFit.cover)
                                : null,
                          ),
                        ),
                      )
                    ];
                  },
                  body: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.only(
                            bottom: context.watch<CartProvider>().hasItems()
                                ? 150
                                : 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: width,
                              padding: EdgeInsets.all(spacing_standard_new),
                              decoration: boxDecoration(radius: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  text(_con.business['name'],
                                      fontSize: textSizeLarge,
                                      fontWeight: fontBold),
                                  _con.business['bio'] != null
                                      ? text(_con.business['bio'], maxLine: 5)
                                      : Container(),
                                  SizedBox(height: spacing_standard),
                                  Row(
                                    children: _con.business['categories']
                                        .map<Widget>((category) {
                                      return text(category,
                                          textColor: textSecondaryColor,
                                          fontSize: textSizeSMedium);
                                    }).toList(),
                                  ),
                                  SizedBox(height: spacing_standard),
                                  Row(
                                    children: [
                                      Image.asset(
                                        ic_stopwatch,
                                        width: 18,
                                        height: 18,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: spacing_standard),
                                      text(
                                          "${_con.business['delivery_time']} min",
                                          fontSize: textSizeSMedium)
                                    ],
                                  ),
                                  SizedBox(width: spacing_standard),
                                  isBusinessClosed(_con.business)
                                      ? Container(
                                          child: Column(
                                            children: <Widget>[
                                              Divider(),
                                              text(
                                                  _con.openToday()
                                                      ? "Abren pronto"
                                                      : "Cerrado por hoy",
                                                  textColor: Colors.red)
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  _con.hourOpen() != ""
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Divider(),
                                            text(
                                                "Horario de ${_con.hourOpen()} a ${_con.hourClose()}",
                                                fontSize: textSizeSMedium,
                                                textColor: textSecondaryColor)
                                          ],
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing_standard_new),
                            _con.sections != null
                                ? ListView.separated(
                                    primary: false,
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var section = _con.sections[index].data();
                                      var items =
                                          _con.items[_con.sections[index].id];

                                      return Container(
                                        width: width,
                                        decoration: boxDecoration(radius: 0),
                                        padding: EdgeInsets.symmetric(
                                            vertical: spacing_standard_new),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            mHeading(section['name']),
                                            SizedBox(
                                              height: spacing_standard,
                                            ),
                                            items != null
                                                ? ListView.separated(
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    itemCount: items.length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            index) {
                                                      return ItemWidget(item: new ItemModel.fromJSON({
                                                        ...items[index],
                                                        "business":
                                                            _con.business
                                                      }));
                                                    },
                                                    separatorBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return SizedBox(
                                                          height:
                                                              spacing_standard_new);
                                                    },
                                                  )
                                                : Container(
                                                    margin: EdgeInsets.only(
                                                        right:
                                                            spacing_standard_new,
                                                        left:
                                                            spacing_standard_new,
                                                        bottom:
                                                            spacing_standard_new),
                                                    child: Text(
                                                        "Aún no hay productos para esta sección"),
                                                  )
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(
                                          height: spacing_standard_new);
                                    },
                                    itemCount: _con.sections.length)
                                : Container()
                          ],
                        ),
                      ),
                      context.watch<CartProvider>().hasItems()
                          ? Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: Container(
                                height: 100,
                                decoration: boxDecoration(
                                    showShadow: true,
                                    radius: 0,
                                    bgColor: food_white),
                                padding: EdgeInsets.symmetric(
                                    vertical: spacing_large,
                                    horizontal: spacing_standard_new),
                                child: GestureDetector(
                                  onTap: () {
                                    Provider.of<CartProvider>(context, listen: false).calculateDeliveryData().then((value) {
                                      launchScreen(context, CartView.routeName);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        spacing_large,
                                        spacing_middle,
                                        spacing_large,
                                        spacing_middle),
                                    decoration: BoxDecoration(
                                      color: appColorAccent,
                                      boxShadow: [
                                        BoxShadow(
                                            color: food_ShadowColor,
                                            blurRadius: 10,
                                            spreadRadius: 2)
                                      ],
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        text(
                                            "Ver mi pedido",
                                            isCentered: true,
                                            textColor: primaryColor,
                                            fontSize: textSizeMedium,
                                        fontWeight: fontSemibold),
                                        text(
                                            "\$${context.watch<CartProvider>().order.subtotal.toStringAsFixed(2)}",
                                            isCentered: true,
                                            textColor: primaryColor,
                                            fontSize: textSizeMedium,
                                        fontWeight: fontSemibold)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
