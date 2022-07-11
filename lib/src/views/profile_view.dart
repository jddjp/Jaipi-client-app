import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jaipi/src/components/default_button.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/providers/login_provider.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/views/home_view.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  static const routeName = 'profile';

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];

  String name;
  String phoneNumber;
  String email;

  @override
  Widget build(BuildContext context) {
    changeStatusColor(appColorPrimary);
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: text('Perfil', textColor: whiteColor),
        backgroundColor: appColorPrimary,
      ),
      backgroundColor: food_white,
      body: SafeArea(
          child: Container(
              margin: EdgeInsets.all(spacing_standard_new),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    context.watch<LoginProvider>().currentUser['photo']
                                ['url'] ==
                            null
                        ? CircleAvatar(
                            radius: width * 0.15,
                            child: Image.asset('assets/images/jaipi.png'),
                          )
                        : CircleAvatar(
                            radius: width * 0.15,
                            backgroundImage: CachedNetworkImageProvider(context
                                .watch<LoginProvider>()
                                .currentUser['photo']['url'])),
                    SizedBox(height: spacing_standard_new),
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
                          SizedBox(height: spacing_large),
                          DefaultButton(
                            text: "Guardar cambios",
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
                                  Fluttertoast.showToast(
                                      msg: "Tu información fue actualizada.");
                                  back(context);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))),
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
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        filled: true,
        fillColor: food_white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(color: food_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(color: food_view_color, width: 1.0)),
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
      //readOnly: defaultValue != null,
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
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        filled: true,
        fillColor: food_white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(color: food_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(color: food_view_color, width: 1.0)),
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
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        filled: true,
        fillColor: food_white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(color: food_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(color: food_view_color, width: 1.0)),
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }
}
