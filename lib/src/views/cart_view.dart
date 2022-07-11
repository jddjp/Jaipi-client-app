import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jaipi/src/components/alert_widget.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/models/order_item_model.dart';
import 'package:jaipi/src/providers/cart_provider.dart';
import 'package:jaipi/src/providers/location_provider.dart';
import 'package:jaipi/src/providers/login_provider.dart';
import 'package:jaipi/src/views/addresses_view.dart';
import 'package:jaipi/src/views/complete_profile_view.dart';
import 'package:jaipi/src/views/payment_view.dart';
import 'package:jaipi/src/views/home_view.dart';
import 'package:provider/provider.dart';
import 'package:jaipi/src/components/default_button.dart';

class CartView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'cart';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  _CartViewState createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  String couponCode;
  bool couponError = false;

  @override
  Widget build(BuildContext context) {
    changeStatusColor(whiteColor);
    var width = MediaQuery.of(context).size.width;

    if (context.watch<CartProvider>().isEmpty()) {
      return Scaffold(
        appBar: AppBar(
          title: text("Tu pedido"),
          backgroundColor: whiteColor,
        ),
        body: Container(
            width: width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/empty-cart.png",
                    width: 120,
                  ),
                  text("¡Tu carrito está vacío!",
                      isCentered: true,
                      fontWeight: fontSemibold,
                      fontSize: textSizeLargeMedium),
                  text("Aún no tienes productos en tu carrito",
                      maxLine: null,
                      isCentered: true,
                      textColor: textSecondaryColor),
                  SizedBox(
                    height: spacing_standard_new,
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: spacing_standard_new),
                    child: DefaultButton(
                      text: "Explorar productos",
                      press: () {
                        launchScreen(context, HomeView.routeName);
                      },
                    ),
                  )
                ])),
      );
    }

    return Scaffold(
      backgroundColor: food_white,
      bottomNavigationBar: Container(
        height: context.watch<CartProvider>().hasService == true ? 190 : 115,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: food_app_background,
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    size: 30,
                  ),
                  SizedBox(
                    width: spacing_standard,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          text("Dirección de entrega:",
                              fontWeight: fontSemibold),
                          InkWell(
                            onTap: () {
                              launchScreen(context, AddressesView.routeName);
                            },
                            child: text("Cambiar",
                                fontSize: 16.0, textColor: food_colorPrimary),
                          ),
                        ],
                      ),
                      text(context.watch<LocationProvider>().shortAddress(),
                          maxLine: 2),
                      /*text("Tiempo aproximado de entrega: 30min",
                          fontSize: 14.0, textColor: food_textColorSecondary),*/
                    ],
                  ))
                ],
              ),
            ),
            context.watch<CartProvider>().hasService == true
                ? mBottom(context, widget)
                : Container()
          ],
        ),
      ),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconButton(
            onPressed: () {
              back(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: food_textColorPrimary,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(
                    left: spacing_standard_new,
                    right: spacing_standard_new,
                    top: spacing_control),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    text("Tu pedido",
                        fontSize: textSizeLarge, fontWeight: fontSemibold),
                    SizedBox(
                      height: spacing_standard_new,
                    ),
                    context.watch<CartProvider>().hasService == false
                        ? AlertWidget(
                            bgColor: Colors.red,
                            alertText:
                                "Lo sentimos aún no tenemos cobertura en la dirección ingresada.",
                          )
                        : Container(),
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: context.watch<CartProvider>().items.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return CartItemWidget(
                              context.watch<CartProvider>().items[index]);
                        }),
                    SizedBox(
                      height: spacing_standard,
                    ),
                    Container(
                      height: 0.5,
                      color: food_view_color,
                      width: width,
                    ),
                    SizedBox(
                      height: spacing_standard,
                    ),
                    (context.watch<CartProvider>().hasCoupon
                        ? InkWell(
                            onTap: () {
                              Provider.of<CartProvider>(context, listen: false)
                                  .deleteCoupon();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: text(
                                      "Cupón: ${context.watch<CartProvider>().coupon['code']}"),
                                ),
                                text("Eliminar",
                                    textColor: food_colorAccent,
                                    isCentered: true)
                              ],
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              setState(() {
                                couponError = false;
                              });
                              couponDialog(context);
                            },
                            child: Row(children: [
                              Image.asset(
                                "assets/images/coupon.png",
                                height: 32,
                              ),
                              SizedBox(
                                width: spacing_standard_new,
                              ),
                              Expanded(child: text("Ingresar cupón")),
                              Icon(Icons.arrow_forward)
                            ]),
                          )),
                    SizedBox(
                      height: spacing_standard,
                    ),
                    Container(
                      height: 0.5,
                      color: food_view_color,
                      width: width,
                    ),
                    SizedBox(
                      height: spacing_standard_new,
                    ),
                    text("Detalle del pedido:",
                        textAllCaps: true, fontWeight: fontSemibold),
                    SizedBox(
                      height: spacing_control,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        text(
                          "Sub Total",
                        ),
                        text(
                          "\$${context.watch<CartProvider>().order.subtotal.toStringAsFixed(2)}",
                        ),
                      ],
                    ),
                    (context.watch<CartProvider>().hasCoupon &&
                            context.watch<CartProvider>().coupon['target'] ==
                                DISCOUNT_SUBTOTAL
                        ? Container(
                            margin: EdgeInsets.only(bottom: spacing_control),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                text(context
                                    .watch<CartProvider>()
                                    .discountLabel()),
                                text(
                                    "-\$${context.watch<CartProvider>().couponDiscount().toStringAsFixed(2)}",
                                    textColor: food_colorAccent),
                              ],
                            ),
                          )
                        : Container()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        text(
                          "Costo de envío",
                        ),
                        (context.watch<CartProvider>().deliveryCost() == 0.0
                            ? text("GRATIS", textColor: Colors.green)
                            : (context.watch<CartProvider>().deliveryCost() ==
                                    -1
                                ? text("-")
                                : text(
                                    "\$${context.watch<CartProvider>().deliveryCost().toStringAsFixed(2)}",
                                  ))),
                      ],
                    ),
                    (context.watch<CartProvider>().hasCoupon &&
                            context.watch<CartProvider>().coupon['target'] ==
                                DISCOUNT_TOTAL
                        ? Container(
                            margin: EdgeInsets.only(bottom: spacing_control),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                text(context
                                    .watch<CartProvider>()
                                    .discountLabel()),
                                text(
                                    "-\$${context.watch<CartProvider>().couponDiscount().toStringAsFixed(2)}",
                                    textColor: food_colorAccent),
                              ],
                            ),
                          )
                        : Container()),
                    Container(
                      height: 0.5,
                      color: food_view_color,
                      width: width,
                      margin:
                          EdgeInsets.symmetric(vertical: spacing_standard_new),
                    ),
                    Form(
                      key: widget._formKey,
                      child: Container(
                        width: width,
                        decoration: boxDecoration(radius: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            text("¿Quieres aclarar algo?"),
                            SizedBox(height: spacing_standard),
                            TextFormField(
                              maxLines: 3,
                              style: TextStyle(fontSize: textSizeMedium),
                              initialValue:
                                  context.watch<CartProvider>().order.comment,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(12, 8, 12, 8),
                                hintText: "Ingresa notas para tu pedido",
                                filled: true,
                                fillColor: food_white,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide: const BorderSide(
                                        color: food_view_color, width: 1.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide: const BorderSide(
                                        color: food_view_color, width: 1.0)),
                              ),
                              onSaved: (String value) {
                                context.read<CartProvider>().order.comment =
                                    value;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: spacing_standard,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      )),
    );
  }

  Future<bool> couponDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Ingresar código"),
            content: Container(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(labelText: "Código de cupón"),
                    autofocus: true,
                    onChanged: (value) {
                      couponCode = value;
                    },
                  ),
                  (couponError == true
                      ? Text(
                          "El cupón no es válido.",
                          style: TextStyle(color: Colors.red),
                        )
                      : Container())
                ],
              ),
            ),
            actions: [
              FlatButton(
                child: Text("Ingresar"),
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false)
                      .validateCoupon(couponCode)
                      .then((result) {
                    if (result == 'success') {
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        couponError = true;
                      });
                      Navigator.of(context).pop();
                      couponDialog(context).then((value) => {});
                    }
                  });
                },
              )
            ],
          );
        });
  }
}

