import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:flutter/material.dart';

class OrderItemView extends StatefulWidget {
  static const routeName = 'order_item_view';

  final Map<String, dynamic> item;

  OrderItemView({Key key, this.item}) : super(key: key);

  @override
  _OrderItemViewState createState() => _OrderItemViewState();
}

class _OrderItemViewState extends State<OrderItemView> {
  Map<String, dynamic> options = {};

  @override
  void initState() {
    super.initState();

    if (widget.item['options'] != null) {
      // Order items
      setState(() {
        widget.item['options'].forEach((opt) {
          if (options[opt['optionId']] == null) {
            options[opt['optionId']] = {...opt, "options": []};
          }
          options[opt['optionId']]['options'].add(opt);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: text("Detalles del producto"),
      ),
      backgroundColor: appLayout_background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.item['image'] != null
                  ? Container(
                      width: width,
                      decoration: boxDecoration(radius: 0),
                      child: Image.network(widget.item['image']),
                    )
                  : Container(),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: spacing_standard_new,
                    vertical: spacing_standard),
                child: text("Descripción del producto",
                    textColor: textSecondaryColor, fontSize: textSizeSMedium),
              ),
              Container(
                width: width,
                padding: EdgeInsets.symmetric(
                    horizontal: spacing_standard_new,
                    vertical: spacing_standard),
                decoration: boxDecoration(radius: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(widget.item['name'], fontWeight: fontSemibold),
                    text("Precio por unidad:",
                        fontWeight: fontSemibold, fontSize: textSizeSMedium),
                    text("\$ ${widget.item['subtotal'].toStringAsFixed(0)}"),
                    SizedBox(height: spacing_standard),
                    text("${widget.item['quantity']} Unidades",
                        fontSize: textSizeSMedium,
                        textColor: textSecondaryColor,
                        fontWeight: fontSemibold),
                    SizedBox(height: spacing_standard),
                    widget.item['description'] != null
                        ? text(widget.item['description'])
                        : Container()
                  ],
                ),
              ),
              options.length > 0
                  ? Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: spacing_standard_new,
                          vertical: spacing_standard),
                      child: text("Adicionales ya incluídas en el precio:",
                          textColor: textSecondaryColor,
                          fontSize: textSizeSMedium),
                    )
                  : Container(),
              Container(
                  width: width,
                  padding: EdgeInsets.symmetric(
                      horizontal: spacing_standard_new,
                      vertical: spacing_standard),
                  decoration: boxDecoration(radius: 0),
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
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(height: spacing_control);
                            },
                          ),
                          SizedBox(height: spacing_standard_new)
                        ],
                      );
                    }).toList(),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
