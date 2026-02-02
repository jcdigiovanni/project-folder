import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0A0A0A),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFC2185B), // Magenta-pink primary
    brightness: Brightness.dark,
  ),
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.inter(
      fontSize: 16,
      color: Colors.grey[300],
      height: 1.5,
    ),
    headlineMedium: GoogleFonts.greatVibes(
      fontSize: 48,  // Increased from 36 → bigger presence
      color: const Color(0xFFFFB6C1), // Pastel pink
      fontWeight: FontWeight.w900,  // Maximum weight for thickness (if font supports it)
      letterSpacing: 2.0,  // Slight spread for drama
      shadows: [
        Shadow(
          blurRadius: 6,
          color: Colors.black.withOpacity(0.8),
          offset: const Offset(2, 2),
        ),
        Shadow(
          blurRadius: 12,
          color: const Color(0xFFFFF59D).withOpacity(0.4), // Soft yellow glow
          offset: const Offset(0, 0),
        ),
      ],
    ),
    headlineSmall: GoogleFonts.orbitron(
      fontSize: 24,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    labelLarge: GoogleFonts.greatVibes(
      fontSize: 20,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xFF1E1E1E)),
      foregroundColor: WidgetStateProperty.all(const Color(0xFFFFB6C1)),
      minimumSize: WidgetStateProperty.all(
        const Size(double.infinity, 72),  // Increased height for Great Vibes font
      ),
      fixedSize: WidgetStateProperty.all(
        const Size.fromHeight(72),  // Taller to accommodate script font descenders
      ),
      shape: WidgetStateProperty.all(
        BeveledRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        final baseStyle = GoogleFonts.greatVibes(
          fontSize: 26,  // Slightly smaller for better fit
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          height: 1.3,  // Add line height to prevent clipping
        );

        // Resting state
        if (!states.contains(WidgetState.hovered) &&
            !states.contains(WidgetState.focused) &&
            !states.contains(WidgetState.pressed)) {
          return baseStyle.copyWith(
            shadows: [
              Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.8), offset: const Offset(2, 2)),
              Shadow(blurRadius: 8, color: const Color(0xFFFFF59D).withOpacity(0.5), offset: const Offset(0, 0)),
            ],
          );
        }

        // Hover/focus/pressed: stronger golden halo
        return baseStyle.copyWith(
          shadows: [
            Shadow(blurRadius: 6, color: Colors.black.withOpacity(0.9), offset: const Offset(2, 2)),
            Shadow(blurRadius: 16, color: const Color(0xFFFFF59D).withOpacity(0.8), offset: const Offset(0, 0)),
            Shadow(blurRadius: 24, color: const Color(0xFFFFF59D).withOpacity(0.4), offset: const Offset(0, 0)),
          ],
        );
      }),
    ),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF121212),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);