class CartItemWidget extends StatelessWidget {
  OrderItemModel orderItem;

  CartItemWidget(OrderItemModel orderItem) {
    this.orderItem = orderItem;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: spacing_standard),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius:
                      BorderRadius.all(Radius.circular(spacing_middle)),
                  child: orderItem.item.image != null
                      ? Image(
                          width: 50,
                          height: 50,
                          image: CachedNetworkImageProvider(
                              orderItem.item.image.url),
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/images/fast-food.png",
                          width: 50,
                          height: 50,
                        ),
                ),
                SizedBox(
                  width: spacing_middle,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (orderItem.options != null &&
                          orderItem.options.length > 1) {
                        showAdditionalsDialog(context, orderItem);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        text(orderItem.item.name,
                            fontWeight: fontSemibold, maxLine: null),
                        text("${orderItem.quantity} Unidad(es)",
                            fontSize: textSizeSMedium,
                            textColor: Colors.grey[500],
                            fontWeight: fontSemibold),
                        orderItem.options != null &&
                                orderItem.options.length > 1
                            ? text("${orderItem.options.length} Adicionales",
                                fontSize: textSizeSMedium,
                                textColor: appColorAccent)
                            : Container(),
                        //text("sd",textColor: food_textColorSecondary),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    text("\$ ${orderItem.total.toStringAsFixed(2)}"),
                    //SizedBox(height: spacing_control,),
                    InkWell(
                        onTap: () {
                          removeOrderItem(context, orderItem.id);
                        },
                        child: Icon(
                          Icons.delete,
                          size: textSizeNormal,
                          color: Colors.red,
                        ))
                  ],
                ),
              ],
            ),
          ),
          // Quantitybtn()
        ],
      ),
    );
  }

  void removeOrderItem(BuildContext context, String orderId) {
    Widget cancelButton = FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("No"));

    Widget okButton = FlatButton(
        onPressed: () {
          Provider.of<CartProvider>(context, listen: false)
              .removeItem(orderItem.id);
          Navigator.of(context).pop();
        },
        child: Text("Eliminar"));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("¿Eliminar producto?"),
            content: Text("Este producto será eliminado de tu pedido."),
            actions: [cancelButton, okButton],
          );
        });
  }

  void showAdditionalsDialog(BuildContext context, OrderItemModel orderItem) {
    Map<String, dynamic> options = {};

    if (orderItem.options != null) {
      orderItem.options.forEach((opt) {
        if (options[opt['optionId']] == null) {
          options[opt['optionId']] = {...opt, "options": []};
        }
        options[opt['optionId']]['options'].add(opt);
      });
    }

    Dialog additionalsDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0))
            ],
          ),
          padding: EdgeInsets.all(spacing_large),
          width: MediaQuery.of(context).size.width,
          //height: MediaQuery.of(context).size.width * 0.5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: options.values.map((option) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(option['optionName'], fontWeight: fontSemibold),
                    SizedBox(height: spacing_standard),
                    ListView.separated(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: option['options'].length,
                      itemBuilder: (BuildContext context, int index) {
                        var opt = option['options'][index];

                        return text(
                            (option['type'] == 'addon'
                                    ? "${opt['quantity']}x "
                                    : "") +
                                opt['name'],
                            textColor: textSecondaryColor,
                            fontSize: textSizeSMedium);
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: spacing_control);
                      },
                    ),
                    SizedBox(height: spacing_standard_new)
                  ],
                );
              }).toList(),
            ),
          )),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return additionalsDialog;
        });
  }
}

