import 'package:flutter/material.dart';

class AppConstants {
  // Nama Aplikasi
  static const String appName = 'ClassCash';
  static const String appSubName = 'Sistem Kas XII RPL 1';

  // Default Base URL ke Laragon di komputer lokal
  // Catatan: Jika diuji di HP fisik, ganti dengan IP WiFi laptop (cth: 192.168.1.10)
  static const String defaultBaseUrl = 'http://10.0.2.2/classcash/api';

  // Header autentikasi API Key
  static const String apiKeyHeader = 'X-API-KEY';
  static const String defaultApiKey = 'cc_live_classcash2026';

  // Kunci SharedPreferences
  static const String keyBaseUrl = 'pref_base_url';
  static const String keyApiKey = 'pref_api_key';
  static const String keyUser = 'pref_user_data';
  static const String keyIsLoggedIn = 'pref_is_logged_in';
}

class AppColors {
  // Palet Warna Khas ClassCash (Navy & Slate)
  static const Color navyDark = Color(0xFF0A1931);
  static const Color navyLight = Color(0xFF1A3D63);
  static const Color background = Color(0xFFEEF3F9);
  static const Color surface = Colors.white;

  // Aksen Status
  static const Color greenSuccess = Color(0xFF10B981);
  static const Color redDanger = Color(0xFFEF4444);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color blueInfo = Color(0xFF3B82F6);

  // Teks
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color border = Color(0xFFCBD5E1);
}
