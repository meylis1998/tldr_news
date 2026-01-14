import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF10B981);

  // Light Theme
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightDivider = Color(0xFFE5E7EB);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkText = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkDivider = Color(0xFF334155);

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'all': Color(0xFF6366F1),
    'tech': Color(0xFF3B82F6),
    'ai': Color(0xFF8B5CF6),
    'crypto': Color(0xFFF59E0B),
    'founders': Color(0xFF10B981),
    'design': Color(0xFFEC4899),
    'devops': Color(0xFF06B6D4),
    'data': Color(0xFF14B8A6),
  };

  // Semantic Colors
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);
}
