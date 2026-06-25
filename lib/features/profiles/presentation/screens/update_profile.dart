import 'dart:io';

import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:chat_messaging/features/auth/providers/auth_provider.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:chat_messaging/core/screens/main_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UpdateUserProfileScreen extends StatefulWidget {
  const UpdateUserProfileScreen({super.key});

  static const String name = '/update_profile';

  @override
  State<UpdateUserProfileScreen> createState() =>
      _UpdateUserProfileScreenState();
}

class _UpdateUserProfileScreenState extends State<UpdateUserProfileScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  File? imageFile;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final userProvider = context.read<UserProvider>();

      await userProvider.getUserData();

      firstNameController.text = userProvider.firstName;
      lastNameController.text = userProvider.lastName;
    });
  }

  /// PICK IMAGE
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
    }
  }

  /// SAVE PROFILE
  Future<void> saveProfile() async {
    if (firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('First name required')));
      return;
    }

    // final userProvider = context.read<UserProvider>();

    // await userProvider.updateProfile(
    //   first: firstNameController.text.trim(),
    //   last: lastNameController.text.trim(),
    //   imageFile: imageFile,
    // );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile Updated')));

    Navigator.pushReplacementNamed(context, MainNavBarScreen.name);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkTheme.scaffoldBackgroundColor
          : AppTheme.lightTheme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Update Profile", style: AppTextStyles.appBarTitle),
        backgroundColor: isDark
            ? AppTheme.darkTheme.appBarTheme.backgroundColor
            : AppTheme.lightTheme.appBarTheme.backgroundColor,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            /// PROFILE IMAGE (CONSUMER USED HERE)
            Consumer<UserProvider>(
              builder: (context, provider, child) {
                return GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 3),
                          image: DecorationImage(
                            image: imageFile != null
                                ? FileImage(imageFile!)
                                : (provider.profileImage.isNotEmpty
                                      ? NetworkImage(provider.profileImage)
                                      : const AssetImage(
                                              'assets/images/avatar.jpg',
                                            )
                                            as ImageProvider),
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
                );
              },
            ),

            const SizedBox(height: 18),

            /// FIRST NAME
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(hintText: 'First Name'),
            ),

            const SizedBox(height: 18),

            /// LAST NAME
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(hintText: 'Last Name'),
            ),

            const SizedBox(height: 30),

            /// SAVE BUTTON (CONSUMER USED HERE)
            Consumer<UserProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : saveProfile,
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
