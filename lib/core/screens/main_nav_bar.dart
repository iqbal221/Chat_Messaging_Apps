import 'package:ChatVani/features/chat/presentation/screens/recent_chat_contact_screen.dart';
import 'package:ChatVani/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:ChatVani/features/contacts/presentation/screens/contact_screen.dart';
import 'package:ChatVani/features/profiles/presentation/screens/profile_screen.dart';

class MainNavBarScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavBarScreen({super.key, this.initialIndex = 0});

  static const String name = "/dashboard";

  @override
  State<MainNavBarScreen> createState() => _MainNavBarScreenState();
}

class _MainNavBarScreenState extends State<MainNavBarScreen> {
  int _selectedIndex = 0;

  final Color primaryColor = const Color(0xFF002DE3);

  final List<Widget> _screens = [
    ContactScreen(),
    RecentChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,

        /// ⭐ SELECTED COLOR FIX
        indicatorColor: AppTheme.lightTheme.primaryColor.withAlpha(10),

        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        destinations: [
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(
              Icons.people_alt,
              color: AppTheme.lightTheme.primaryColor,
            ),
            label: "Contacts",
          ),

          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(
              Icons.chat_bubble,
              color: AppTheme.lightTheme.primaryColor,
            ),
            label: "Chats",
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(
              Icons.person,
              color: AppTheme.lightTheme.primaryColor,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
