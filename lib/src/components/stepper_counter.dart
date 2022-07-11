import 'package:flutter/material.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';

class StepperCounter extends StatelessWidget {
  final double iconSize;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  int stepperValue;

  StepperCounter({
    @required this.stepperValue,
    @required this.onIncrement,
    @required this.onDecrement,
    this.iconSize = textSizeNormal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoundedIconButton(
          icon: Icons.remove,
          iconSize: iconSize,
          onPress: onDecrement,
        ),
        Container(
          width: iconSize,
          child: Text(
            stepperValue.toString(),
            style: TextStyle(
              fontSize: iconSize * 0.8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        RoundedIconButton(
          icon: Icons.add,
          iconSize: iconSize,
          onPress: onIncrement,
        ),
      ],
    );
  }
}

class RoundedIconButton extends StatelessWidget {
  RoundedIconButton(
      {@required this.icon, @required this.onPress, @required this.iconSize});

  final IconData icon;
  final Function onPress;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: BoxConstraints.tightFor(width: iconSize, height: iconSize),
      //elevation: 6.0,
      onPressed: onPress,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(iconSize * 0.2)),
      fillColor: appColorPrimary,
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize * 0.8,
      ),
    );
  }
}
