import 'package:flutter/material.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/providers/cart_provider.dart';
import 'package:jaipi/src/views/tracking_view.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'payment';

  @override
  _PaymentViewState createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  Map<String, dynamic> paymentTypes = {
    'cash': {
      'title': 'Pago en efectivo',
      'subtitle': 'Al recibir tu pedido',
      'secondary': Image.asset("assets/images/pago.png")
    },
    'zettle': {
      'title': 'Pago con tarjeta',
      'subtitle': 'Con Zettle al recibir tu pedido',
      'secondary': Image.asset(
        "assets/images/zettle.png",
        width: 55,
        height: 40,
      )
    },
    /*'clip': {
      'title': 'Pago con tarjeta',
      'subtitle': 'Con Clip al recibir tu pedido',
      'secondary': Image.asset(
        "assets/images/clip.png",
        width: 55,
        height: 40,
      )
    },
    'online': {
      'title': 'Pago con tarjeta',
      'subtitle': 'Paga en línea'
    },*/
  };
  SharedPreferences _prefs;
  Map<String, dynamic> paymentIntentData;
  String _selectedPayment = 'cash';
  bool isLoading = false;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  void setError(dynamic error) {
    setState(() {});
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(whiteColor);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
      ),
      body: LoadingOverlay(
          isLoading: isLoading,
          progressIndicator: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/progress.gif",
                  width: 120,
                ),
                text("¡Estamos preparando tu pedido!",
                    isCentered: true,
                    fontWeight: fontSemibold,
                    fontSize: textSizeLargeMedium),
              ],
            ),
          ),
          child: Container(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Container(
                margin: EdgeInsets.only(
                    left: spacing_standard_new,
                    right: spacing_standard_new,
                    bottom: spacing_xlarge),
                child: text("Elige tu método de pago",
                    fontSize: textSizeLarge, fontWeight: fontSemibold),
              ),
              Expanded(
                child: Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: spacing_standard_new),
                  child: ListView(
                    children: paymentTypes.keys.map((String paymentMethod) {
                      return Container(
                        margin: EdgeInsets.only(bottom: spacing_standard_new),
                        decoration: BoxDecoration(
                          color: viewLineColor,
                          boxShadow: [
                            BoxShadow(
                                color: food_ShadowColor,
                                blurRadius: 10,
                                spreadRadius: 2)
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: new RadioListTile(
                          title: Text(paymentTypes[paymentMethod]['title']),
                          subtitle:
                              Text(paymentTypes[paymentMethod]['subtitle']),
                          value: paymentMethod,
                          secondary: paymentTypes[paymentMethod]['secondary'],
                          /*const Icon(Icons.payment),*/
                          activeColor: appColorPrimary,
                          groupValue: _selectedPayment,
                          controlAffinity: ListTileControlAffinity.trailing,
                          onChanged: (String value) {
                            setState(() {
                              context.read<CartProvider>().order.paymentMethod =
                                  value;
                              _selectedPayment = value;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                height: 80,
                decoration: boxDecoration(
                    showShadow: true, radius: 0, bgColor: food_white),
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
                            "Total: \$${context.watch<CartProvider>().orderTotal().toStringAsFixed(0)}",
                            fontSize: textSizeLargeMedium,
                            fontWeight: fontSemibold),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });

                        // Create order
                        final order = await Provider.of<CartProvider>(context,
                                listen: false)
                            .createOrder(context);

                        Navigator.pushNamedAndRemoveUntil(
                            context, TrackingView.routeName, (route) => false,
                            arguments: order.id);

                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(spacing_large,
                            spacing_middle, spacing_large, spacing_middle),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: appColorAccent,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: "Confirmar pedido",
                                  style: TextStyle(
                                      fontSize: textSizeMedium,
                                      color: appColorPrimary,
                                      fontWeight: fontSemibold)),
                              WidgetSpan(
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: spacing_standard),
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
              )
            ]),
          )),
    );
  }
}
