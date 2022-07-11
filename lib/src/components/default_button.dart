import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key key,
    this.text,
    this.press,
  }) : super(key: key);
  final String text;
  final Function press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        color: appColorAccent,
        onPressed: press,
        child: Text(
          text,
          style: TextStyle(
            fontSize: textSizeMedium,
            color: appColorPrimary,
          ),
        ),
      ),
    );
  }
}


Widget socialButton(var color, var icon, var value, var iconColor,
  var valueColor, VoidCallback onPressed, { double height = 50.0, double iconSize = 18.0, double fontSize = textSizeMedium }) {
  return SizedBox(
    width: double.infinity,
    height: height,
    child: FlatButton.icon(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: BorderSide(color: whiteColor)),
      color: color,
      onPressed: onPressed,
      icon: SvgPicture.asset(icon, color: iconColor, width: iconSize, height: iconSize),
      label: Text(
        value,
        style: TextStyle(fontSize: fontSize, color: valueColor),
      ),
    ),
  );
}