import 'package:flutter/material.dart';

/// Ilovaning asosiy rang palitrasyi
/// PDP.uz uslubidagi indigo/binafsha gamma
abstract final class AppColors {
  // ─── Primary ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0023E7);       // vibrant blue
  static const Color primaryDark = Color(0xFF12185A);   // dark navy
  static const Color primaryLight = Color(0xFF7B10E6);  // deep purple
  static const Color primarySurface = Color(0xFF111111); // black

  // ─── Secondary ──────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF7B10E6);
  static const Color secondaryDark = Color(0xFF12185A);
  static const Color secondaryLight = Color(0xFF0023E7);

  // ─── Accent ─────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF0023E7);

  // ─── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0023E7);

  // ─── Submission Status ──────────────────────────────────────────────────────
  static const Color statusNotSent = Color(0xFF6B7280);
  static const Color statusSent = Color(0xFF0023E7);
  static const Color statusChecking = Color(0xFFF59E0B);
  static const Color statusGraded = Color(0xFF10B981);
  static const Color statusReturned = Color(0xFFEF4444);

  // ─── Light Theme ────────────────────────────────────────────────────────────
  // We make both themes dark to fit the "iOS 27 glassmorphism" which works best on dark #111111 background
  static const Color backgroundLight = Color(0xFF111111);
  static const Color surfaceLight = Color(0x3312185A); // transparent glass
  static const Color surfaceVariantLight = Color(0x550023E7);
  static const Color cardLight = Color(0x3312185A);
  static const Color borderLight = Color(0x557B10E6);
  static const Color textPrimaryLight = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFFDDDDDD);
  static const Color textHintLight = Color(0xFFAAAAAA);

  // ─── Dark Theme ─────────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF111111);
  static const Color surfaceDark = Color(0x3312185A); // transparent glass
  static const Color surfaceVariantDark = Color(0x550023E7);
  static const Color cardDark = Color(0x3312185A);
  static const Color borderDark = Color(0x557B10E6);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFDDDDDD);
  static const Color textHintDark = Color(0xFFAAAAAA);

  // ─── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0023E7), Color(0xFF7B10E6)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF12185A), Color(0xFF111111)],
  );

  // ─── Shadows ────────────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
