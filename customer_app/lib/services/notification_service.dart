import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Navigation key for handling notification taps
  static GlobalKey<NavigatorState>? navigatorKey;

  Future<void> initialize() async {
    // Initialize local notifications (only on mobile platforms)
    if (!kIsWeb) {
      await _initializeLocalNotifications();
    }

    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional notification permission');
    } else {
      debugPrint('User declined or has not accepted notification permission');
    }

    // Get FCM token (wrapped in try-catch for web compatibility)
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
    } catch (e) {
      debugPrint(
          'Failed to get FCM token (expected on web without VAPID key): $e');
    }

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      // Provider.of<AuthProvider>(context, listen: false).updateFcmToken(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.notification?.title}');

      if (message.notification != null && !kIsWeb) {
        _showLocalNotification(
          title: message.notification!.title ?? 'Sevagan',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped: ${message.data}');
      _handleNotificationTap(message.data);
    });

    // Check if app was opened from a terminated state via notification
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      _handleNotificationTap(initialMessage.data);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped with payload: ${response.payload}');
        if (response.payload != null) {
          // Parse payload and navigate
          // For now, just log it
          debugPrint('Handling local notification tap: ${response.payload}');
        }
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'sevagan_channel', // id
      'Sevagan Notifications', // name
      description: 'Notifications for job updates and messages',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sevagan_channel',
      'Sevagan Notifications',
      channelDescription: 'Notifications for job updates and messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('Handling notification tap with data: $data');

    // Navigate based on notification type
    if (navigatorKey?.currentState == null) {
      debugPrint('Navigator key is null, cannot navigate');
      return;
    }

    final String? type = data['type'];

    switch (type) {
      case 'job_update':
        final String? jobId = data['jobId'];
        if (jobId != null) {
          debugPrint('Navigating to job details: $jobId');
          // navigatorKey!.currentState!.pushNamed('/job-details', arguments: jobId);
        }
        break;
      case 'message':
        final String? chatId = data['chatId'];
        if (chatId != null) {
          debugPrint('Navigating to chat: $chatId');
          // navigatorKey!.currentState!.pushNamed('/chat', arguments: chatId);
        }
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
    debugPrint('FCM token deleted');
  }
}
