import 'dart:developer';

import 'package:chity/views/chat_view.dart';
import 'package:chity/views/home_view.dart';
import 'package:chity/views/login_view.dart';
import 'package:chity/views/my_profile_view.dart';
import 'package:chity/views/profile_view.dart';
import 'package:chity/views/register_view.dart';
import 'package:chity/views/request_view.dart';
import 'package:chity/views/search_view.dart';
import 'package:chity/views/splash_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken();

  log(fcmToken.toString());
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const Chity());
}

class Chity extends StatelessWidget {
  const Chity({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        LoginView.id: (context) => const LoginView(),
        RegisterView.id: (context) => const RegisterView(),
        HomeView.id: (context) => const HomeView(),
        ChatView.id: (context) => const ChatView(),
        SplashScreen.id: (context) => const SplashScreen(),
        SearchView.id: (context) => const SearchView(),
        ProfileView.id: (context) => const ProfileView(),
        RequestView.id: (context) => const RequestView(),
        MyProfileView.id: (context) => const MyProfileView(),
      },
      initialRoute: SplashScreen.id,
    );
  }
}
