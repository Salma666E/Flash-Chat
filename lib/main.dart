import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/utilty.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding();
  await Firebase.initializeApp();
  await CashHelper.init();
  runApp(
    ChangeNotifierProvider(
        create: (_) => AuthProvider()..getShared(), child: const FlashChat()),
  );
}

class FlashChat extends StatelessWidget {
  const FlashChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: (CashHelper.pref.getBool('isLogin') == true)
          ? ChatScreen.id
          : WelcomeScreen.id,
      debugShowCheckedModeBanner: false,
      title: 'Private Chat',
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}
