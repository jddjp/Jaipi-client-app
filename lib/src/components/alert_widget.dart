import 'package:flutter/material.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';

class AlertWidget extends StatelessWidget {
  Color bgColor;
  String alertText;

  AlertWidget({this.bgColor, this.alertText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration(bgColor: bgColor),
      padding: EdgeInsets.all(spacing_standard),
      margin: EdgeInsets.only(bottom: spacing_standard),
      child: text(alertText,
          textColor: whiteColor, maxLine: null, fontSize: textSizeSMedium),
    );
  }
}
