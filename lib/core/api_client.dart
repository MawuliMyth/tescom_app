import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'api_config.dart';
import 'auth_tokens.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, TokenStorage? tokenStorage})
    : _httpClient = httpClient ?? http.Client(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  static Future<void>? _refreshInFlight;

  final http.Client _httpClient;
  final TokenStorage _tokenStorage;

  Future<Map<String, dynamic>> get(String path, {bool auth = true}) async {
    final response = await _send('GET', path, auth: auth);
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final response = await _send('POST', path, body: body, auth: auth);
    return response.body.isEmpty ? <String, dynamic>{} : _decode(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final response = await _send('PATCH', path, body: body, auth: auth);
    return response.body.isEmpty ? <String, dynamic>{} : _decode(response);
  }

  Future<void> delete(String path, {bool auth = true}) async {
    final response = await _send('DELETE', path, auth: auth);
    if (response.body.isNotEmpty) _decode(response);
  }

  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required String fieldName,
    required String filename,
    required Uint8List bytes,
    required String contentType,
    bool auth = true,
    bool retrying = false,
  }) async {
    const requestTimeout = Duration(seconds: 90);
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: _mediaType(contentType),
        ),
      );

    if (auth) {
      if (await _tokenStorage.shouldRefreshAccessToken()) {
        await refreshSession();
      }
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    try {
      final streamed = await _httpClient.send(request).timeout(requestTimeout);
      final response = await http.Response.fromStream(streamed);
      if (auth && response.statusCode == 401 && !retrying) {
        await refreshSession();
        return uploadFile(
          path,
          fieldName: fieldName,
          filename: filename,
          bytes: bytes,
          contentType: contentType,
          auth: auth,
          retrying: true,
        );
      }
      return _decode(response);
    } on TimeoutException {
      throw const ApiException(
        'The upload is taking longer than expected. Please try again.',
      );
    }
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required bool auth,
    bool retrying = false,
  }) async {
    const requestTimeout = Duration(seconds: 45);
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (auth) {
      if (await _tokenStorage.shouldRefreshAccessToken()) {
        await refreshSession();
      }
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    final encodedBody = body == null ? null : jsonEncode(body);
    final http.Response response;
    try {
      response = switch (method) {
        'GET' =>
          await _httpClient.get(uri, headers: headers).timeout(requestTimeout),
        'POST' =>
          await _httpClient
              .post(uri, headers: headers, body: encodedBody)
              .timeout(requestTimeout),
        'PATCH' =>
          await _httpClient
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(requestTimeout),
        'DELETE' =>
          await _httpClient
              .delete(uri, headers: headers)
              .timeout(requestTimeout),
        _ => throw UnsupportedError('Unsupported method $method'),
      };
    } on TimeoutException {
      throw const ApiException(
        'The server is taking longer than expected. Please try again.',
      );
    }

    if (auth && response.statusCode == 401 && !retrying) {
      await refreshSession();
      return _send(method, path, body: body, auth: auth, retrying: true);
    }

    return response;
  }

  Future<void> refreshSession() {
    final currentRefresh = _refreshInFlight;
    if (currentRefresh != null) return currentRefresh;

    final refresh = _refreshSessionOnce();
    _refreshInFlight = refresh;
    return refresh.whenComplete(() => _refreshInFlight = null);
  }

  Future<void> _refreshSessionOnce() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) throw const ApiException('Session expired');

    try {
      final response = await _httpClient
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/refresh'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 45));

      final data = _decode(response);
      await _tokenStorage.save(AuthTokens.fromJson(data['tokens']));
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await _tokenStorage.clear();
      }
      rethrow;
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    final data = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        data['message'] as String? ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }

    return data;
  }
}

MediaType _mediaType(String value) {
  final parts = value.split('/');
  if (parts.length != 2) return MediaType('application', 'octet-stream');
  return MediaType(parts.first, parts.last);
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
