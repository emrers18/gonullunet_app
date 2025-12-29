import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<UserModel?> getUserStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      }
      return null;
    });
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<String> uploadProfileImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu bulunamadı.");

    // Dosya ismi: profile_uid_zaman.jpg
    final String fileName =
        'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference ref = _storage.ref().child('profile_images/$fileName');

    final UploadTask uploadTask = ref.putFile(imageFile);
    final TaskSnapshot snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
  }

  Future<void> updateNgoProfile({
    required String stkName,
    required String description,
    required String location,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu bulunamadı.");

    final Map<String, dynamic> data = {
      'stkName': stkName,
      'description': description,
      'location': location,
    };

    if (imageUrl != null) {
      data['imageUrl'] = imageUrl;
    }

    await _firestore.collection('users').doc(user.uid).update(data);
  }
}
