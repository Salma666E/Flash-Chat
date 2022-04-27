import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/utilty.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';
import '../components/rounded_button.dart';
import '../components/rounded_textfield.dart';
import 'chat_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String id = 'login_screen';

  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  late String name;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final providerWatch = Provider.of<AuthProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: Hero(
                tag: 'logo',
                child: SizedBox(
                  height: 150.0,
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
            ),
            const SizedBox(
              height: 48.0,
            ),
            RoundedTextField(
                hint: 'name',
                onChangedFunction: (value) {
                  name = value;
                }),
            const SizedBox(
              height: 8.0,
            ),
            RoundedTextField(
                hint: 'email',
                myKeyboardType: TextInputType.emailAddress,
                onChangedFunction: (value) {
                  email = value;
                }),
            const SizedBox(
              height: 8.0,
            ),
            RoundedTextField(
                hint: 'password',
                obscureText: true,
                onChangedFunction: (value) {
                  password = value;
                }),
            const SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              title: 'Login with Email',
              colour: Colors.blueAccent,
              onPressed: () async {
                try {
                  final user = await _auth.signInWithEmailAndPassword(
                      email: email, password: password);
                  providerWatch.prefs!.setString('name', name);
                  providerWatch.prefs!.setString('email', email);
                  if (user != null) {
                    providerWatch.prefs!.setBool('isLogin', true);
                    Navigator.pushNamed(context, ChatScreen.id);
                  }
                } catch (e) {
                  showAlertDialog(
                      context, "An error occurred while logging in");
                }
              },
            ),
            RoundedButton(
              title: 'Login with Google',
              colour: Colors.lightBlueAccent,
              onPressed: () async {
                try {
                  final user = await provider.googleLogin();
                  if (user != null) {
                    providerWatch.prefs!.setBool('isLogin', true);
                    Navigator.pushNamed(context, ChatScreen.id);
                  }
                } catch (e) {
                  showAlertDialog(
                      context, "An error occurred while logging in");
                }
              },
            ),
            RoundedButton(
              title: 'Login with Facebook',
              colour: Colors.lightBlueAccent,
              onPressed: () async {
                try {
                  final user = await provider.facebookLogin();

                  if (user != null) {
                    providerWatch.prefs!.setBool('isLogin', true);
                    Navigator.pushNamed(context, ChatScreen.id);
                  }
                } catch (e) {
                  showAlertDialog(
                      context, "An error occurred while logging in");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
