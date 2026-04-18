import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gonullunet_app/models/post_model.dart';
import 'package:gonullunet_app/models/comment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gonullunet_app/services/image_compress_service.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  /// Görseli 1080x1080'e sıkıştırarak Firebase Storage'a yükler.
  /// Sıkıştırma başarısız olursa orijinal dosyayı yükler (fallback).
  Future<String> uploadImage(File imageFile) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference ref = _storage.ref().child('post_images/$fileName.jpg');

      // 1080x1080 hedefli sıkıştırma (%85 kalite, kare crop yok — oran korunur)
      final compressed = await ImageCompressService.compressFile(
        imageFile,
        minWidth: 1080,
        minHeight: 1080,
        quality: 85,
      );

      TaskSnapshot snapshot;
      if (compressed != null) {
        // Sıkıştırılmış baytları yükle
        snapshot = await ref.putData(
          compressed,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // Fallback: sıkıştırılamadıysa orijinali yükle
        snapshot = await ref.putFile(imageFile);
      }

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Resim yükleme hatası: $e");
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

  Future<void> toggleLikePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Oturum açılmamış.");

    final postRef = _firestore.collection('posts').doc(postId);
    final likeRef =
        _firestore.collection('post_likes').doc("${postId}_${user.uid}");

    return _firestore.runTransaction((transaction) async {
      final likeSnapshot = await transaction.get(likeRef);

      if (likeSnapshot.exists) {
        // Beğeniyi kaldır
        transaction.delete(likeRef);
        transaction.update(postRef, {'likeCount': FieldValue.increment(-1)});
      } else {
        // Beğen
        transaction.set(likeRef, {
          'postId': postId,
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(postRef, {'likeCount': FieldValue.increment(1)});
      }
    });
  }

  Future<bool> isPostLiked(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final likeDoc = await _firestore
        .collection('post_likes')
        .doc("${postId}_${user.uid}")
        .get();
    return likeDoc.exists;
  }

  Future<void> addComment(String postId, String content) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Oturum açılmamış.");

    final postRef = _firestore.collection('posts').doc(postId);
    final commentRef =
        _firestore.collection('posts').doc(postId).collection('comments').doc();

    return _firestore.runTransaction((transaction) async {
      transaction.set(commentRef, {
        'postId': postId,
        'userId': user.uid,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.update(postRef, {'commentCount': FieldValue.increment(1)});
    });
  }

  Stream<List<Comment>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
    });
  }

  /// Kullanıcının kendi gönderilerini çeker (publisherId'ye göre)
  Future<List<Post>> fetchMyPosts(String userId) async {
    final snapshot = await _firestore
        .collection('posts')
        .where('publisherId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  /// Gönderi başlığını ve açıklamasını günceller
  Future<void> updatePost(
      String postId, String title, String description) async {
    await _firestore.collection('posts').doc(postId).update({
      'title': title,
      'description': description,
    });
  }

  /// Gönderiyi ve varsa fotoğrafını Storage'dan siler
  Future<void> deletePost(String postId, String imageUrl) async {
    final batch = _firestore.batch();
    final postRef = _firestore.collection('posts').doc(postId);
    batch.delete(postRef);
    await batch.commit();

    // Storage'daki resmi de sil (varsa)
    if (imageUrl.isNotEmpty) {
      try {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      } catch (_) {
        // Görsel silinememişse sessizce geç
      }
    }
  }
}
