import 'api_client.dart';
import 'auth_tokens.dart';
import 'token_storage.dart';

class AuthService {
  AuthService({ApiClient? apiClient, TokenStorage? tokenStorage})
    : this._(tokenStorage ?? TokenStorage(), apiClient);

  AuthService._(TokenStorage tokenStorage, ApiClient? apiClient)
    : _tokenStorage = tokenStorage,
      _apiClient = apiClient ?? ApiClient(tokenStorage: tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<bool> hasSession() => _tokenStorage.hasRefreshSession();

  Future<void> signIn({required String email, required String password}) async {
    final data = await _apiClient.post(
      '/api/auth/login',
      auth: false,
      body: {'email': email, 'password': password},
    );
    await _saveTokens(data);
  }

  Future<void> signUp({
    required String fullName,
    required String phone,
    required String institution,
    required String email,
    required String password,
  }) async {
    final data = await _apiClient.post(
      '/api/auth/register',
      auth: false,
      body: {
        'fullName': fullName,
        'phone': phone,
        'institution': institution,
        'email': email,
        'password': password,
      },
    );
    await _saveTokens(data);
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    try {
      await _apiClient.post(
        '/api/auth/logout',
        body: {'refreshToken': refreshToken},
      );
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) {
    return _tokenStorage.save(AuthTokens.fromJson(data['tokens']));
  }
}
