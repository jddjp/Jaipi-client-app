import 'package:flutter/material.dart';
import 'package:jaipi/src/components/components.dart';
import 'package:jaipi/src/config/config.dart';
import 'package:jaipi/src/controllers/controllers.dart';
import 'package:jaipi/src/helpers/helpers.dart';
import 'package:jaipi/src/models/models.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ItemOptionWidget extends StatefulWidget {
  final ItemOptionModel itemOption;
  final double price;
  final void Function(ItemOptionModel, Map) onChange;
  final Map<String, String> errors;

  ItemOptionWidget(
      {@required this.itemOption,
      @required this.price,
      @required this.onChange,
      @required this.errors});

  @override
  _ItemOptionWidgetState createState() =>
      _ItemOptionWidgetState(itemOption, price, onChange);
}

class _ItemOptionWidgetState extends StateMVC<ItemOptionWidget> {
  ItemOptionController _con;

  _ItemOptionWidgetState(ItemOptionModel option, double price, onChange)
      : super(ItemOptionController(option, price, onChange)) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      decoration: boxDecoration(radius: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: spacing_standard,
          ),
          optionTitle(),
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: _con.itemOption.options.length,
            itemBuilder: (BuildContext context, index) {
              SingleItemOption option =
                  _con.itemOption.options.elementAt(index);
              if (option.active == false) {
                return Container();
              }

              if (_con.itemOption.type == 'addon') {
                return Container(
                  margin: EdgeInsets.only(
                      left: spacing_standard_new, bottom: spacing_standard),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            text(option.name),
                            mPrice(option.toJSON(), withSymbol: true)
                          ],
                        ),
                      ),
                      StepperCounter(
                        stepperValue: _con.selectedOptions[option.id],
                        onIncrement: () {
                          _con.incrementOption(option);
                        },
                        onDecrement: () {
                          _con.decrementOption(option);
                        },
                      )
                    ],
                  ),
                );
              } else if (_con.itemOption.max == 1 ||
                  _con.itemOption.multiple == false) {
                return RadioListTile(
                    title: Text(option.name),
                    subtitle: mPrice(option.toJSON(), withSymbol: true),
                    value: option,
                    controlAffinity: ListTileControlAffinity.trailing,
                    groupValue: _con.selectedOption,
                    onChanged: (selected) {
                      _con.onChangeOption(selected);
                    });
              } else {
                return CheckboxListTile(
                    title: Text(option.name),
                    subtitle: mPrice(option.toJSON(), withSymbol: true),
                    value: _con.checkboxSelected[option.id] ?? false,
                    onChanged: (selected) {
                      _con.onChangeOption(option, selected: selected);
                    });
              }
            },
          )
        ],
      ),
    );
  }

  Widget optionTitle() {
    return Container(
      margin: EdgeInsets.only(
          left: spacing_standard_new, right: spacing_standard_new),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(_con.itemOption.name,
                    fontWeight: fontSemibold, fontSize: textSizeLargeMedium),
                widget.errors[_con.itemOption.id] != null
                    ? text(widget.errors[_con.itemOption.id],
                        textColor: Colors.red, fontSize: textSizeSMedium)
                    : (_con.subtitle != ""
                        ? text(_con.subtitle,
                            textColor: textSecondaryColor,
                            fontSize: textSizeSMedium)
                        : Container())
              ],
            ),
          ),
          _con.itemOption.required == true
              ? Container(
                  decoration: boxDecoration(
                      bgColor: widget.errors[_con.itemOption.id] != null
                          ? Colors.red
                          : Colors.grey[400]),
                  padding: EdgeInsets.symmetric(horizontal: spacing_control),
                  margin: EdgeInsets.only(top: spacing_standard),
                  child: text("Obligatorio",
                      textColor: whiteColor, fontSize: textSizeSmall),
                )
              : Container()
        ],
      ),
    );
  }
}
