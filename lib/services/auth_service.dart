import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.rememberMeKey);
      await prefs.remove(AppConstants.userEmailKey);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Save user data to Firestore
  static Future<void> saveUserToFirestore({
    required UserModel user,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toJson());
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  // Get user data from Firestore
  static Future<UserModel?> getUserFromFirestore(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Get user by email
  static Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Update user data
  static Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Remember user login
  static Future<void> rememberUser(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.rememberMeKey, true);
      await prefs.setString(AppConstants.userEmailKey, email);
    } catch (e) {
      throw Exception('Failed to remember user: $e');
    }
  }

  // Check if user is remembered
  static Future<bool> isUserRemembered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.rememberMeKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get remembered user email
  static Future<String?> getRememberedUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.userEmailKey);
    } catch (e) {
      return null;
    }
  }

  // Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AppConstants.noUserFound;
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'The account already exists for that email';
      case 'weak-password':
        return 'The password provided is too weak';
      case 'invalid-email':
        return 'The email address is not valid';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'too-many-requests':
        return AppConstants.tooManyRequests;
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      default:
        return e.message ?? AppConstants.genericError;
    }
  }
}
