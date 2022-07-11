import 'package:flutter/material.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';

class HighlightText extends StatelessWidget {
  final String text;
  final String highlight;
  final bool isLast;

  final TextStyle textStyle = TextStyle(fontSize: 17.0);

  HighlightText(
      {Key key,
      @required this.text,
      @required this.highlight,
      @required this.isLast})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String text = this.text ?? '';
    if ((highlight?.isEmpty ?? true) || text.isEmpty) {
      return Text(text, style: textStyle);
    }

    if (isLast == true) {
      return Text(text, style: textStyle.copyWith(color: primaryColor));
    }

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;
    do {
      indexOfHighlight = text.indexOf(highlight, start);
      if (indexOfHighlight < 0) {
        // no highlight
        spans.add(_normalSpan(text.substring(start, text.length)));
        break;
      }
      if (indexOfHighlight == start) {
        // start with highlight.
        spans.add(_highlightSpan(highlight));
        start += highlight.length;
      } else {
        // normal + highlight
        spans.add(_normalSpan(text.substring(start, indexOfHighlight)));
        spans.add(_highlightSpan(highlight));
        start = indexOfHighlight + highlight.length;
      }
    } while (true);

    return Text.rich(TextSpan(children: spans));
  }

  TextSpan _highlightSpan(String content) {
    return TextSpan(
        text: content, style: textStyle.copyWith(fontWeight: FontWeight.bold));
  }

  TextSpan _normalSpan(String content) {
    return TextSpan(text: content, style: textStyle);
  }
}
