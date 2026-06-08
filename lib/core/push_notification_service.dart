import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';
import 'app_refresh_bus.dart';
import 'app_settings_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await PushNotificationService.ensureFirebaseInitialized();
}

class PushNotificationService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    AppSettingsService? settingsService,
    ApiClient? apiClient,
  }) : _messaging = messaging,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin(),
       _settingsService = settingsService ?? AppSettingsService(),
       _apiClient = apiClient ?? ApiClient();

  static bool _firebaseInitialized = false;
  static bool _localNotificationsInitialized = false;

  final FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final AppSettingsService _settingsService;
  final ApiClient _apiClient;

  static Future<bool> ensureFirebaseInitialized() async {
    if (_firebaseInitialized) return true;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _firebaseInitialized = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> initializeForSignedInUser() async {
    if (!await ensureFirebaseInitialized()) return;
    await _initializeLocalNotifications();

    final messaging = _messaging ?? FirebaseMessaging.instance;
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) _handleMessageOpened(initialMessage);
    messaging.onTokenRefresh.listen((token) async {
      if (await _settingsService.notificationsEnabled()) {
        await registerDeviceToken(token);
      }
    });

    if (await _settingsService.notificationsEnabled()) {
      await enableNotifications();
    }
  }

  Future<void> enableNotifications() async {
    if (!await ensureFirebaseInitialized()) return;
    await _settingsService.setNotificationsEnabled(true);
    final messaging = _messaging ?? FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await messaging.getToken();
    if (token != null) await registerDeviceToken(token);
  }

  Future<void> disableNotifications() async {
    await _settingsService.setNotificationsEnabled(false);
    if (!await ensureFirebaseInitialized()) return;

    final messaging = _messaging ?? FirebaseMessaging.instance;
    final token = await messaging.getToken();
    if (token == null) return;
    try {
      await _apiClient.post(
        '/api/app/device-tokens/disable',
        body: {'token': token},
      );
    } catch (_) {
      // The local setting still disables notification registration.
    }
  }

  Future<void> registerDeviceToken(String token) async {
    try {
      await _apiClient.post(
        '/api/app/device-tokens',
        body: {
          'token': token,
          'platform': defaultTargetPlatform.name,
          'enabled': true,
        },
      );
    } catch (_) {
      // Registration is retried on next launch or token refresh.
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    await _localNotifications.initialize(settings: settings);

    const channel = AndroidNotificationChannel(
      'tescon_updates',
      'TESCON Updates',
      description: 'News, announcements, polls, and event updates.',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _localNotificationsInitialized = true;
  }

  void _handleMessageOpened(RemoteMessage message) {
    if (_shouldRefreshFromMessage(message)) AppRefreshBus().refresh();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (_shouldRefreshFromMessage(message)) AppRefreshBus().refresh();
    await _showForegroundNotification(message);
  }

  bool _shouldRefreshFromMessage(RemoteMessage message) {
    final type = message.data['type'];
    return type == 'content_update' || type == 'notification';
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (!await _settingsService.notificationsEnabled()) return;
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'tescon_updates',
          'TESCON Updates',
          channelDescription: 'News, announcements, polls, and event updates.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
