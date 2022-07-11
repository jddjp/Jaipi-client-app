import 'package:flutter/material.dart';
// import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

back(var context) {
  Navigator.pop(context);
}

launchScreen(context, String routeName, {Object arguments}) {
  if (arguments == null) {
    Navigator.pushNamed(context, routeName);
  } else {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }
}

changeStatusColor(Color color) async {
  try {
    // await FlutterStatusbarcolor.setStatusBarColor(color, animate: true);
    // FlutterStatusbarcolor.setStatusBarWhiteForeground(
    //     useWhiteForeground(color));
  } on Exception catch (e) {
    print(e);
  }
}
