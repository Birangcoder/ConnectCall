import 'package:flutter/material.dart';

/// Centralized color palette so every screen stays visually consistent.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4F6BFF);
  static const Color primaryDark = Color(0xFF3A50D9);
  static const Color secondary = Color(0xFF00C896);

  // Status
  static const Color online = Color(0xFF34C759);
  static const Color offline = Color(0xFF9AA0A6);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);

  // Call controls
  static const Color endCall = Color(0xFFE53935);
  static const Color acceptCall = Color(0xFF34C759);
  static const Color controlActive = Color(0xFF4F6BFF);
  static const Color controlInactive = Color(0xFF3A3A3C);

  // Light theme surfaces
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1C1C1E);
  static const Color textSecondaryLight = Color(0xFF6E7175);

  // Dark theme surfaces
  static const Color backgroundDark = Color(0xFF0F1115);
  static const Color surfaceDark = Color(0xFF1C1E22);
  static const Color textPrimaryDark = Color(0xFFF2F2F7);
  static const Color textSecondaryDark = Color(0xFFA1A1A6);

  static const Color divider = Color(0xFFE5E7EB);
}
