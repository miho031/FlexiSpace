import 'package:flutter/material.dart';

/// FlexiSpace vizualni sustav.
class AppTheme {
  AppTheme._();

  static const Color gradientStart = Color(0xFFEAF4F2);
  static const Color gradientEnd = Color(0xFFB8CBC6);

  static const Color primaryYellow = Color(0xFF0F766E);
  static const Color primaryBlack = Color(0xFF17201E);
  static const Color accentGold = Color(0xFFE9B949);
  static const Color danger = Color(0xFFB42318);
  static const Color success = Color(0xFF217A4B);
  static const Color warning = Color(0xFF9A5B13);

  static const Color cardWhite = Color(0xFFFFFEFB);
  static const Color inputFill = Color(0xFFF4F7F6);
  static const Color border = Color(0xFFD6E0DD);
  static const Color textPrimary = Color(0xFF17201E);
  static const Color textMuted = Color(0xFF62706C);

  static BoxDecoration get gradientBackground => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [gradientStart, gradientEnd],
    ),
  );

  static InputDecoration inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: inputFill,
    hintStyle: const TextStyle(color: textMuted, fontWeight: FontWeight.w400),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryYellow, width: 1.6),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  static ButtonStyle get blackButton => ElevatedButton.styleFrom(
    backgroundColor: primaryBlack,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    minimumSize: const Size(double.infinity, 50),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );

  static ButtonStyle get yellowButton => ElevatedButton.styleFrom(
    backgroundColor: primaryYellow,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    minimumSize: const Size(double.infinity, 50),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );

  static ColorScheme get colorScheme => const ColorScheme.light(
    primary: primaryYellow,
    onPrimary: Colors.white,
    secondary: accentGold,
    onSecondary: primaryBlack,
    surface: cardWhite,
    onSurface: textPrimary,
    error: danger,
    onError: Colors.white,
  );
}
