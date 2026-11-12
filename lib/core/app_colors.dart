import 'package:flutter/material.dart';

/// AppColors defines the complete color palette for Tariq Medical Store.
/// All colors are centralized here as per design specification.
class AppColors {
  // Brand & Surfaces
  static const Color primary = Color(0xFF0E8FA3);       // Primary teal
  static const Color primaryDark = Color(0xFF0A6B7A);   // Darker teal
  static const Color primaryLight = Color(0xFFE2F4F7);  // Soft teal tint
  static const Color primaryContainer = Color(0xFFCCEBF0);

  static const Color background = Color(0xFFF6F9FA);    // Soft clean background
  static const Color surface = Color(0xFFFFFFFF);       // White surface
  static const Color surfaceVariant = Color(0xFFF0F4F6);

  // Text
  static const Color textPrimary = Color(0xFF1A252C);   // Deep slate
  static const Color textSecondary = Color(0xFF60727D); // Muted slate
  static const Color textTertiary = Color(0xFF94A3B8);  // Placeholder/hint

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);

  // Status & Alerts
  static const Color danger = Color(0xFFD64545);        // Red: Danger, Expired, Out of stock
  static const Color dangerLight = Color(0xFFFDE8E8);
  static const Color warning = Color(0xFFF2A100);       // Amber: Low stock, Near expiry
  static const Color warningLight = Color(0xFFFEF5E7);
  static const Color success = Color(0xFF2E9E6B);       // Green: In stock, Paid, Success
  static const Color successLight = Color(0xFFE8F7F0);
  static const Color info = Color(0xFF2563EB);          // Blue: Info
  static const Color infoLight = Color(0xFFEFF6FF);

  // Controlled Drugs Purple Badge
  static const Color controlled = Color(0xFF7C3AED);
  static const Color controlledLight = Color(0xFFF3E8FF);
}

