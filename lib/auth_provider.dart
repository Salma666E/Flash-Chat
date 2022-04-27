import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;
  SharedPreferences? prefs;
  getShared() async {
    prefs = await SharedPreferences.getInstance();
    notifyListeners();
  }

  googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      prefs!.setString('name', _user!.displayName.toString());
      prefs!.setString('email', _user!.email.toString());
      notifyListeners();
      return googleUser;
    } catch (e) {
      print(e);
      notifyListeners();
    }
  }

  facebookLogin() async {
    final result =
        await FacebookAuth.i.login(permissions: ["public_profile", "email"]);
    log('result: ' + result.accessToken.toString());
    if (result.status == LoginStatus.success) {
      final AuthCredential facebookCredential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(facebookCredential);
      prefs!.setString('name', userCredential.user!.displayName.toString());
      prefs!.setString('email', userCredential.user!.email.toString());
      notifyListeners();
      return result;
    } else {
      print('Error in Login by facebook');
      notifyListeners();
    }
  }

  logout(context) async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
    prefs!.remove('isLogin');
    prefs!.remove('name');
    prefs!.remove('email');
    Navigator.pushNamed(context, WelcomeScreen.id);
  }
}
