import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppErrorMessages {
  AppErrorMessages._();

  static String friendly(Object error, {String? fallback}) {
    final raw = error.toString();
    final message = raw
        .replaceFirst(
          RegExp(r'^(Exception|AuthException|PostgrestException):\s*'),
          '',
        )
        .trim();
    final lower = message.toLowerCase();

    if (lower.contains('invalid login credentials')) {
      return 'Netocan email ili lozinka.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Potvrdite email adresu putem linka koji smo vam poslali.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already registered')) {
      return 'Korisnik s ovim emailom vec postoji. Prijavite se.';
    }
    if (lower.contains('network') ||
        lower.contains('socket') ||
        lower.contains('failed host lookup') ||
        lower.contains('timed out') ||
        lower.contains('connection')) {
      return 'Ne mogu se spojiti na server. Provjerite internet i pokusajte ponovno.';
    }
    if (lower.contains('row-level security') ||
        lower.contains('permission') ||
        lower.contains('not authorized') ||
        lower.contains('unauthorized')) {
      return 'Nemate dopustenje za ovu radnju.';
    }
    if (lower.contains('bucket') || lower.contains('storage')) {
      return 'Slika nije spremljena. Provjerite Storage bucket i pokusajte ponovno.';
    }
    if (lower.contains('preklapa') ||
        lower.contains('vec imate rezervaciju') ||
        lower.contains('already reserved')) {
      return 'Odabrani termin vise nije dostupan. Osvjezite termine i odaberite drugi.';
    }
    if (lower.contains('clanstvo') || lower.contains('membership')) {
      return 'Vase clanstvo nije aktivno. Obratite se administratoru.';
    }

    return fallback ?? 'Doslo je do greske. Pokusajte ponovno.';
  }
}

class AppSnackBars {
  AppSnackBars._();

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: AppTheme.success,
      icon: Icons.check_circle_outline,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: AppTheme.warning,
      icon: Icons.info_outline,
    );
  }

  static void showError(
    BuildContext context,
    Object error, {
    String? fallback,
  }) {
    _show(
      context,
      AppErrorMessages.friendly(error, fallback: fallback),
      backgroundColor: AppTheme.danger,
      icon: Icons.error_outline,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
