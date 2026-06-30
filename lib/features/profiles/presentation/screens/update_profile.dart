import 'dart:convert';
import 'dart:io';

import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:chat_messaging/features/auth/providers/auth_provider.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:chat_messaging/core/screens/main_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
  String phoneNumber = '';
  String email = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final userProvider = context.read<UserProvider>();

      await userProvider.getUserData();

      firstNameController.text = userProvider.firstName;
      lastNameController.text = userProvider.lastName;
      phoneNumber = userProvider.phoneNumber;
      email = userProvider.email;
    });
  }

  bool isLoading = false;

  // 🔥 CHANGE THESE VALUES
  final String cloudName = dotenv.env["CLOUD_NAME"] ?? "";
  final String uploadPreset = dotenv.env["UPLOAD_PRESET"] ?? "";

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

  /// ✅ Upload image to Cloudinary
  Future<String> uploadToCloudinary(File file) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", url);

    request.fields["upload_preset"] = uploadPreset;

    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();

    final resBody = await response.stream.bytesToString();
    final data = jsonDecode(resBody);

    if (response.statusCode == 200) {
      return data["secure_url"];
    } else {
      throw Exception(data);
    }
  }

  Future<void> saveProfile() async {
    if (firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('First name required')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      String imageUrl = "";

      // ✅ Upload image using Cloudinary
      if (imageFile != null) {
        imageUrl = await uploadToCloudinary(imageFile!);
        debugPrint("CLOUDINARY URL: $imageUrl");
      }
      print(imageUrl);

      // ✅ Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'profileImage': imageUrl,
        "phoneNumber": phoneNumber,
        "email": email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Update Profle')));

      Navigator.pushReplacementNamed(context, MainNavBarScreen.name);
    } catch (e) {
      setState(() => isLoading = false);

      debugPrint("UPLOAD FAILED: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkTheme.scaffoldBackgroundColor
          : AppTheme.lightTheme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text("Update Profile", style: AppTextStyles.titleLarge),
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
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.grey.shade900 : Colors.white,
                          border: isDark
                              ? Border.all(color: Colors.grey.shade900)
                              : Border.all(color: Colors.blue, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundImage: imageFile != null
                              ? FileImage(imageFile!)
                              : (provider.profileImage.isNotEmpty
                                    ? NetworkImage(provider.profileImage)
                                    : const AssetImage(
                                            "assets/images/avatar.jpg",
                                          )
                                          as ImageProvider),
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
              decoration: InputDecoration(
                hintText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            /// LAST NAME
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                hintText: 'Last Name',
                border: OutlineInputBorder(),
              ),
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
