import 'dart:convert';
import 'dart:math';
// import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/views/opt_view.dart';
import 'package:jaipi/src/views/complete_profile_view.dart';
import 'package:jaipi/src/views/home_view.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

/// Generates a cryptographically secure random nonce, to be included in a
/// credential request.
String generateNonce([int length = 32]) {
  final charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class LoginProvider with ChangeNotifier {
  FirebaseAuth _auth;
  SharedPreferences _prefs;
  Map<String, dynamic> _currentUser;

  bool _loggedIn = false;
  bool _loading = false;
  bool _loadingCurrentUser = true;

  // Public access to current user data
  Map<String, dynamic> get currentUser => _currentUser;

  LoginProvider() {
    // Initialize App Provider
    initAppProvider();

    // Check for login state
    checkLoginState();
  }

  void initAppProvider() async {
    _prefs = await SharedPreferences.getInstance();
    _auth = FirebaseAuth.instance;
  }

  bool isLoggedIn() => _loggedIn;
  bool isLoading() => _loading;
  bool isLoadingCurrentUser() => _loadingCurrentUser;

  bool isCompleted() =>
      _currentUser != null ? _currentUser['completed'] == true : false;

  // Main login function
  Future<dynamic> login(String type) async {
    _loading = true;
    notifyListeners();

    final AuthResult result = type == 'google'
        ? await signInWithGoogle()
        : (type == 'apple'
            ? await signInWithApple()
            : await signInWithFacebook());

    if (result.status == AuthResult.ok) {
      try {
        UserCredential userCredential =
            await _auth.signInWithCredential(result.credential);
        return afterSignIn(userCredential);
      } on FirebaseAuthException catch (e) {
        print(e);
      }
    } else if (result.status == AuthResult.cancelled) {
      Fluttertoast.showToast(msg: "Haz cancelado el inicio de sesión");
    } else {
      Fluttertoast.showToast(
          msg: "Ocurrió un error, inténtalo más tarde\n${result.message}");
    }

    _loading = false;
    notifyListeners();

    return Future.error("not loggedin");
  }

  // TODO: Testing alternative
  // void loginFacebook() async {
  //   _loading = true;
  //   notifyListeners();

  //   // Present the dialog to the user
  //   final result = await FlutterWebAuth.authenticate(
  //       url: "https://hermez-delivery--hermez-r7efb7dk.web.app",
  //       callbackUrlScheme: "hermez");

  //   // Extract status from resulting url
  //   final params = Uri.parse(result).queryParameters;
  //   final status = int.parse(params['status']);

  //   // Success
  //   if (status == AuthResult.ok) {
  //     final uid = params['uid'];
  //     // Save UID on device
  //     _prefs.setString('uid', uid);
  //     await checkLoginState();
  //   }

  //   _loading = false;
  //   notifyListeners();
  // }

  Future<void> afterSignIn(UserCredential userCredential) async {
    _loadingCurrentUser = true;
    notifyListeners();
    // Register in firestore if is a new user
    if (userCredential.additionalUserInfo.isNewUser) {
      print("IS NEW USER %%%%%%%%%%");
      User _userData = userCredential.user;
      // Validate phoneNumber
      String phoneNumber = _userData.phoneNumber;
      if (phoneNumber != null && phoneNumber.startsWith("+52")) {
        phoneNumber = phoneNumber.replaceAll("+", "").replaceFirst("52", "");
      }
      // Save new user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userData.uid)
          .set({
        'name': _userData.displayName != null
            ? _userData.displayName
            : 'Apple User',
        'email': _userData.email,
        'phone': phoneNumber,
        'photo': {'path': null, 'url': _userData.photoURL},
        'active': true,
        'completed': false, // We required that user complete their profile
        'type': 'client',
        'group': 'production',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp()
      });
    } else {
      print("USER EXISTS %%%%%%%%%%%%");
    }

    // Save UID on device
    _prefs.setString('uid', userCredential.user.uid);
    await checkLoginState();

    return Future.value();
  }

  Future<AuthResult> signInWithGoogle() async {
    GoogleSignInAccount result;
    // Trigger the authentication flow
    try {
      result =
          await GoogleSignIn().signIn().catchError((onError) => print(onError));
    } on PlatformException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    // Canceled authentication
    if (result == null) return AuthResult(status: AuthResult.cancelled);

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await result.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return AuthResult(status: AuthResult.ok, credential: credential);
  }

  // Facebook login
  Future<AuthResult> signInWithFacebook() async {
    String message = "";
    try {
      // by default the login method has the next permissions ['email','public_profile']
      AccessToken accessToken = await FacebookAuth.instance.login();
      // get the user data
      //final userData = await FacebookAuth.instance.getUserData();
      //print(userData);
      FacebookAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken.token);

      return AuthResult(
          status: AuthResult.ok, credential: facebookAuthCredential);
    } on FacebookAuthException catch (e) {
      print(e.message);
      message = "${e.message}-${e.errorCode}";
      switch (e.errorCode) {
        case FacebookAuthErrorCode.OPERATION_IN_PROGRESS:
          print("You have a previous login operation in progress");
          break;
        case FacebookAuthErrorCode.CANCELLED:
          print("login cancelled");
          break;
        case FacebookAuthErrorCode.FAILED:
          print("login failed");
          break;
      }
    }

    return AuthResult(status: 500, credential: null, message: message);
  }

  Future<AuthResult> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    var appleCredential;
    var oauthCredential;

    // Request credential for the currently signed in Apple account.
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
    } on PlatformException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    // Canceled authentication
    if (oauthCredential == null)
      return AuthResult(status: AuthResult.cancelled);

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return AuthResult(status: AuthResult.ok, credential: oauthCredential);
  }

  // SignIn With phone
  Future<void> signInWithPhone({String verificationId, String smsCode}) async {
    _loading = true;
    notifyListeners();

    PhoneAuthCredential phoneAuthCredential;
    try {
      phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      // Sign the user in (or link) with the credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);

      await afterSignIn(userCredential);

      return Future.value();
    } on PlatformException catch (err) {
      print(err);
    } catch (err) {
      print(err);
    }

    _loading = false;
    notifyListeners();
  }

  // Phone number authentication
  Future verifyPhoneNumber(String phoneNumber, BuildContext context) {
    return _auth.verifyPhoneNumber(
        phoneNumber: "+52$phoneNumber",
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          // ANDROID ONLY!
          UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          //
          await afterSignIn(userCredential);

          if (!Provider.of<LoginProvider>(context, listen: false)
              .isCompleted()) {
            launchScreen(context, CompleteProfileView.routeName);
          } else {
            launchScreen(context, HomeView.routeName);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e);
          return "error";
        },
        codeSent: (String verificationId, int resendToken) {
          launchScreen(context, OPTView.routeName, arguments: {
            'phoneNumber': phoneNumber,
            'verificationId': verificationId
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("retrieval");
        });
  }

  /// Check login status // cookies
  Future<void> checkLoginState() async {
    // Create instance if not initialized
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();

    // Get logged user data
    if (_prefs.getString('uid') != null) {
      if (_prefs.getString('userData') == null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_prefs.getString('uid'))
            .get();

        if (userDoc.exists) {
          _currentUser = {...userDoc.data(), "id": userDoc.id};
          _prefs.setString(
              'userData',
              jsonEncode({
                ..._currentUser,
                "created_at":
                    DateFormat().format(_currentUser['created_at'].toDate()),
                "updated_at":
                    DateFormat().format(_currentUser['updated_at'].toDate())
              }));
        } else {
          print("userDoc not exists %%%%%%%");
        }
      } else {
        _currentUser = jsonDecode(_prefs.getString('userData'));
        print(_currentUser);
        print("User already exists %%%%%");
      }

      print("SET LOGGEDIN %%%%%%");
      _loggedIn = true;
    } else {
      print("UID NOT FOUND %%%%%%");
    }

    // Loading and login
    _loading = false;
    _loadingCurrentUser = false;
    notifyListeners();

    // Promise
    return Future.value();
  }

  Future<void> updateLoginSatate() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_prefs.getString('uid'))
        .get();
    _currentUser = {...userDoc.data(), "id": userDoc.id};
    _prefs.setString(
        'userData',
        jsonEncode({
          ..._currentUser,
          "created_at":
              DateFormat().format(_currentUser['created_at'].toDate()),
          "updated_at": DateFormat().format(_currentUser['updated_at'].toDate())
        }));

    // Loading and login
    _loading = false;
    _loadingCurrentUser = false;
    notifyListeners();

    // Promise
    return Future.value();
  }

  Future<void> saveTokenToDatabase(String token) async {
    // Create instance if not initialized
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();

    // Assume user is logged in for this example
    String deviceToken = _prefs.getString('device_token');
    String userId = _prefs.getString('uid');

    // User not logged
    if (userId == null || _currentUser == null || deviceToken != null) return;

    print("Saving token $token to database");

    _prefs.setString('device_token', token);

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }

  // Close sessión
  void logout() async {
    _loading = true;
    notifyListeners();

    // Clear device data
    _prefs.clear();

    // Close auth session
    await _auth.signOut();

    // local variables
    _loggedIn = false;
    _currentUser = null;
    _loading = false;
    notifyListeners();
  }
}

class AuthResult {
  // status codes
  static const ok = 200;
  static const cancelled = 403;
  static const error = 500;

  final int status;
  final AuthCredential credential;
  final String message;

  AuthResult({this.status, this.credential, this.message = "success"});

  AuthCredential getCredential() => this.credential;
}
