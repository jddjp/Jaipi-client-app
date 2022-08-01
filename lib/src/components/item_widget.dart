import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jaipi/src/config/config.dart';
import 'package:jaipi/src/helpers/helpers.dart';
import 'package:jaipi/src/models/models.dart';
import 'package:jaipi/src/views/views.dart';

class ItemWidget extends StatefulWidget {
  final ItemModel item;

  ItemWidget({Key key, this.item}) : super(key: key);

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        launchScreen(context, ItemView.routeName, arguments: widget.item);
      },
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
                right: spacing_standard_new,
                left: spacing_standard_new,
                bottom: spacing_standard_new),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.item.image != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.all(Radius.circular(spacing_middle)),
                        child: CachedNetworkImage(
                            placeholder: (context, url) =>
                                Image.asset('assets/images/placeholder.png'),
                            imageUrl: widget.item.image.url,
                            width: width * 0.23,
                            height: width * 0.23,
                            fit: BoxFit.cover),
                      )
                    : Container(),
                SizedBox(width: spacing_middle),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      text(widget.item.name, fontWeight: fontSemibold),
                      text(widget.item.description,
                          textColor: textSecondaryColor,
                          fontSize: textSizeSMedium,
                          maxLine: 2),
                      Row(
                        children: [mPrice(widget.item.toJSON())],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
