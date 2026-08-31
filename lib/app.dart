import 'package:ChatVani/features/auth/providers/auth_provider.dart';
import 'package:ChatVani/core/routes/app_routes.dart';
import 'package:ChatVani/core/firebase/notification_service.dart';
import 'package:ChatVani/core/theme/app_theme.dart';
import 'package:ChatVani/core/theme/theme_provider.dart';
import 'package:ChatVani/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatVani extends StatefulWidget {
  const ChatVani({super.key});

  @override
  State<ChatVani> createState() => _ChatVaniState();
}

class _ChatVaniState extends State<ChatVani> {
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
