import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/image_compress_service.dart';
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

    // Görseli sıkıştır (max 1080px, %80 kalite)
    final Uint8List? compressed =
        await ImageCompressService.compressFile(imageFile);

    final String fileName =
        'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference ref = _storage.ref().child('profile_images/$fileName');

    // Sıkıştırılmış baytları yükle; başarısız olursa orijinal dosyayı kullan
    final UploadTask uploadTask = compressed != null
        ? ref.putData(
            compressed,
            SettableMetadata(contentType: 'image/jpeg'),
          )
        : ref.putFile(imageFile);

    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> updateNgoProfile({
    required String stkName,
    required String description,
    required String location,
    required String phone,
    required String vision,
    required String mission,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu bulunamadı.");

    final Map<String, dynamic> data = {
      'stkName': stkName,
      'description': description,
      'location': location,
      'phone': phone,
      'vision': vision,
      'mission': mission,
    };

    if (imageUrl != null) {
      data['imageUrl'] = imageUrl;
    }

    await _firestore.collection('users').doc(user.uid).update(data);
  }

  Future<void> toggleFollowNgo(String ngoId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu bulunamadı.");

    final userRef = _firestore.collection('users').doc(user.uid);
    final ngoRef = _firestore.collection('users').doc(ngoId);

    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final ngoSnapshot = await transaction.get(ngoRef);

      if (!userSnapshot.exists || !ngoSnapshot.exists) {
        throw Exception("Kullanıcı veya Kurum verisi bulunamadı.");
      }

      final List<String> following =
          List<String>.from(userSnapshot.data()?['following'] ?? []);
      final bool isFollowing = following.contains(ngoId);

      if (isFollowing) {
        // Takibi bırak
        transaction.update(userRef, {
          'following': FieldValue.arrayRemove([ngoId])
        });
        transaction
            .update(ngoRef, {'followersCount': FieldValue.increment(-1)});
      } else {
        // Takip et
        transaction.update(userRef, {
          'following': FieldValue.arrayUnion([ngoId])
        });
        transaction.update(ngoRef, {'followersCount': FieldValue.increment(1)});
      }
    });
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateVolunteerProfile({
    required String bio,
    required List<String> interests,
    required List<String> skills,
    DateTime? birthDate,
    required String education,
    required String city,
    required String phone,
    File? imageFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu bulunamadı.");

    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadProfileImage(imageFile);
    }

    final Map<String, dynamic> data = {
      'bio': bio,
      'interests': interests,
      'skills': skills,
      'education': education,
      'city': city,
      'phone': phone,
    };

    if (birthDate != null) {
      data['birthDate'] = Timestamp.fromDate(birthDate);
    }

    if (imageUrl != null) {
      data['imageUrl'] = imageUrl;
    }

    await _firestore.collection('users').doc(user.uid).update(data);
  }
}
