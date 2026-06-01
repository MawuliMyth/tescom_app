import 'api_client.dart';
import 'app_models.dart';

class AppRepository {
  AppRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AppBootstrap> loadBootstrap() async {
    final data = await _apiClient.get('/api/app/bootstrap', auth: false);
    return AppBootstrap.fromJson(data);
  }

  Future<void> sendContactMessage({
    required String name,
    required String email,
    required String topic,
    required String message,
  }) async {
    await _apiClient.post(
      '/api/app/contact',
      auth: false,
      body: {'name': name, 'email': email, 'topic': topic, 'message': message},
    );
  }

  Future<List<AppUser>> loadMembers() async {
    final data = await _apiClient.get('/api/app/members');
    return _list(data['members'], AppUser.fromJson);
  }

  Future<AppUser?> loadCurrentUser() async {
    final data = await _apiClient.get('/api/auth/me');
    if (data['user'] is! Map<String, dynamic>) return null;
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<List<AppUser>> loadExecutives() async {
    final data = await _apiClient.get('/api/app/executives');
    return _list(data['executives'], AppUser.fromJson);
  }

  Future<List<AppNotification>> loadNotifications() async {
    final data = await _apiClient.get('/api/app/notifications');
    return _list(data['notifications'], AppNotification.fromJson);
  }

  Future<void> markNotificationRead(String id) async {
    await _apiClient.patch('/api/app/notifications/$id/read');
  }

  Future<List<AppConversation>> loadConversations() async {
    final data = await _apiClient.get('/api/app/conversations');
    return _list(data['conversations'], AppConversation.fromJson);
  }

  Future<List<AppMessage>> loadConversationMessages(
    String conversationId,
  ) async {
    final data = await _apiClient.get(
      '/api/app/conversations/$conversationId/messages',
    );
    return _list(data['messages'], AppMessage.fromJson);
  }

  Future<AppMessage> sendConversationMessage({
    required String conversationId,
    required String body,
  }) async {
    final data = await _apiClient.post(
      '/api/app/conversations/$conversationId/messages',
      body: {'body': body},
    );
    return AppMessage.fromJson(data['message'] as Map<String, dynamic>);
  }

  Future<List<AppSavedItem>> loadSavedItems() async {
    final data = await _apiClient.get('/api/app/saved-items');
    return _list(data['savedItems'], AppSavedItem.fromJson);
  }

  Future<void> saveItem({
    required String itemType,
    required String itemId,
  }) async {
    await _apiClient.post(
      '/api/app/saved-items',
      body: {'itemType': itemType, 'itemId': itemId},
    );
  }

  Future<void> removeSavedItem({
    required String itemType,
    required String itemId,
  }) async {
    await _apiClient.delete('/api/app/saved-items/$itemType/$itemId');
  }

  Future<void> voteInPoll({
    required String pollId,
    required String optionId,
  }) async {
    await _apiClient.post(
      '/api/app/polls/$pollId/vote',
      body: {'optionId': optionId},
    );
  }
}

List<T> _list<T>(Object? value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList(growable: false);
}
