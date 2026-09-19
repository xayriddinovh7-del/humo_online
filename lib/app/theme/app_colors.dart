import 'package:flutter/material.dart';

/// Ilovaning asosiy rang palitrasyi
/// PDP.uz uslubidagi indigo/binafsha gamma
abstract final class AppColors {
  // ─── Primary ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6366F1);       // indigo-500
  static const Color primaryDark = Color(0xFF4F46E5);   // indigo-600
  static const Color primaryLight = Color(0xFF818CF8);  // indigo-400
  static const Color primarySurface = Color(0xFFEEF2FF); // indigo-50

  // ─── Secondary ──────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF06B6D4);     // cyan-500
  static const Color secondaryDark = Color(0xFF0891B2);
  static const Color secondaryLight = Color(0xFF22D3EE);

  // ─── Accent ─────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFF59E0B);        // amber-500

  // ─── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);       // emerald-500
  static const Color warning = Color(0xFFF59E0B);       // amber-500
  static const Color error = Color(0xFFEF4444);         // red-500
  static const Color info = Color(0xFF3B82F6);          // blue-500

  // ─── Submission Status ──────────────────────────────────────────────────────
  static const Color statusNotSent = Color(0xFF6B7280);   // gray-500
  static const Color statusSent = Color(0xFF3B82F6);       // blue-500
  static const Color statusChecking = Color(0xFFF59E0B);  // amber-500
  static const Color statusGraded = Color(0xFF10B981);    // emerald-500
  static const Color statusReturned = Color(0xFFEF4444);  // red-500

  // ─── Light Theme ────────────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textHintLight = Color(0xFF94A3B8);

  // ─── Dark Theme ─────────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textHintDark = Color(0xFF64748B);

  // ─── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
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
