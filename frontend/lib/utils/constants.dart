// utils/constants.dart

import 'package:flutter/material.dart';

class AppColors {
  // Үндсэн өнгө
  static const primary = Color(0xFF6366F1);        // Indigo
  static const secondary = Color(0xFF8B5CF6);      // Purple
  static const accent = Color(0xFFEC4899);         // Pink
  static const success = Color(0xFF10B981);        // Green
  static const warning = Color(0xFFF59E0B);        // Orange
  static const error = Color(0xFFEF4444);          // Red
  
  // Background
  static const background = Color(0xFFF9FAFB);
  static const surface = Colors.white;
  
  // Text
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static const caption = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}