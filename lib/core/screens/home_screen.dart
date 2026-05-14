import 'package:chat_messaging/core/screens/input_phone_screen.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String name = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/home.png', width: 250),
            SizedBox(height: 40),
            SizedBox(
              width: 340,
              child: Text(
                'Connect easily with your family and friends over countries.',
                style: AppTheme.lightTheme.textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 120),
            Text(
              "Terms & Privacy Policy",
              style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, PhoneNumberScreen.name);
              },
              child: const Text(
                'Start Messaging',
                style: TextStyle(fontSize: 20, letterSpacing: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
