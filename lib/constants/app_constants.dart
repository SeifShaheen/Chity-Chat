class AppConstants {
  // App Information
  static const String appName = 'Chity-Chat';
  static const String appVersion = '1.0.0';

  // Colors
  static const int primaryColorValue = 0xff005073;
  static const int secondaryColorValue = 0xff189ad3;

  // Route Names
  static const String splashRoute = 'splashId';
  static const String loginRoute = 'LoginId';
  static const String registerRoute = 'RegisterId';
  static const String homeRoute = 'homeId';
  static const String chatRoute = 'ChatId';
  static const String searchRoute = 'SearchId';
  static const String profileRoute = 'ProfileId';
  static const String requestRoute = 'RequestId';
  static const String myProfileRoute = 'MyProfileId';

  // SharedPreferences Keys
  static const String rememberMeKey = 'rememberMe';
  static const String userEmailKey = 'userEmail';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String messagesCollection = 'messages';

  // Validation Messages
  static const String emailRequired = 'Please Enter Email';
  static const String passwordRequired = 'Please Enter Password';
  static const String nameRequired = 'Please Enter Name';
  static const String usernameRequired = 'Please Enter Username';
  static const String invalidEmail = 'Please Enter Valid Email';
  static const String passwordTooShort =
      'Password must be at least 6 characters';

  // Error Messages
  static const String genericError =
      'There was an error please try again later!';
  static const String noUserFound = 'No user found for that email.';
  static const String tooManyRequests =
      'Too many requests please try again later!';
  static const String networkError = 'Please check your internet connection';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Registration successful';
  static const String logoutSuccess = 'Logged out successfully';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
