import 'dart:convert';
import 'dart:io';

import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:chat_messaging/core/providers/auth_provider.dart';
import 'package:chat_messaging/core/screens/main_nav_bar.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  bool isLoading = false;

  String imageUrl = "";

  final String cloudName = "deuky2rb8";
  final String uploadPreset = "chat_app_unsigned";

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<UserProvider>().getUserData();
    });

    loadUserData();
  }

  /// LOAD USER DATA
  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      firstNameController.text = data['firstName'] ?? '';
      lastNameController.text = data['lastName'] ?? '';
      imageUrl = data['profileImage'] ?? '';

      setState(() {});
    }
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

  /// CLOUDINARY IMAGE UPLOAD
  Future<String> uploadToCloudinary(File file) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", url);

    request.fields["upload_preset"] = uploadPreset;

    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();

    final responseData = await response.stream.bytesToString();

    final data = jsonDecode(responseData);

    if (response.statusCode == 200) {
      return data["secure_url"];
    } else {
      throw Exception(data);
    }
  }

  /// SAVE OR UPDATE PROFILE
  Future<void> saveProfile() async {
    if (firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('First name required')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      String finalImageUrl = imageUrl;

      /// UPLOAD NEW IMAGE
      if (imageFile != null) {
        finalImageUrl = await uploadToCloudinary(imageFile!);
      }

      /// UPDATE FIRESTORE
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'profileImage': finalImageUrl,
        'phoneNumber': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      /// REFRESH PROVIDER
      await context.read<UserProvider>().getUserData();

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile Updated')));

      Navigator.pushReplacementNamed(context, MainNavBarScreen.name);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Update Profile", style: AppTextStyles.appBarTitle),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

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

            const SizedBox(height: 18),

            /// FIRST NAME
            TextField(
              controller: firstNameController,

              decoration: InputDecoration(
                hintText: 'First Name',

                filled: true,

                fillColor: AppTheme.lightTheme.hintColor,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// LAST NAME
            TextField(
              controller: lastNameController,

              decoration: InputDecoration(
                hintText: 'Last Name',

                filled: true,

                fillColor: AppTheme.lightTheme.hintColor,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: isLoading ? null : saveProfile,

                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Profile',
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
