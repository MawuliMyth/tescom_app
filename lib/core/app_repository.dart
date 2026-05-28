import 'api_client.dart';
import 'app_models.dart';

class AppRepository {
  AppRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AppBootstrap> loadBootstrap() async {
    final data = await _apiClient.get('/api/app/bootstrap', auth: false);
    return AppBootstrap.fromJson(data);
  }
}
