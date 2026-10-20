import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

class AuthService {
  // Simpan Sesi Pengguna
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUser, jsonEncode(user.toJson()));
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
  }

  // Ambil Sesi Pengguna
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.keyUser);
    if (userJson == null) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(userJson);
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // Cek Status Login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUser);
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
  }

  // Pengaturan Base URL API (bisa disesuaikan via menu setting di HP)
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyBaseUrl) ?? AppConstants.defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyBaseUrl, url.trim());
  }

  // Pengaturan API Key
  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyApiKey) ?? AppConstants.defaultApiKey;
  }

  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyApiKey, key.trim());
  }
}
