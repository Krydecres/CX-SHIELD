import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Lỗi trả về từ backend theo mẫu `{code, message, fieldErrors}`.
class ApiException implements Exception {
  ApiException({required this.statusCode, required this.code, required this.message, this.fieldErrors = const {}});

  final int statusCode;
  final String code;
  final String message;
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}

/// Gọi REST API Spring Boot, đính kèm access token Supabase của người đang đăng nhập.
class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _http;
  final String _baseUrl;

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, Map<String, dynamic> body) => _send('POST', path, body);

  Future<dynamic> put(String path, Map<String, dynamic> body) => _send('PUT', path, body);

  Future<dynamic> _send(String method, String path, [Map<String, dynamic>? body]) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final request = http.Request(method, Uri.parse('$_baseUrl/api/v1$path'))
      ..headers['Accept'] = 'application/json';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _http.send(request));
    } catch (_) {
      throw ApiException(
        statusCode: 0,
        code: 'NETWORK_ERROR',
        message: 'Không kết nối được máy chủ. Vui lòng kiểm tra mạng và thử lại.',
      );
    }

    final text = utf8.decode(response.bodyBytes);
    final decoded = text.isEmpty ? null : jsonDecode(text);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw _toException(response.statusCode, decoded);
  }

  static ApiException _toException(int status, dynamic body) {
    if (body is Map<String, dynamic>) {
      final fieldErrors = (body['fieldErrors'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, value.toString()));
      return ApiException(
        statusCode: status,
        code: body['code'] as String? ?? 'ERROR',
        message: body['message'] as String? ?? 'Đã có lỗi xảy ra.',
        fieldErrors: fieldErrors,
      );
    }
    return ApiException(
      statusCode: status,
      code: status == 401 ? 'UNAUTHORIZED' : 'ERROR',
      message: status == 401
          ? 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.'
          : 'Đã có lỗi xảy ra (HTTP $status).',
    );
  }
}
