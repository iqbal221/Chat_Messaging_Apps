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
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    if (completePhoneNumber.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Phone number required')));
      return;
    }

    try {
      setState(() => isLoading = true);

      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: completePhoneNumber.trim())
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not registered')));
        return;
      }

      final userDoc = userQuery.docs.first;
      print(userDoc);

      if (userDoc.id == currentUid) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("You can't add yourself")));
        return;
      }

      final existingContact = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('contacts')
          .where('receiverId', isEqualTo: userDoc.id)
          .get();

      if (existingContact.docs.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Contact already added')));
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('contacts')
          .add({
            'receiverId': userDoc.id,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact added successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
        elevation: 0,
        backgroundColor: isDark
            ? AppTheme.darkTheme.appBarTheme.backgroundColor
            : AppTheme.lightTheme.appBarTheme.backgroundColor,
        title: Text("Add New Contact", style: AppTextStyles.titleLarge),
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

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            /// LAST NAME
            TextField(
              controller: lastNameController,

              decoration: InputDecoration(
                hintText: "Last Name",

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            /// PHONE NUMBER WITH COUNTRY CODE
            IntlPhoneField(
              controller: phoneController,
              initialCountryCode: 'BD',

              decoration: InputDecoration(
                hintText: "Mobile Number",

                border: OutlineInputBorder(),
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
