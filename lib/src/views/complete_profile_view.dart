import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jaipi/src/components/default_button.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/providers/login_provider.dart';
import 'package:jaipi/src/views/home_view.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';

class CompleteProfileView extends StatefulWidget {
  static const routeName = 'complete_profile';

  @override
  _CompleteProfileViewState createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];

  String name;
  String phoneNumber;
  String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: context.watch<LoginProvider>().currentUser == null,
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing_standard_new),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 40.0),
                    text("Completar perfil", fontSize: textSizeNormal),
                    Text(
                      "Completa tus datos para poder continuar",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 45.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildNameFormField(context
                              .watch<LoginProvider>()
                              .currentUser['name']),
                          SizedBox(height: spacing_large),
                          buildPhoneNumberFormField(context
                              .watch<LoginProvider>()
                              .currentUser['phone']),
                          SizedBox(height: spacing_large),
                          buildEmailFormField(context
                              .watch<LoginProvider>()
                              .currentUser['email']),
                          SizedBox(height: 40.0),
                          DefaultButton(
                            text: "Continuar",
                            press: () async {
                              if (_formKey.currentState.validate()) {
                                _formKey.currentState.save();

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(context
                                        .read<LoginProvider>()
                                        .currentUser['id'])
                                    .update({
                                  'name': name,
                                  'phone': phoneNumber,
                                  'email': email,
                                  'completed': true,
                                  'updated_at': FieldValue.serverTimestamp()
                                });

                                Provider.of<LoginProvider>(context,
                                        listen: false)
                                    .updateLoginSatate()
                                    .then((value) {
                                  // Redirect and remove all screens
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      HomeView.routeName, (route) => false);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing_large),
                    Text(
                      "Al continuar, confirmas que está de acuerdo \ncon nuestros Términos y condiciones",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.caption,
                    ),
                    SizedBox(height: 80.0),
                    GestureDetector(
                      onTap: () {
                        context.read<LoginProvider>().logout();
                      },
                      child: Text(
                        "Cerrar sesión",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildNameFormField(defaultName) {
    return TextFormField(
      onSaved: (newValue) => name = newValue,
      initialValue: defaultName,
      autofocus: true,
      validator: (value) {
        if (value.isEmpty) {
          return "Por favor ingresa tu nombre";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Nombre",
        hintText: "Ingresa tu nombre completo",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildPhoneNumberFormField(String defaultValue) {
    return TextFormField(
      keyboardType: TextInputType.phone,
      initialValue: defaultValue,
      readOnly: defaultValue != null,
      onSaved: (newValue) => phoneNumber = newValue,
      validator: (value) {
        Pattern pattern = r'^[0-9]{10}$';
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
        hintText: "Ingresa tu número de teléfono",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField(String defaultValue) {
    return TextFormField(
      initialValue: defaultValue,
      onSaved: (newValue) => email = newValue,
      decoration: InputDecoration(
        labelText: "Correo electrónico",
        hintText: "Ingresa tu correo electrónico",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }
}
