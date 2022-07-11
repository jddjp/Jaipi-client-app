import 'package:flutter/material.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';

class LoadingView extends StatelessWidget {
  final String sourceLoading;

  LoadingView({this.sourceLoading});

  @override
  Widget build(BuildContext context) {
    changeStatusColor(primaryColor);
    return Scaffold(
      body: SafeArea(
          child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: spacing_standard_new),
            text(sourceLoading)
          ],
        ),
      )),
    );
  }
}
