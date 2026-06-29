import 'package:chat_messaging/features/auth/presentation/screens/input_phone_screen.dart';
import 'package:chat_messaging/core/screens/main_nav_bar.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:chat_messaging/features/auth/presentation/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String name = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // AUTO CHECK LOGIN
    Future.microtask(() => checkAuthStatus());
  }

  Future<void> checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    print("CURRENT USER: $user");

    if (user != null) {
      Navigator.pushReplacementNamed(context, MainNavBarScreen.name);
    } else {
      Navigator.pushReplacementNamed(context, LoginScreen.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkTheme.scaffoldBackgroundColor
          : AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isDark
                ? Image.asset('assets/images/home-dark.png', width: 250)
                : Image.asset('assets/images/home.png', width: 250),
            SizedBox(height: 40),
            SizedBox(
              width: 340,
              child: Text(
                'Connect easily with your family and friends over countries.',
                style: isDark
                    ? AppTheme.darkTheme.textTheme.displayLarge
                    : AppTheme.lightTheme.textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 120),
            Text(
              "Terms & Privacy Policy",
              style: isDark
                  ? AppTheme.darkTheme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                    )
                  : AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                      color: Colors.black,
                    ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              // onPressed: checkAuthStatus,
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.name);
              },
              child: const Text('Start Messaging'),
            ),
          ],
        ),
      ),
    );
  }
}
