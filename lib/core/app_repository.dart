import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';
import 'app_models.dart';

class AppRepository {
  AppRepository({ApiClient? apiClient, FlutterSecureStorage? storage})
    : _apiClient = apiClient ?? ApiClient(),
      _storage = storage ?? const FlutterSecureStorage();

  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  Future<AppBootstrap> loadBootstrap() async {
    final data = await _getCachedMap(
      '/api/app/bootstrap',
      cacheKey: _CacheKeys.bootstrap,
      auth: false,
    );
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
    final data = await _getCachedMap(
      '/api/app/members',
      cacheKey: _CacheKeys.members,
    );
    return _list(data['members'], AppUser.fromJson);
  }

  Future<AppUser?> loadCurrentUser() async {
    final data = await _getCachedMap('/api/auth/me', cacheKey: _CacheKeys.me);
    if (data['user'] is! Map<String, dynamic>) return null;
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<List<AppUser>> loadExecutives() async {
    final data = await _getCachedMap(
      '/api/app/executives',
      cacheKey: _CacheKeys.executives,
    );
    return _list(data['executives'], AppUser.fromJson);
  }

  Future<List<AppNotification>> loadNotifications() async {
    final data = await _getCachedMap(
      '/api/app/notifications',
      cacheKey: _CacheKeys.notifications,
    );
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
    final data = await _getCachedMap(
      '/api/app/conversations',
      cacheKey: _CacheKeys.conversations,
    );
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
    final data = await _getCachedMap(
      '/api/app/conversations/$conversationId/messages',
      cacheKey: _CacheKeys.messages(conversationId),
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

  Future<({String url, String contentType})> uploadProfileImage({
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

  Future<AppUser> updateProfile({
    String? fullName,
    String? phone,
    String? institution,
    String? avatarUrl,
    String? bio,
  }) async {
    final data = await _apiClient.patch(
      '/api/app/profile',
      body: {
        if (_hasValue(fullName)) 'fullName': fullName!.trim(),
        if (_hasValue(phone)) 'phone': phone!.trim(),
        if (_hasValue(institution)) 'institution': institution!.trim(),
        if (_hasValue(avatarUrl)) 'avatarUrl': avatarUrl!.trim(),
        if (_hasValue(bio)) 'bio': bio!.trim(),
      },
    );
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
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

  Future<Map<String, dynamic>> _getCachedMap(
    String path, {
    required String cacheKey,
    bool auth = true,
  }) async {
    try {
      final data = await _apiClient.get(path, auth: auth);
      await _storage.write(key: cacheKey, value: jsonEncode(data));
      return data;
    } on ApiException {
      final cached = await _readCachedMap(cacheKey);
      if (cached != null) return cached;
      rethrow;
    } catch (_) {
      final cached = await _readCachedMap(cacheKey);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _readCachedMap(String cacheKey) async {
    final cached = await _storage.read(key: cacheKey);
    if (cached == null || cached.isEmpty) return null;
    final decoded = jsonDecode(cached);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }
}

class _CacheKeys {
  static const bootstrap = 'cache_app_bootstrap';
  static const me = 'cache_auth_me';
  static const members = 'cache_app_members';
  static const executives = 'cache_app_executives';
  static const notifications = 'cache_app_notifications';
  static const conversations = 'cache_app_conversations';

  static String messages(String conversationId) =>
      'cache_app_conversation_messages_$conversationId';
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

List<T> _list<T>(Object? value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList(growable: false);
}
