import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/welcome_screen.dart';

SharedPreferences? prefs;
void main() async {
  WidgetsFlutterBinding();
  await Firebase.initializeApp();
  prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
        create: (_) => AuthProvider(), child: const FlashChat()),
  );
}

class FlashChat extends StatelessWidget {
  const FlashChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLogin = prefs!.getBool('isLogin')!;

    return MaterialApp(
      initialRoute: isLogin ? ChatScreen.id : WelcomeScreen.id,
      debugShowCheckedModeBanner: false,
      title: 'Private Chat',
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => const ChatScreen(),
      },
    );
  }
}
