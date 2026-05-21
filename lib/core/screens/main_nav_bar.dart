import 'package:chat_messaging/core/screens/recent_chat_screen.dart';
import 'package:chat_messaging/core/screens/contact_screen.dart';
import 'package:chat_messaging/core/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class MainNavBarScreen extends StatefulWidget {
  const MainNavBarScreen({super.key});

  static const String name = "/dashboard";

  @override
  State<MainNavBarScreen> createState() => _MainNavBarScreenState();
}

class _MainNavBarScreenState extends State<MainNavBarScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ContactScreen(),
    RecentChatScreen(
      receiverId: 'demo',
      receiverName: 'Chats',
      receiverImage: '',
    ),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: TMAppbar(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          _selectedIndex = index;
          setState(() {});
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            label: "Contacts",
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chats",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
