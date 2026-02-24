// ignore_for_file: use_build_context_synchronously

import 'package:chity/views/home_view.dart';
import 'package:chity/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static String id = "splashId";
  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkRememberedUser();
  }

  Future<void> _checkRememberedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? rememberMe = prefs.getBool('rememberMe');
    String? userEmail = prefs.getString('userEmail');

    if (rememberMe == true && userEmail != null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacementNamed(context, HomeView.id,
            arguments: userEmail);
      } else {
        Navigator.pushReplacementNamed(context, LoginView.id);
      }
    } else {
      Navigator.pushReplacementNamed(context, LoginView.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
