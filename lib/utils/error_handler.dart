import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

class ErrorHandler {
  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: AppStrings.ok,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show error dialog
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text(AppStrings.retry),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  // Show confirmation dialog
  static void showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = AppStrings.yes,
    String cancelText = AppStrings.no,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Handle Firebase Auth exceptions
  static String handleFirebaseAuthException(String errorCode) {
    switch (errorCode) {
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
      case 'network-request-failed':
        return AppConstants.networkError;
      default:
        return AppConstants.genericError;
    }
  }

  // Handle generic exceptions
  static String handleGenericException(dynamic error) {
    if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return AppConstants.networkError;
    }

    if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (error.toString().contains('permission')) {
      return 'Permission denied. Please check your settings.';
    }

    return AppConstants.genericError;
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? AppStrings.loading),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show bottom sheet with error
  static void showErrorBottomSheet(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 16),
            Row(
              children: [
                if (onRetry != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRetry();
                      },
                      child: const Text(AppStrings.retry),
                    ),
                  ),
                if (onRetry != null) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(AppStrings.ok),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
