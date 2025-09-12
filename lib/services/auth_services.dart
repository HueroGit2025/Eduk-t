import 'package:cloud_firestore/cloud_firestore.dart';

import 'encryption_helper.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> login({
    required String role,
    required String enrollment,
    required String password,
  }) async {
    try {
      final doc = await _firestore
          .collection(role)
          .doc(enrollment)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      if (EncryptionHelper.verifyPassword(password, data['password'])) {
        return {
          'name': data['name'],
          'enrollment': enrollment,
          'rol': role,
          'image': (data['image'] != null) ? data['image'] : '',
          'career':(data['career'] != null) ? data['career'] : ''
        };
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }
}
