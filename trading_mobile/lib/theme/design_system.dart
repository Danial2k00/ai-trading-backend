import 'package:flutter/material.dart';

/// Premium fintech palette — light-first, TradingView / Binance inspired.
abstract final class AppColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color primary = Color(0xFF4F46E5);
  static const Color primarySoft = Color(0xFFEEF2FF);
  static const Color buy = Color(0xFF22C55E);
  static const Color sell = Color(0xFFEF4444);
  static const Color hold = Color(0xFFF59E0B);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color chartGrid = Color(0xFFE8EDF5);

  static const List<Color> headerGradient = [
    Color(0xFFEEF2FF),
    Color(0xFFF8FAFC),
  ];
}

abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get pill => BorderRadius.circular(999);
  static BorderRadius get sheet => BorderRadius.vertical(top: Radius.circular(xl));
}

abstract final class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
}

/// Soft layered shadows for cards (modern fintech depth).
abstract final class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> subtle = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
