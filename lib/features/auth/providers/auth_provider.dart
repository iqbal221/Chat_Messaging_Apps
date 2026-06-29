import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String profileImage = '';
  String email = '';

  bool isLoading = false;

  Future<void> getUserData() async {
    try {
      isLoading = true;
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        firstName = data['firstName'] ?? '';
        lastName = data['lastName'] ?? '';
        phoneNumber = data['phoneNumber'] ?? '';
        profileImage = data['profileImage'] ?? '';
        email = data['email'] ?? '';
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
