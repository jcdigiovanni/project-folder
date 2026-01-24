import 'package:flutter/material.dart';

/// App-wide settings and preferences
class AppSettings {
  final int snackBarDurationSeconds;
  final Color? snackBarSuccessColor;
  final Color? snackBarErrorColor;
  final Color? snackBarInfoColor;
  final bool snackBarShowIcon;

  const AppSettings({
    this.snackBarDurationSeconds = 2,
    this.snackBarSuccessColor,
    this.snackBarErrorColor,
    this.snackBarInfoColor,
    this.snackBarShowIcon = false,
  });

  AppSettings copyWith({
    int? snackBarDurationSeconds,
    Color? snackBarSuccessColor,
    Color? snackBarErrorColor,
    Color? snackBarInfoColor,
    bool? snackBarShowIcon,
  }) {
    return AppSettings(
      snackBarDurationSeconds: snackBarDurationSeconds ?? this.snackBarDurationSeconds,
      snackBarSuccessColor: snackBarSuccessColor ?? this.snackBarSuccessColor,
      snackBarErrorColor: snackBarErrorColor ?? this.snackBarErrorColor,
      snackBarInfoColor: snackBarInfoColor ?? this.snackBarInfoColor,
      snackBarShowIcon: snackBarShowIcon ?? this.snackBarShowIcon,
    );
  }

  /// Default app settings
  factory AppSettings.defaults() {
    return const AppSettings(
      snackBarDurationSeconds: 2,
      snackBarShowIcon: false,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'snackBarDurationSeconds': snackBarDurationSeconds,
      'snackBarSuccessColor': snackBarSuccessColor?.toARGB32(),
      'snackBarErrorColor': snackBarErrorColor?.toARGB32(),
      'snackBarInfoColor': snackBarInfoColor?.toARGB32(),
      'snackBarShowIcon': snackBarShowIcon,
    };
  }

  /// Create from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      snackBarDurationSeconds: json['snackBarDurationSeconds'] as int? ?? 2,
      snackBarSuccessColor: json['snackBarSuccessColor'] != null
          ? Color(json['snackBarSuccessColor'] as int)
          : null,
      snackBarErrorColor: json['snackBarErrorColor'] != null
          ? Color(json['snackBarErrorColor'] as int)
          : null,
      snackBarInfoColor: json['snackBarInfoColor'] != null
          ? Color(json['snackBarInfoColor'] as int)
          : null,
      snackBarShowIcon: json['snackBarShowIcon'] as bool? ?? false,
    );
  }
}
