import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/views/home_view.dart';
import 'package:jaipi/src/views/order_detail_view.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackingView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'tracking';

  final String orderId;

  TrackingView({Key key, this.orderId}) : super(key: key);

  @override
  _TrackingViewState createState() => _TrackingViewState();
}

class _TrackingViewState extends State<TrackingView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic> order;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    changeStatusColor(appColorPrimary);
    var width = MediaQuery.of(context).size.width;
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (order == null &&
              snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                body: LoadingOverlay(isLoading: true, child: Container()));
          }

          order = snapshot.data.data();

          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: text("Pedido #${order['number']}")),
            backgroundColor: appLayout_background,
            extendBody: true,
            body: LoadingOverlay(
                isLoading: isLoading ||
                    snapshot.connectionState == ConnectionState.waiting,
                child: SingleChildScrollView(
                    child: Container(
                  width: width,
                  child: Stepper(
                    controlsBuilder: (context, _) {
                      return Row(
                        children: <Widget>[
                          TextButton(
                            onPressed: () {},
                            child: const Text(''),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(''),
                          ),
                        ],
                      );
                    },
                    currentStep: order['status_step'] - 1,
                    steps: [
                      Step(
                          title: text("Tu pedido fue recibido",
                              textColor: textSecondaryColor),
                          content: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                text(
                                    "Tu pedido fue recibido y pronto será confirmado",
                                    maxLine: null),
                                SizedBox(
                                  height: spacing_standard,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // launchScreen(context, OrderDetail.routeName, arguments: order);
                                    showCancelDialog(context);
                                  },
                                  child: text("Cancelar pedido",
                                      textColor: appColorPrimary,
                                      fontWeight: fontSemibold),
                                )
                              ],
                            ),
                          ),
                          state:
                              order['status_step'] > ORDER_CLIENT_RECEIVED_STEP
                                  ? StepState.complete
                                  : StepState.indexed,
                          isActive: order['status_step'] ==
                              ORDER_CLIENT_RECEIVED_STEP),
                      Step(
                          title: text("Tu pedido se está preparando",
                              textColor: textSecondaryColor),
                          content: Container(),
                          state: order['status_step'] >
                                  ORDER_CLIENT_IN_PROGRESS_STEP
                              ? StepState.complete
                              : StepState.indexed,
                          isActive: order['status_step'] ==
                              ORDER_CLIENT_IN_PROGRESS_STEP),
                      Step(
                          title: text("Tu pedido está en camino",
                              textColor: textSecondaryColor),
                          content: Container(),
                          state: order['status_step'] >
                                  ORDER_CLIENT_DELIVERING_STEP
                              ? StepState.complete
                              : StepState.indexed,
                          isActive: order['status_step'] ==
                              ORDER_CLIENT_DELIVERING_STEP),
                      Step(
                          title: text("Tu pedido llegó",
                              textColor: textSecondaryColor),
                          content: Container(),
                          state: order['status_step'] >
                                  ORDER_CLIENT_WAITING_CLIENT_STEP
                              ? StepState.complete
                              : StepState.indexed,
                          isActive: order['status_step'] ==
                              ORDER_CLIENT_WAITING_CLIENT_STEP),
                      Step(
                          title: text("Pedido finalizado",
                              textColor: textSecondaryColor),
                          content: Container(),
                          state: order['driver_current_step'] ==
                                  ORDER_CLIENT_FINISHED_STEP
                              ? StepState.complete
                              : StepState.indexed,
                          isActive: order['driver_current_step'] ==
                              ORDER_CLIENT_FINISHED_STEP)
                    ],
                  ),
                ))),
            bottomNavigationBar: Container(
              width: width,
              height: 118,
              decoration: boxDecoration(radius: 0),
              padding: EdgeInsets.all(spacing_standard_new),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      tabItem(
                          title: "Detalle pedido",
                          icon: Icons.restaurant_menu,
                          onTap: () {
                            launchScreen(context, OrderDetail.routeName,
                                arguments: order);
                          }),
                      tabItem(
                          title: "Ayuda jaipi",
                          icon: Icons.support_agent,
                          onTap: () {
                            Uri waUrl = Uri(
                                scheme: "https",
                                host: "wa.me",
                                path: "52$WHATSAPPPHONE",
                                queryParameters: {
                                  "text":
                                      "Hola, necesito ayuda con el pedido #${order['number']}"
                                });
                            launch(waUrl.toString());
                          })
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  void showCancelDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("No"));

    Widget okButton = FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
          setState(() {
            isLoading = true;
          });
          // Document referente
          DocumentReference order = FirebaseFirestore.instance
              .collection('orders')
              .doc(widget.orderId);

          order.update({
            'status': ORDER_CANCELED, // New status
            'driver_current_step': ORDER_DRIVER_FINISHED_STEP,
            'status_step': ORDER_CLIENT_FINISHED_STEP,
            'canceled_by': 'client'
          }).then((doc) {
            setState(() {
              isLoading = false;
            });
            Navigator.pushNamedAndRemoveUntil(
                context, HomeView.routeName, (route) => false);
          });
        },
        child: Text("Si, estoy seguro"));

    AlertDialog confirm = AlertDialog(
      title: Text("¿Quieres cancelar el pedido?"),
      content: Text("Hacer esto frecuentemente puede afectar tu reputación."),
      actions: [cancelButton, okButton],
    );

    showDialog(
        context: _scaffoldKey.currentContext,
        builder: (BuildContext context) {
          return confirm;
        });
  }

  Widget tabItem(
      {IconData icon, String title, Function onTap, bool disabled = false}) {
    return InkWell(
      onTap: disabled == true ? () {} : onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.width * 0.2,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              size: MediaQuery.of(context).size.width * 0.07,
              color: disabled ? Colors.grey[300] : textPrimaryColor,
            ),
            SizedBox(height: spacing_standard_new),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1,
                fontSize: textSizeSMedium,
                fontWeight: fontSemibold,
                color: disabled ? Colors.grey[300] : textPrimaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
