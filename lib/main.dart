import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:chity/constants/app_constants.dart';
import 'package:chity/constants/app_colors.dart';
import 'package:chity/constants/app_strings.dart';
import 'package:chity/views/chat_view.dart';
import 'package:chity/views/home_view.dart';
import 'package:chity/views/login_view.dart';
import 'package:chity/views/my_profile_view.dart';
import 'package:chity/views/profile_view.dart';
import 'package:chity/views/register_view.dart';
import 'package:chity/views/request_view.dart';
import 'package:chity/views/search_view.dart';
import 'package:chity/views/splash_view.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Messaging
    final fcmToken = await FirebaseMessaging.instance.getToken();
    log("FCM Token: $fcmToken");

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    runApp(const ChityApp());
  } catch (e) {
    log("Error initializing Firebase: $e");
    runApp(const ChityApp());
  }
}

class ChityApp extends StatelessWidget {
  const ChityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routes: _buildRoutes(),
      initialRoute: AppConstants.splashRoute,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide:
              const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      AppConstants.splashRoute: (context) => const SplashScreen(),
      AppConstants.loginRoute: (context) => const LoginView(),
      AppConstants.registerRoute: (context) => const RegisterView(),
      AppConstants.homeRoute: (context) => const HomeView(),
      AppConstants.chatRoute: (context) => const ChatView(),
      AppConstants.searchRoute: (context) => const SearchView(),
      AppConstants.profileRoute: (context) => const ProfileView(),
      AppConstants.requestRoute: (context) => const RequestView(),
      AppConstants.myProfileRoute: (context) => const MyProfileView(),
    };
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    // Handle dynamic routes or arguments here if needed
    return null;
  }
}
