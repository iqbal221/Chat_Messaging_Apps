import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Check phone number already exists
      final phoneQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phone)
          .limit(1)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        return "Mobile number already exists";
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "phoneNumber": phone,
          "profileImage": "",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          return "No user found with this email.";

        case "wrong-password":
          return "Incorrect password.";

        case "invalid-credential":
          return "Invalid email or password.";

        case "invalid-email":
          return "Invalid email address.";

        case "user-disabled":
          return "This account has been disabled.";

        default:
          return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
