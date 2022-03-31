import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;
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
      log('userCredential: ' + userCredential.user!.toString());
      notifyListeners();
      return result;
    } else {
      print('Error in Login by facebook');
      notifyListeners();
    }
  }

  logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
