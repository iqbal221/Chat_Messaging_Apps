import 'dart:convert';
import 'dart:io';

import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:chat_messaging/core/screens/main_nav_bar.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class NewUserProfileScreen extends StatefulWidget {
  const NewUserProfileScreen({super.key});

  static const String name = '/create_profile';

  @override
  State<NewUserProfileScreen> createState() => _NewUserProfileScreenState();
}

class _NewUserProfileScreenState extends State<NewUserProfileScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  File? imageFile;
  bool isLoading = false;

  // 🔥 CHANGE THESE VALUES
  final String cloudName = "deuky2rb8";
  final String uploadPreset = "chat_app_unsigned";

  Future<String> getFcmToken() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    final token = await messaging.getToken();

    print("FCM TOKEN: $token");

    return token ?? "";
  }

  // image picker
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
      final fcmToken = await getFcmToken();

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
        'phoneNumber': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
        "fcmToken": fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile Saved')));

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
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Create Profile", style: AppTextStyles.appBarTitle),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            GestureDetector(
              onTap: pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: imageFile != null
                            ? FileImage(imageFile!)
                            : null,
                        child: imageFile == null
                            ? const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Edit Icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                hintText: 'First Name (required)',
                filled: true,
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: AppTheme.lightTheme.hintColor,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                hintText: 'Last Name (optional)',
                filled: true,
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: AppTheme.lightTheme.hintColor,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProfile,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Profile',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
