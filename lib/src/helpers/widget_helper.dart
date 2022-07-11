import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';

BoxDecoration boxDecoration(
    {double radius = spacing_middle,
    Color color = Colors.transparent,
    Color bgColor = food_white,
    var showShadow = false}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow
        ? [BoxShadow(color: food_ShadowColor, blurRadius: 6, spreadRadius: 2)]
        : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}

Widget text(String text,
    {var fontSize = textSizeMedium,
    textColor = food_textColorPrimary,
    var fontWeight = fontRegular,
    var isCentered = false,
    var maxLine = 1,
    var latterSpacing = 0.25,
    var textAllCaps = false,
    var textDecoration = TextDecoration.none,
    var isLongText = false}) {
  return Text(
    textAllCaps ? text.toUpperCase() : text,
    textAlign: isCentered ? TextAlign.center : TextAlign.start,
    maxLines: isLongText ? null : maxLine,
    style: TextStyle(
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: textColor,
        height: 1.5,
        letterSpacing: latterSpacing,
        decoration: textDecoration),
  );
}

Widget mHeading(String value,
    {var fontSize = textSizeLargeMedium, String subtitle = ""}) {
  return Container(
    margin: EdgeInsets.only(
        left: spacing_standard_new, right: spacing_standard_new),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(value, fontWeight: fontSemibold, fontSize: fontSize),
        subtitle != ""
            ? text(subtitle, textColor: textSecondaryColor)
            : Container()
      ],
    ),
  );
}

Widget mDivider(double width) {
  return Container(
      height: 0.5,
      width: width,
      color: food_view_color,
      margin: EdgeInsets.only(
          top: spacing_standard_new, bottom: spacing_standard_new));
}

Widget mPrice(Map<String, dynamic> item, { bool isLarge = false, bool withSymbol = false}) {
  if (item['price'] == 0.0) {
    return Container();
  }
  
  double price = getRealPrice(item['price'], item['with_discount'], item['discount'], item['discount_type']);

  return Row(
    children: [
      text(
        withSymbol ? "\+ \$${price.toStringAsFixed(2)}" : "\$ ${price.toStringAsFixed(2)}",
        fontWeight: fontSemibold,
        fontSize: isLarge ? textSizeMedium : textSizeSMedium
      ),
      item['with_discount'] ?
        Row(
          children: [
            SizedBox(width: 10,),
            text(
              "\$ ${item['price'].toStringAsFixed(2)}",
              fontSize:  isLarge ? textSizeMedium : textSizeSMedium,
              textColor: textMutedColor,
              textDecoration: TextDecoration.lineThrough
            )
          ],
        ) : Container()
    ],
  );
}

double getRealPrice(double price, bool withDiscount, double discount, String discountType) {
    if (withDiscount == false)
      return price;

    // Percentage
    if (discountType == 'percentage') {
      return price - (price * (discount / 100));
    }

    // Fixed
    return price - discount;
  }
