import 'dart:typed_data';

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

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
    bool enabled = true,
  }) async {
    await _apiClient.post(
      '/api/app/device-tokens',
      body: {'token': token, 'platform': platform, 'enabled': enabled},
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '/api/auth/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  Future<List<AppConversation>> loadConversations() async {
    final data = await _apiClient.get('/api/app/conversations');
    return _list(data['conversations'], AppConversation.fromJson);
  }

  Future<AppConversation> createConversation({
    required String title,
    List<String> participantIds = const [],
  }) async {
    final data = await _apiClient.post(
      '/api/app/conversations',
      body: {'title': title, 'participantIds': participantIds},
    );
    return AppConversation.fromJson(
      data['conversation'] as Map<String, dynamic>,
    );
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
    String body = '',
    String? mediaUrl,
    String? mediaType,
  }) async {
    final payload = <String, dynamic>{'body': body};
    if (mediaUrl != null) payload['mediaUrl'] = mediaUrl;
    if (mediaType != null) payload['mediaType'] = mediaType;
    final data = await _apiClient.post(
      '/api/app/conversations/$conversationId/messages',
      body: payload,
    );
    return AppMessage.fromJson(data['message'] as Map<String, dynamic>);
  }

  Future<void> addConversationParticipant({
    required String conversationId,
    required String userId,
  }) async {
    await _apiClient.post(
      '/api/app/conversations/$conversationId/participants',
      body: {'userId': userId},
    );
  }

  Future<({String url, String contentType})> uploadChatMedia({
    required String filename,
    required List<int> bytes,
    required String contentType,
  }) async {
    final data = await _apiClient.uploadFile(
      '/api/app/uploads',
      fieldName: 'file',
      filename: filename,
      bytes: Uint8List.fromList(bytes),
      contentType: contentType,
    );
    return (
      url: data['url'] as String? ?? '',
      contentType: data['contentType'] as String? ?? contentType,
    );
  }

  Future<void> applyForJob({
    required String jobId,
    String? fullName,
    String? email,
    String? phone,
    String? institution,
    String? coverNote,
    String? credentialsUrl,
    String? supportingUrl,
  }) async {
    await _apiClient.post(
      '/api/app/jobs/$jobId/apply',
      body: {
        if (_hasValue(fullName)) 'fullName': fullName!.trim(),
        if (_hasValue(email)) 'email': email!.trim(),
        if (_hasValue(phone)) 'phone': phone!.trim(),
        if (_hasValue(institution)) 'institution': institution!.trim(),
        if (_hasValue(coverNote)) 'coverNote': coverNote!.trim(),
        if (_hasValue(credentialsUrl)) 'credentialsUrl': credentialsUrl!.trim(),
        if (_hasValue(supportingUrl)) 'supportingUrl': supportingUrl!.trim(),
      },
    );
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

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

List<T> _list<T>(Object? value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList(growable: false);
}
