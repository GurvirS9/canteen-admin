import 'package:flutter/material.dart';
import 'package:manager_app/data/models/order.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Canteen Manager';
  static const String apiBaseUrl = 'https://api.example.com';
  static const bool isDemoMode = true;

  // Categories
  static const List<String> menuCategories = [
    'Main Course',
    'Snacks',
    'Beverages',
    'Desserts',
    'Combos',
    'Breakfast',
  ];
}

class AppColors {
  AppColors._();

  // Primary palette — reddish accent
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryLight = Color(0xFFEF5350);
  static const Color primaryDark = Color(0xFFB71C1C);

  // Accent — warm coral/rose
  static const Color accent = Color(0xFFE57373);
  static const Color accentLight = Color(0xFFFFCDD2);

  // Light-mode backgrounds
  static const Color scaffoldBg = Color(0xFFF5F5F5);
  static const Color cardBg = Colors.white;

  // Dark-mode backgrounds — neutral grays
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color cardDark = Color(0xFF2C2C2E);
  static const Color elevatedDark = Color(0xFF3A3A3C);

  // Status colors
  static const Color pending = Color(0xFFFFA726);
  static const Color accepted = Color(0xFF42A5F5);
  static const Color preparing = Color(0xFFFF7043);
  static const Color ready = Color(0xFF66BB6A);
  static const Color completed = Color(0xFF4CAF50);
  static const Color cancelled = Color(0xFFEF5350);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  static Color statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return pending;
      case OrderStatus.accepted:
        return accepted;
      case OrderStatus.preparing:
        return preparing;
      case OrderStatus.ready:
        return ready;
      case OrderStatus.completed:
        return completed;
      case OrderStatus.cancelled:
        return cancelled;
    }
  }
}