Widget mBottom(BuildContext context, var widget
    /* var value, var tags*/
    ) {
  var width = MediaQuery.of(context).size.width;

  return Container(
    height: 80,
    decoration: boxDecoration(showShadow: true, radius: 0, bgColor: food_white),
    padding: EdgeInsets.all(spacing_standard_new),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            text(
                "Total: \$${context.watch<CartProvider>().orderTotal().toStringAsFixed(2)}",
                fontSize: textSizeLargeMedium,
                fontWeight: fontSemibold),
          ],
        ),
        GestureDetector(
          onTap: () {
            if (widget._formKey.currentState.validate()) {
              widget._formKey.currentState.save();
              if (Provider.of<LocationProvider>(context, listen: false)
                      .getAddress()
                      .street ==
                  "Sin dirección") {
                return Fluttertoast.showToast(
                    msg: "Ingresa la dirección de envío.");
              }
              if (Provider.of<LoginProvider>(context, listen: false)
                      .isCompleted() ==
                  false) {
                Fluttertoast.showToast(msg: "Completa tu perfil.");
                return launchScreen(context, CompleteProfileView.routeName);
              }
              launchScreen(context, PaymentView.routeName);
            }
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(
                spacing_large, spacing_middle, spacing_large, spacing_middle),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: appColorAccent,
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: "Continuar",
                      style: TextStyle(
                          fontSize: textSizeMedium,
                          color: appColorPrimary,
                          fontWeight: fontSemibold)),
                  WidgetSpan(
                    child: Padding(
                        padding: const EdgeInsets.only(left: spacing_standard),
                        child: Icon(Icons.arrow_forward,
                            color: appColorPrimary, size: 18)),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ),
  );
}
