import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import 'auth_service.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  // Helper Headers dengan API Key
  static Future<Map<String, String>> _getHeaders() async {
    final apiKey = await AuthService.getApiKey();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      AppConstants.apiKeyHeader: apiKey,
    };
  }

  // Request GET
  static Future<ApiResponse> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final baseUrl = await AuthService.getBaseUrl();
      String urlStr = '$baseUrl/$endpoint';
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(urlStr).replace(queryParameters: queryParams);
        urlStr = uri.toString();
      }

      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(urlStr), headers: headers)
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);
      return ApiResponse(
        success: body['success'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: body['message'] ?? 'Respons diterima',
        data: body['data'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Koneksi gagal: Tidak dapat menghubungi server (${e.toString()})',
        statusCode: 500,
      );
    }
  }

  // Request POST
  static Future<ApiResponse> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getHeaders();

      final response = await http
          .post(url, headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);
      return ApiResponse(
        success: body['success'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: body['message'] ?? 'Respons diterima',
        data: body['data'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Koneksi gagal: Tidak dapat menghubungi server (${e.toString()})',
        statusCode: 500,
      );
    }
  }
}
