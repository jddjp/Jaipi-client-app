import 'package:flutter/material.dart';
import 'package:jaipi/src/components/components.dart';
import 'package:jaipi/src/config/config.dart';
import 'package:jaipi/src/helpers/helpers.dart';
import 'package:jaipi/src/providers/providers.dart';
import 'package:jaipi/src/views/views.dart';
import 'package:provider/provider.dart';

final otpInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: spacing_middle),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(textSizeMedium),
    borderSide: BorderSide(color: textPrimaryColor),
  );
}

class OPTView extends StatefulWidget {
  static const routeName = 'opt';

  final Map<String, dynamic> phoneData;

  OPTView({Key key, this.phoneData}) : super(key: key);

  @override
  _OPTViewState createState() => _OPTViewState();
}

class _OPTViewState extends State<OPTView> {
  // Form vars
  final _formKey = GlobalKey<FormState>();
  String smsCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing_standard_new),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 80.0),
                text("Verificación", fontSize: textSizeNormal),
                Text("Enviamos un código a +52 " +
                    widget.phoneData['phoneNumber']),
                buildTimer(), // TODO: Funcionality of time
                buildOPTForm(context, widget.phoneData['verificationId']),
                SizedBox(height: 80.0),
                GestureDetector(
                  onTap: () {
                    // OTP code resend
                  },
                  child: Text(
                    "No recibí el código",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Form buildOPTForm(BuildContext context, String verificationId) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 80.0),
          Container(
              margin: EdgeInsets.only(
                  left: spacing_standard_new, right: spacing_standard_new),
              child: TextFormField(
                maxLength: 6,
                keyboardType: TextInputType.phone,
                autofocus: true,
                onSaved: (value) => smsCode = value,
                validator: (value) {
                  Pattern pattern = r'^[0-9]{6}$';
                  RegExp regex = new RegExp(pattern);
                  if (value.isEmpty) {
                    return "Ingresa el código de verificación";
                  }
                  if (!regex.hasMatch(value)) {
                    return "Ingresa un código válido";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Código de verificación",
                  hintText: "Ingresa el código que te llegó",
                  // If  you are using latest version of flutter then lable text and hint text shown like this
                  // if you r using flutter less then 1.20.* then maybe this is not working properly
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
                ),
              )),
          SizedBox(height: spacing_large),
          Container(
            margin: EdgeInsets.only(
                left: spacing_standard_new, right: spacing_standard_new),
            child: DefaultButton(
              text: "Continuar",
              press: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();

                  // Save phoneNumber on App Global State
                  Provider.of<LoginProvider>(context, listen: false)
                      .signInWithPhone(
                          verificationId: verificationId, smsCode: smsCode)
                      .then((o) {
                    // Redirect
                    if (!Provider.of<LoginProvider>(context, listen: false)
                        .isCompleted()) {
                      launchScreen(context, CompleteProfileView.routeName);
                    } else {
                      launchScreen(context, HomeView.routeName);
                    }
                  });
                }
              },
            ),
          ),
          SizedBox(height: 100.0)
        ],
      ),
    );
  }

  Row buildTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Este código caducará en "),
        TweenAnimationBuilder(
          tween: Tween(begin: 59.0, end: 0.0),
          duration: Duration(seconds: 59),
          builder: (_, value, child) => Text(
            "00:${value.toInt()}",
            style: TextStyle(color: appColorAccent),
          ),
        ),
      ],
    );
  }
}
