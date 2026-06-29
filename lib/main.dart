import 'package:chat_messaging/app.dart';
import 'package:chat_messaging/core/firebase/fcm_service.dart';
import 'package:chat_messaging/core/firebase/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';

// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   print("Background message: ${message.messageId}");
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   /// attach navigator key FIRST
//   NotificationService.navigatorKey = navigatorKey;

//   /// init services
//   await NotificationService.init();
//   await NotificationService.handleInitialMessage();

//   await FCMService.init();

//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     NotificationService.showNotification(
//       title: message.notification?.title ?? 'New Message',
//       body: message.notification?.body ?? '',
//     );
//   });

//   await dotenv.load(fileName: ".env");

//   runApp(const ChatMessaging());
// }
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("1");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("2");

  NotificationService.navigatorKey = navigatorKey;

  await NotificationService.init();

  print("3");

  await NotificationService.handleInitialMessage();

  print("4");

  await FCMService.init();

  print("5");

  await dotenv.load(fileName: ".env");

  print("6");

  runApp(const ChatMessaging());

  print("7");
}
