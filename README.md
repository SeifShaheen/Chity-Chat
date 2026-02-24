# Chity-Chat 💬

A modern, real-time chat application built with **Flutter** and **Firebase**. Chity-Chat lets users register, add friends, and exchange messages with real-time notifications.

## ✨ Features

- **Authentication** — Email & password sign-in/sign-up with Firebase Auth
- **Real-Time Messaging** — Instant chat powered by Cloud Firestore
- **Push Notifications** — FCM-based message notifications
- **Friend System** — Send, accept, and decline friend requests
- **User Profiles** — View and edit profiles, create posts, like posts
- **User Search** — Search for other users by username or email
- **Remember Me** — Persistent login via SharedPreferences
- **Dark Theme** — Modern dark UI with Material 3

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Notifications | Firebase Cloud Messaging (FCM) |
| Analytics | Firebase Analytics |
| Local Storage | SharedPreferences |
| HTTP Client | http package |
| Env Management | flutter_dotenv |

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point & theme configuration
├── firebase_options.dart      # Firebase config (reads from .env)
├── apis/
│   └── messages_api.dart      # FCM push notification API
├── constants/
│   ├── app_colors.dart        # Color palette
│   ├── app_constants.dart     # Route names, keys, UI constants
│   └── app_strings.dart       # UI text strings
├── helpers/
│   └── helpers.dart           # Utility functions
├── models/
│   ├── message_model.dart     # Message data model
│   └── user_model.dart        # User data model
├── services/
│   ├── auth_service.dart      # Authentication logic
│   ├── friend_service.dart    # Friend request management
│   ├── message_service.dart   # Chat message CRUD operations
│   └── profile_service.dart   # Profile & posts management
├── utils/
│   ├── error_handler.dart     # Error dialogs & snackbars
│   └── validators.dart        # Form validation logic
├── views/
│   ├── splash_view.dart       # Splash / loading screen
│   ├── login_view.dart        # Login screen
│   ├── register_view.dart     # Registration screen
│   ├── home_view.dart         # Home / friends list
│   ├── chat_view.dart         # Chat conversation screen
│   ├── search_view.dart       # User search screen
│   ├── profile_view.dart      # Other user's profile
│   ├── my_profile_view.dart   # Current user's profile
│   └── request_view.dart      # Friend requests screen
└── widgets/                   # Reusable UI components
    ├── chat_bubble.dart
    ├── custom_button.dart
    ├── custom_label.dart
    ├── custom_text_form_field.dart
    ├── friend_request.dart
    ├── loading_widget.dart
    ├── search_widget.dart
    ├── user_chat.dart
    └── already_have_an_accout.dart
```

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.4.1)
- A Firebase project set up at [Firebase Console](https://console.firebase.google.com/)
- Android Studio / VS Code with Flutter extensions

### Environment Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/SeifShaheen/Chity-Chat.git
   cd Chity-Chat
   ```

2. **Create your environment file**
   ```bash
   cp .env.example .env
   ```

3. **Fill in your Firebase credentials** in `.env`:
   ```env
   FIREBASE_WEB_API_KEY=your_web_api_key
   FIREBASE_ANDROID_API_KEY=your_android_api_key
   FIREBASE_IOS_API_KEY=your_ios_api_key
   # ... see .env.example for all required keys
   ```

   > You can find these values in your Firebase project settings under **General** and **Cloud Messaging** tabs.

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Setup

1. Create a new project in [Firebase Console](https://console.firebase.google.com/)
2. Enable **Email/Password** authentication in Authentication → Sign-in method
3. Create a **Cloud Firestore** database
4. Enable **Firebase Storage**
5. Enable **Cloud Messaging** for push notifications
6. Copy your project credentials into the `.env` file

## 🔒 Environment Variables

All sensitive configuration is stored in `.env` (git-ignored). See [.env.example](.env.example) for the full list of required variables:

| Variable | Description |
|----------|-------------|
| `FIREBASE_WEB_API_KEY` | Firebase API key for Web platform |
| `FIREBASE_ANDROID_API_KEY` | Firebase API key for Android platform |
| `FIREBASE_IOS_API_KEY` | Firebase API key for iOS/macOS platform |
| `FIREBASE_WEB_APP_ID` | Firebase App ID for Web |
| `FIREBASE_ANDROID_APP_ID` | Firebase App ID for Android |
| `FIREBASE_IOS_APP_ID` | Firebase App ID for iOS/macOS |
| `FIREBASE_WINDOWS_APP_ID` | Firebase App ID for Windows |
| `FIREBASE_MESSAGING_SENDER_ID` | FCM Sender ID |
| `FIREBASE_PROJECT_ID` | Firebase Project ID |
| `FIREBASE_AUTH_DOMAIN` | Firebase Auth Domain |
| `FIREBASE_STORAGE_BUCKET` | Firebase Storage Bucket |
| `FIREBASE_IOS_BUNDLE_ID` | iOS Bundle Identifier |
| `FCM_SERVER_KEY` | FCM Server Key for push notifications |

> ⚠️ **Never commit the `.env` file to version control.** It is already listed in `.gitignore`.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Copy `.env.example` to `.env` and fill in your credentials
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📄 License

This project is for educational purposes.
