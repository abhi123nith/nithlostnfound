import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nithlostnfound/Pages/HomePage/homepage.dart';
import 'package:nithlostnfound/Pages/LoginPage/login_page.dart';
import 'package:nithlostnfound/Pages/Setting/setting_page.dart';

import 'Widgets/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  PaintingBinding.instance.imageCache.clear();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lost and Found',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(), // Use AuthWrapper to decide the start screen
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is signed in
    User? user = FirebaseAuth.instance.currentUser;

    // If the user is signed in, navigate to HomePage, otherwise navigate to LoginPage
    if (user != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
