import 'package:flutter/services.dart';

/// Shared input formatters for text fields throughout the app.
///
/// Prevents control characters (which can corrupt JSON/display) and
/// enforces reasonable length limits. Apostrophes, quotes, and other
/// printable characters are deliberately allowed — Warhammer names
/// are full of them (e.g., Blood Raven's Chapter Master Titus "The Bold").

/// For single-line name fields (crusade name, unit name, group name, etc.).
/// Max 100 chars, strips all control characters.
final nameFormatters = <TextInputFormatter>[
  LengthLimitingTextInputFormatter(100),
  FilteringTextInputFormatter.deny(RegExp(r'[\x00-\x1F\x7F]')),
];

/// For multi-line notes/description fields.
/// Max 2000 chars, allows newlines but strips other control characters.
final notesFormatters = <TextInputFormatter>[
  LengthLimitingTextInputFormatter(2000),
  FilteringTextInputFormatter.deny(
      RegExp(r'[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]')),
];

/// For numeric score fields.
/// Digits only, max 4 chars.
final numericFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(4),
];
