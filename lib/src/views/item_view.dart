import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jaipi/src/components/item_option_widget.dart';
import 'package:jaipi/src/components/stepper_counter.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/controllers/order_controller.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/models/item_model.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ItemView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'item';

  final ItemModel item;

  ItemView({Key key, this.item}) : super(key: key);

  @override
  _ItemViewState createState() => _ItemViewState(item);
}

class _ItemViewState extends StateMVC<ItemView> {
  OrderController _con;

  _ItemViewState(ItemModel item) : super(OrderController(item)) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    double expandHeight = _con.item != null && _con.item.image != null
        ? MediaQuery.of(context).size.height * 0.33
        : 0;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: food_app_background,
      body: LoadingOverlay(
        isLoading: _con.isLoading,
        child: _con.item == null
            ? Container()
            : NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: expandHeight,
                      floating: true,
                      forceElevated: innerBoxScrolled,
                      pinned: true,
                      titleSpacing: 0,
                      backgroundColor: Colors.white,
                      actionsIconTheme: IconThemeData(opacity: 0.0),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          height: expandHeight,
                          child: _con.item.image != null
                              ? CachedNetworkImage(
                                  imageUrl: _con.item.image.url,
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
                        padding:
                            EdgeInsets.only(bottom: 100 + spacing_standard_new),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: width,
                              padding: EdgeInsets.all(spacing_standard_new),
                              decoration: boxDecoration(radius: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: text(_con.item.name,
                                            fontSize: textSizeNormal,
                                            fontWeight: fontBold,
                                            maxLine: null),
                                      ),
                                      mPrice(_con.item.toJSON(), isLarge: true)
                                    ],
                                  ),
                                  SizedBox(height: spacing_standard),
                                  text(_con.item.description,
                                      textColor: textSecondaryColor,
                                      isLongText: true)
                                ],
                              ),
                            ),
                            SizedBox(height: spacing_standard),
                            ListView.separated(
                              primary: false,
                              shrinkWrap: true,
                              itemCount: _con.itemOptions.length,
                              itemBuilder: (BuildContext context, index) {
                                return ItemOptionWidget(
                                    itemOption: _con.itemOptions[index],
                                    price: _con.item.price,
                                    onChange: _con.onChangeOption,
                                    errors: _con.errors);
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(height: spacing_standard_new);
                              },
                            ),
                          ],
                        )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        height: 100,
                        decoration: boxDecoration(
                            showShadow: true, radius: 0, bgColor: food_white),
                        padding: EdgeInsets.all(spacing_standard_new),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            StepperCounter(
                              stepperValue: _con.orderItem.quantity,
                              onIncrement: () {
                                _con.incrementQuantity();
                              },
                              onDecrement: () {
                                _con.decrementQuantity();
                              },
                              iconSize: 33.0,
                            ),
                            SizedBox(width: spacing_standard_new),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Add to cart
                                  if (_con.addToCart(context) == true) {
                                    back(context);
                                  }
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        text("Agregar",
                                            isCentered: true,
                                            textColor: primaryColor,
                                            fontSize: textSizeMedium,
                                            fontWeight: fontSemibold),
                                        text(
                                            "\$${_con.totalPrice.toStringAsFixed(2)}",
                                            isCentered: true,
                                            textColor: primaryColor,
                                            fontSize: textSizeMedium,
                                            fontWeight: fontSemibold)
                                      ],
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
