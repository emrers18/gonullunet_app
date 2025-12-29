import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gonullunet_app/models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const int limit = 5;

  Future<List<Post>> fetchPosts({DocumentSnapshot? lastDocument}) async {
    Query query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('post_images/$fileName.jpg');

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      // ignore: avoid_print
      print("Resim yükleme hatası: $e");
      return '';
    }
  }

  Future<void> addPost(String title, String description, String imageUrl,
      String publisherId) async {
    await _firestore.collection('posts').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'publisherId': publisherId,
      'createdAt': FieldValue.serverTimestamp(),
      'likeCount': 0,
      'commentCount': 0,
    });
  }

  Future<DocumentSnapshot?> getLastDocumentFromQuery(
      {DocumentSnapshot? lastDocument}) async {
    Query query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.last;
    }
    return null;
  }
}
