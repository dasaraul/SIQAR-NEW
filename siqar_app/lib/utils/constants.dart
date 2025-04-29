import 'package:flutter/material.dart';

class AppConstants {
  // API
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api'; // For Android Emulator
  // static const String apiBaseUrl = 'http://localhost:8000/api'; // For iOS Simulator
  // static const String apiBaseUrl = 'https://your-domain.com/api'; // For Production

  // App Info
  static const String appName = 'SIQAR';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistem QR Absensi Responsif';
  
  // Theme Colors
  static const Color primaryColor = Color(0xFF7C3AED); // Indigo-600
  static const Color secondaryColor = Color(0xFF5B21B6); // Indigo-800
  static const Color accentColor = Color(0xFFC4B5FD); // Indigo-300
  static const Color backgroundColor = Color(0xFFF9FAFB); // Gray-50
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444); // Red-500
  static const Color successColor = Color(0xFF10B981); // Green-500
  static const Color warningColor = Color(0xFFF59E0B); // Amber-500
  static const Color infoColor = Color(0xFF3B82F6); // Blue-500
  
  // Text Colors
  static const Color textPrimaryColor = Color(0xFF1F2937); // Gray-800
  static const Color textSecondaryColor = Color(0xFF6B7280); // Gray-500
  static const Color textLightColor = Color(0xFF9CA3AF); // Gray-400
  
  // Status Colors
  static Map<String, Color> statusColors = {
    'hadir': successColor,
    'terlambat': warningColor,
    'izin': infoColor,
    'sakit': infoColor,
    'alpha': errorColor,
    'aktif': successColor,
    'nonaktif': Color(0xFF6B7280), // Gray-500
  };
  
  // Status Labels
  static Map<String, String> statusLabels = {
    'hadir': 'Hadir',
    'terlambat': 'Terlambat',
    'izin': 'Izin',
    'sakit': 'Sakit',
    'alpha': 'Alpha',
    'aktif': 'Aktif',
    'nonaktif': 'Nonaktif',
  };
  
  // Lokasi Radius (dalam meter)
  static const int defaultRadius = 100;
  
  // Durasi Animasi
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Assets Path
  static const String imagePath = 'assets/images/';
  static const String iconPath = 'assets/icons/';
  static const String animationPath = 'assets/animations/';
  
  // Default Images
  static const String defaultAvatar = '${imagePath}default_avatar.png';
  static const String logoImage = '${imagePath}logo.png';
  static const String placeholderImage = '${imagePath}placeholder.png';
  
  // Animation Files
  static const String loadingAnimation = '${animationPath}loading.json';
  static const String successAnimation = '${animationPath}success.json';
  static const String errorAnimation = '${animationPath}error.json';
  static const String emptyAnimation = '${animationPath}empty.json';
  static const String scannerAnimation = '${animationPath}scanner.json';
}