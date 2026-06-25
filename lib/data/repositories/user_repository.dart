import 'package:cloud_firestore/cloud_firestore.dart';
import '/data/models/users_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Users?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return Users.fromFirestore(doc, null);
    }
    return null;
  }

  Future<void> saveUser(String uid, Users user) async {
    await _db.collection('users').doc(uid).set(user.toFirestore());
  }

  Future<void> updateUserField(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }
}
