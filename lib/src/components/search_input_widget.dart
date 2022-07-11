import 'package:flutter/material.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/services/search_delegate.dart';

class SearchInputWidget extends StatefulWidget {
  final double position;
  final Color bgColor;
  final String hintText;

  SearchInputWidget(
      {Key key,
      this.hintText = "Buscar negocios",
      this.position = 0.0,
      this.bgColor = appLayout_background})
      : super(key: key);

  @override
  _SearchInputWidgetState createState() => _SearchInputWidgetState();
}

class _SearchInputWidgetState extends State<SearchInputWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      transform: Matrix4.translationValues(0.0, widget.position, 0.0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: boxDecoration(radius: 26, bgColor: widget.bgColor),
          child: GestureDetector(
            onTap: () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                      left: 26.0, top: 12.0, bottom: 12.0, right: 50.0),
                  child: text(widget.hintText),
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Icon(
                      Icons.search,
                      color: primaryColor,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
