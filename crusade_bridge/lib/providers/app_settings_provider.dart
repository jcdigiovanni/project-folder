import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

import '../models/app_settings.dart';

/// Notifier for managing app settings
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(AppSettings.defaults()) {
    _loadSettings();
  }

  static const String _boxName = 'app_settings_box';
  static const String _settingsKey = 'app_settings';

  /// Load settings from persistent storage
  Future<void> _loadSettings() async {
    try {
      final box = await Hive.openBox(_boxName);
      final settingsJson = box.get(_settingsKey) as String?;

      if (settingsJson != null) {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        state = AppSettings.fromJson(json);
      }
    } catch (e) {
      // If loading fails, keep default settings
      state = AppSettings.defaults();
    }
  }

  /// Save settings to persistent storage
  Future<void> _saveSettings() async {
    try {
      final box = await Hive.openBox(_boxName);
      final settingsJson = jsonEncode(state.toJson());
      await box.put(_settingsKey, settingsJson);
    } catch (e) {
      // Silently fail - settings will be lost but app continues to work
    }
  }

  /// Update snackbar duration
  Future<void> setSnackBarDuration(int seconds) async {
    state = state.copyWith(snackBarDurationSeconds: seconds);
    await _saveSettings();
  }

  /// Update settings
  Future<void> updateSettings(AppSettings newSettings) async {
    state = newSettings;
    await _saveSettings();
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    state = AppSettings.defaults();
    await _saveSettings();
  }
}

/// Global provider for app settings
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(),
);
