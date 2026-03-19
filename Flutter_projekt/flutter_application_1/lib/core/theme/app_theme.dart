import 'package:flutter/material.dart';

/// FlexiSpace dizajn - boje i stilovi prema skici
class AppTheme {
  AppTheme._();

  // Gradient boje (svijetlo zlatna -> tamno zlatna/olive)
  static const Color gradientStart = Color(0xFFE6D36F);
  static const Color gradientEnd = Color(0xFF8F8444);

  // Akcent boje
  static const Color primaryYellow = Color(0xFFFFD54F);
  static const Color primaryBlack = Colors.black;

  // Kartice i inputi
  static const Color cardWhite = Colors.white;
  static const Color inputFill = Colors.white;

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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  static ButtonStyle get blackButton => ElevatedButton.styleFrom(
        backgroundColor: primaryBlack,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 50),
      );

  static ButtonStyle get yellowButton => ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: primaryBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 50),
      );
}
