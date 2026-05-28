import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_tokens.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, TokenStorage? tokenStorage})
    : _httpClient = httpClient ?? http.Client(),
      _tokenStorage = tokenStorage ?? TokenStorage();

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

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required bool auth,
    bool retrying = false,
  }) async {
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
    final response = switch (method) {
      'GET' => await _httpClient.get(uri, headers: headers),
      'POST' => await _httpClient.post(
        uri,
        headers: headers,
        body: encodedBody,
      ),
      _ => throw UnsupportedError('Unsupported method $method'),
    };

    if (auth && response.statusCode == 401 && !retrying) {
      await refreshSession();
      return _send(method, path, body: body, auth: auth, retrying: true);
    }

    return response;
  }

  Future<void> refreshSession() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) throw const ApiException('Session expired');

    final response = await _httpClient.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/refresh'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    final data = _decode(response);
    await _tokenStorage.save(AuthTokens.fromJson(data['tokens']));
  }

  Map<String, dynamic> _decode(http.Response response) {
    final data = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(data['message'] as String? ?? 'Request failed');
    }

    return data;
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
