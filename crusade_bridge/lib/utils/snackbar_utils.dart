import 'package:flutter/material.dart';
import '../models/app_settings.dart';

/// Utility class for showing consistent SnackBars throughout the app
class SnackBarUtils {
  /// Shows a SnackBar with customizable settings
  static void showMessage(
    BuildContext context,
    String message, {
    AppSettings? settings,
    IconData? icon,
  }) {
    final duration = settings?.snackBarDurationSeconds ?? 2;
    final showIcon = settings?.snackBarShowIcon ?? false;
    final backgroundColor = settings?.snackBarInfoColor;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (showIcon && icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        duration: Duration(seconds: duration),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Shows an error SnackBar with red background
  static void showError(
    BuildContext context,
    String message, {
    AppSettings? settings,
  }) {
    final duration = settings?.snackBarDurationSeconds ?? 2;
    final showIcon = settings?.snackBarShowIcon ?? false;
    final backgroundColor = settings?.snackBarErrorColor ?? Colors.red[700];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (showIcon) ...[
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        duration: Duration(seconds: duration),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Shows a success SnackBar with green background
  static void showSuccess(
    BuildContext context,
    String message, {
    AppSettings? settings,
  }) {
    final duration = settings?.snackBarDurationSeconds ?? 2;
    final showIcon = settings?.snackBarShowIcon ?? false;
    final backgroundColor = settings?.snackBarSuccessColor ?? Colors.green[700];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (showIcon) ...[
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        duration: Duration(seconds: duration),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
