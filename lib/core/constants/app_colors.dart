import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Background & Surface ────────────────────────────────────
  static const Color background = Color(0xFF06070D);
  static const Color surface = Color(0xFF0F1120);
  static const Color surfaceLight = Color(0xFF161830);
  static const Color cardBg = Color(0xFF13152A);
  static const Color cardBgLight = Color(0xFF1C1F3A);

  // ─── Primary Palette ─────────────────────────────────────────
  static const Color primary = Color(0xFF7C6AFF);
  static const Color primaryLight = Color(0xFFA594FF);
  static const Color primaryDark = Color(0xFF5B48D9);

  // ─── Accent / Secondary ──────────────────────────────────────
  static const Color accent = Color(0xFF00E5FF);
  static const Color accentLight = Color(0xFF6EFFFF);

  // ─── Semantic Colors ─────────────────────────────────────────
  static const Color income = Color(0xFF00E676);
  static const Color expense = Color(0xFFFF5252);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF29B6F6);

  // ─── Text ────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF9DA0C1);
  static const Color textMuted = Color(0xFF5C5F80);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Borders & Dividers ──────────────────────────────────────
  static const Color border = Color(0xFF252845);
  static const Color divider = Color(0xFF1E2040);

  // ─── Glass Effect Colors (non-const because of withValues) ──
  static Color get glassWhite => Colors.white.withValues(alpha: 0.06);
  static Color get glassBorder => Colors.white.withValues(alpha: 0.12);
  static Color get glassHighlight => Colors.white.withValues(alpha: 0.08);

  // ─── Glow / Shadow Colors ────────────────────────────────────
  static Color get primaryGlow => primary.withValues(alpha: 0.35);
  static Color get accentGlow => accent.withValues(alpha: 0.25);
  static Color get incomeGlow => income.withValues(alpha: 0.25);
  static Color get expenseGlow => expense.withValues(alpha: 0.25);

  // ─── Gradients ───────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C6AFF), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF161830), Color(0xFF0F1120)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF00E676)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFF8A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFF8F00), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0C18), Color(0xFF06070D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Category Colors ─────────────────────────────────────────
  static const Color catFood = Color(0xFFFF8A65);
  static const Color catShopping = Color(0xFFBA68C8);
  static const Color catTransport = Color(0xFF4FC3F7);
  static const Color catEntertainment = Color(0xFFFFD54F);
  static const Color catBills = Color(0xFFE57373);
  static const Color catHealth = Color(0xFF81C784);
  static const Color catEducation = Color(0xFF7986CB);
  static const Color catInvestment = Color(0xFF4DD0E1);
}
