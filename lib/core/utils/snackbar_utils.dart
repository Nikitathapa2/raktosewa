import 'package:flutter/material.dart';

class SnackbarUtils {
  /// Show success snackbar with green background
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error snackbar with red background
  static void showError(BuildContext context, String message) {
    // Remove "Exception:" prefix if present
    final cleanMessage = message.replaceFirst('Exception: ', '');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cleanMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show warning/info snackbar with yellow/amber background
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.amber,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Generic snackbar with custom color
  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.grey,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }
}
