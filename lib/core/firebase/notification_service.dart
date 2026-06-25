import 'package:chat_messaging/features/chat/presentation/screens/chat_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  // Set this from main.dart
  static GlobalKey<NavigatorState>? navigatorKey;

  static Future<void> init() async {
    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings settings = InitializationSettings(
      android: android,
    );

    await localNotifications.initialize(settings: settings);

    setupNotificationNavigation();
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'chat_channel',
      'Chat Messages',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details = NotificationDetails(android: android);

    await localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  static void setupNotificationNavigation() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final receiverId = message.data['senderId'];

      navigatorKey?.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            receiverId: receiverId,
            receiverName: message.data['senderName'] ?? '',
            receiverImage: '',
          ),
        ),
      );
    });
  }

  static Future<void> handleInitialMessage() async {
    RemoteMessage? message = await FirebaseMessaging.instance
        .getInitialMessage();

    if (message != null) {
      final receiverId = message.data['senderId'];

      navigatorKey?.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            receiverId: receiverId,
            receiverName: message.data['senderName'] ?? '',
            receiverImage: '',
          ),
        ),
      );
    }
  }
}
