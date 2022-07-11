import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jaipi/src/views/order_item_view.dart';

class OrderDetail extends StatefulWidget {
  static const routeName = 'order_detail';

  final Map<String, dynamic> order;

  OrderDetail({Key key, this.order}) : super(key: key);

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: text("Detalles del pedido #${widget.order['number']}"),
      ),
      backgroundColor: appLayout_background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
                width: width,
                decoration: boxDecoration(radius: 0),
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      var item = widget.order['items'][index];

                      return InkWell(
                        onTap: () {
                          launchScreen(context, OrderItemView.routeName,
                              arguments: item);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: spacing_standard_new,
                              vertical: spacing_standard),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(spacing_middle)),
                                      child: item['image'] != null
                                          ? Image(
                                              width: 50,
                                              height: 50,
                                              image: CachedNetworkImageProvider(
                                                  item['image']),
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          text(item['name'],
                                              fontWeight: fontSemibold,
                                              maxLine: null),
                                          text("${item['quantity']} Unidad(es)",
                                              fontSize: textSizeSMedium,
                                              textColor: Colors.grey[500],
                                              fontWeight: fontSemibold),
                                          item['options'] != null &&
                                                  item['options'].length > 1
                                              ? text(
                                                  "${item['options'].length} Adicionales",
                                                  fontSize: textSizeSMedium,
                                                  textColor: appColorAccent)
                                              : Container(),
                                          //text("sd",textColor: food_textColorSecondary),
                                        ],
                                      ),
                                    ),
                                    text(
                                        "\$ ${item['total'].toStringAsFixed(0)}"),
                                  ],
                                ),
                              ),
                              // Quantitybtn()
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 10);
                    },
                    itemCount: widget.order['items'].length)),
            SizedBox(
              height: spacing_standard_new,
            ),
            Container(
              decoration: boxDecoration(radius: 0),
              padding: EdgeInsets.symmetric(
                  horizontal: spacing_standard_new, vertical: spacing_standard),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  cListTile(
                    title: text("Subtotal"),
                    trailing: text(
                        "\$ ${widget.order['subtotal'].toStringAsFixed(0)}"),
                  ),
                  cListTile(
                    title: text("Costo de envío"),
                    trailing: text(
                        "\$ ${widget.order['delivery_cost'].toStringAsFixed(0)}"),
                  ),
                  SizedBox(
                    height: spacing_standard,
                  ),
                  cListTile(
                    title: text("Total", fontWeight: fontSemibold),
                    trailing: text(
                        "\$ ${widget.order['total'].toStringAsFixed(0)}",
                        fontWeight: fontSemibold),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget cListTile({Widget title, Widget trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[title, trailing],
    );
  }
}
