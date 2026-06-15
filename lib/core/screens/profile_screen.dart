import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:chat_messaging/core/providers/auth_provider.dart';
import 'package:chat_messaging/core/screens/input_phone_screen.dart';
import 'package:chat_messaging/core/screens/update_profile.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String name = '/profile_screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<UserProvider>().getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        centerTitle: true,
        title: const Text("Profile", style: AppTextStyles.appBarTitle),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // PROFILE IMAGE
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 3),
                      image: DecorationImage(
                        image: userProvider.profileImage.isNotEmpty
                            ? NetworkImage(userProvider.profileImage)
                            : const AssetImage('assets/images/avatar.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // NAME (DYNAMIC)
              Text(
                '${userProvider.firstName} ${userProvider.lastName}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // PHONE (DYNAMIC)
              Text(
                userProvider.phoneNumber,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),

              const SizedBox(height: 30),

              buildTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {
                  Navigator.pushNamed(context, UpdateUserProfileScreen.name);
                },
              ),

              buildTile(
                icon: Icons.lock_outline,
                title: 'Privacy',
                onTap: () {},
              ),

              buildTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                onTap: () {},
              ),

              buildTile(
                icon: Icons.logout,
                title: 'Logout',
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () async {
                  final shouldLogout = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text("Cancel"),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text(
                              "Logout",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldLogout == true) {
                    await FirebaseAuth.instance.signOut();

                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        PhoneNumberScreen.name,
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
