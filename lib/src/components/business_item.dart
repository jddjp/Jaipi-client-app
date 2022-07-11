import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/config/images.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/helpers/utils_helper.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/views/business_view.dart';

class BusinessItem extends StatelessWidget {
  final Map<String, dynamic> business;

  BusinessItem({Key key, this.business}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        launchScreen(context, BusinessView.routeName,
            arguments: business['id']);
      },
      child: Container(
        decoration: boxDecoration(
          showShadow: true,
        ),
        margin: EdgeInsets.only(
            right: spacing_standard_new,
            left: spacing_standard_new,
            bottom: spacing_standard_new),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            business['logo'] != null
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.all(Radius.circular(spacing_middle)),
                    child: CachedNetworkImage(
                        imageUrl: business['logo']['url'],
                        width: width * 0.23,
                        height: width * 0.23,
                        fit: BoxFit.fill),
                  )
                : Container(),
            SizedBox(width: spacing_middle),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  text(business['name'], fontWeight: fontSemibold),
                  Row(
                    children: business['categories'].map<Widget>((category) {
                      return text(category + " ",
                          textColor: textSecondaryColor,
                          fontSize: textSizeSMedium);
                    }).toList(),
                  ),
                  Row(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            ic_stopwatch,
                            width: 18,
                            height: 18,
                            color: Colors.blue,
                          ),
                          SizedBox(width: spacing_standard),
                          text("${business['delivery_time']} min",
                              fontSize: textSizeSMedium)
                        ],
                      ),
                      Expanded(child: Container()),
                      isOpenBusiness(business)
                          ? Text(
                              "Abierto",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: food_color_green
                              ),
                              textAlign: TextAlign.center,
                            )
                          : Container()
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
