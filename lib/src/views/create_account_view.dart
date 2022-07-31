import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jaipi/src/components/components.dart';
import 'package:jaipi/src/config/config.dart';
import 'package:jaipi/src/helpers/helpers.dart';
import 'package:jaipi/src/providers/providers.dart';
import 'package:jaipi/src/views/views.dart';
import 'package:provider/provider.dart';

class CreateAccountView extends StatefulWidget {
  static const routeName = 'create_acount';

  @override
  _CreateAccountViewState createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];
  String phoneNumber;

  final _codeController = TextEditingController();

  Future<bool> loginPhoneNumber(BuildContext context, String phone) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: "+52$phone",
        verificationCompleted: (AuthCredential credential) async {
          // ANDROID ONLY!
          Navigator.of(context).pop();

          UserCredential userCredential =
              await _auth.signInWithCredential(credential);

          Provider.of<LoginProvider>(context, listen: false)
              .afterSignIn(userCredential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("verificationFailed");
          print(e);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          launchScreen(context, OPTView.routeName, arguments: {
            'phoneNumber': phoneNumber,
            'verificationId': verificationId
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("retrieval");
        },
        timeout: Duration(seconds: 60));
  }

  @override
  Widget build(BuildContext context) {
    //changeStatusColor(whiteColor);

    var width = MediaQuery.of(context).size.width;

    var mLabel = Container(
      margin: EdgeInsets.only(
          left: spacing_standard_new, right: spacing_standard_new),
      child: text("¿Cuál es tu número de teléfono?",
          fontWeight: fontBold, isLongText: true, fontSize: textSizeNormal),
    );

    var mSubLabel = Container(
      margin: EdgeInsets.only(
          left: spacing_standard_new, right: spacing_standard_new),
      child: text(
          "Tu número no se almacenará ni usará como método de contacto hasta que te registres y aceptes nuestros Términos y Condiciones y Política de privacidad.",
          isLongText: true,
          textColor: textSecondaryColor,
          fontSize: textSizeSmall),
    );

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: width,
              alignment: Alignment.topLeft,
              color: whiteColor,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  back(context);
                },
              ),
            ),
            SizedBox(height: spacing_standard_new),
            mLabel,
            mSubLabel,
            SizedBox(height: 30.0),
            Form(
              key: _formKey,
              child: buildPhoneNumberFormField(),
            ),
            SizedBox(height: spacing_large),
            Expanded(
              child: Container(),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: spacing_standard_new, right: spacing_standard_new),
              child: DefaultButton(
                text: "Continuar",
                press: () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();

                    // Save phoneNumber on App Global State
                    //await context.read<LoginProvider>().verifyPhoneNumber(phoneNumber, context);
                    Provider.of<LoginProvider>(context, listen: false)
                        .verifyPhoneNumber(phoneNumber, context);
                    //loginPhoneNumber(context, phoneNumber);
                  }
                },
              ),
            ),
            SizedBox(height: spacing_large),
          ],
        ),
      ),
    );
  }

  Widget buildPhoneNumberFormField() {
    return Container(
        margin: EdgeInsets.only(
            left: spacing_standard_new, right: spacing_standard_new),
        child: TextFormField(
          keyboardType: TextInputType.phone,
          autofocus: true,
          onSaved: (newValue) => phoneNumber = newValue,
          validator: (value) {
            Pattern pattern = r'^(?:[+0]9)?[0-9]{10}$';
            RegExp regex = new RegExp(pattern);
            if (value.isEmpty) {
              return "Ingresa tu número de teléfono";
            }
            if (!regex.hasMatch(value)) {
              return "Ingresa un número a 10 dígitos válido";
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: "Número de teléfono",
            hintText: "¿Cuál es tu número de teléfono?",
            // If  you are using latest version of flutter then lable text and hint text shown like this
            // if you r using flutter less then 1.20.* then maybe this is not working properly
            floatingLabelBehavior: FloatingLabelBehavior.always,
            //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
          ),
        ));
  }
}
