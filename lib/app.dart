import 'package:chat_messaging/features/auth/providers/auth_provider.dart';
import 'package:chat_messaging/core/routes/app_routes.dart';
import 'package:chat_messaging/core/firebase/notification_service.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:chat_messaging/core/theme/theme_provider.dart';
import 'package:chat_messaging/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatMessaging extends StatefulWidget {
  const ChatMessaging({super.key});

  @override
  State<ChatMessaging> createState() => _ChatMessagingState();
}

class _ChatMessagingState extends State<ChatMessaging> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: NotificationService.navigatorKey,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: HomeScreen.name,
            onGenerateRoute: AppRoutes.routes,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
