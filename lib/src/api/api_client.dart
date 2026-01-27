import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getJson(String path,
      {Map<String, String>? query}) async {
    final uri = ApiConfig.buildUri(path, query);
    final response = await _client.get(uri, headers: _headers());
    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> postJson(String path, Object body) async {
    final uri = ApiConfig.buildUri(path);
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> patchJson(String path, Object body) async {
    final uri = ApiConfig.buildUri(path);
    final response = await _client.patch(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _decodeJson(response);
  }

  Map<String, String> _headers() {
    return <String, String>{
      'Content-Type': 'application/json',
      'x-api-key': ApiConfig.apiKey,
    };
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    final body = response.body;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, body);
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        response.statusCode,
        'Unexpected response format',
      );
    }
    return decoded;
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
