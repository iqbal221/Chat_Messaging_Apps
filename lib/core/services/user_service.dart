import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static Future<String?> getUserIdByPhone(String phone) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: phone)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      return result.docs.first.id;
    }

    return null;
  }
}
