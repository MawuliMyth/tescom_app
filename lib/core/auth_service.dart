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

  Future<bool> hasSession() async {
    if (!await _tokenStorage.hasRefreshSession()) return false;
    if (await _tokenStorage.hasValidAccessSession()) return true;

    try {
      await _apiClient.refreshSession();
      return true;
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await _tokenStorage.clear();
        return false;
      }
      return true;
    } catch (_) {
      return true;
    }
  }

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
      final body = refreshToken == null
          ? <String, dynamic>{}
          : {'refreshToken': refreshToken};
      await _apiClient.post('/api/auth/logout', body: body);
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) {
    return _tokenStorage.save(AuthTokens.fromJson(data['tokens']));
  }
}
