import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddNewContactScreen extends StatefulWidget {
  const AddNewContactScreen({super.key});

  static const String name = '/add_new_contact';

  @override
  State<AddNewContactScreen> createState() => _AddNewContactScreenState();
}

class _AddNewContactScreenState extends State<AddNewContactScreen> {
  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  String completePhoneNumber = '';
  bool isLoading = false;

  Future<void> saveContact() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (firstNameController.text.trim().isEmpty ||
        completePhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First name and phone number required')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .add({
            'firstName': firstNameController.text.trim(),
            'lastName': lastNameController.text.trim(),
            'phoneNumber': completePhoneNumber,
            'createdAt': Timestamp.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact Added Successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("ERROR: $e");

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
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        title: const Text("Add New Contact", style: AppTextStyles.appBarTitle),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            TextField(
              controller: firstNameController,

              decoration: InputDecoration(
                hintText: "First Name",
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// LAST NAME
            TextField(
              controller: lastNameController,

              decoration: InputDecoration(
                hintText: "Last Name",
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// PHONE NUMBER WITH COUNTRY CODE
            IntlPhoneField(
              controller: phoneController,
              initialCountryCode: 'BD',

              decoration: InputDecoration(
                hintText: "Mobile Number",
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),

              onChanged: (phone) {
                completePhoneNumber = phone.completeNumber;
              },
            ),

            const SizedBox(height: 40),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: saveContact,

                child: const Text(
                  "Save contact",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
