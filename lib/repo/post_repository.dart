import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gonullunet_app/models/post_model.dart';
import 'package:gonullunet_app/models/comment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gonullunet_app/services/image_compress_service.dart';
import 'package:gonullunet_app/services/functions_service.dart';
import 'package:gonullunet_app/utils/app_messages.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FunctionsService _functionsService = FunctionsService();

  static const int limit = 5;

  /// Postları çeker. [publisherType] filtresi varsa sadece o türdeki postlar gelir.
  /// Dönen tuple: (postlar listesi, son DocumentSnapshot veya null)
  Future<({List<Post> posts, DocumentSnapshot? lastDocument})> fetchPosts({
    DocumentSnapshot? lastDocument,
    String? publisherType,
  }) async {
    Query query = _firestore.collection('posts');

    if (publisherType != null) {
      query = query.where('publisherType', isEqualTo: publisherType);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final posts = snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    return (posts: posts, lastDocument: lastDoc);
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
      throw Exception(AppErrorCodes.imageUpload);
    }
  }

  Future<void> addPost(String title, String description, String imageUrl,
      String publisherId) async {
    // Post oluşturma işlemini Cloud Functions üzerinden yapıyoruz (limit kontrolü için)
    await _functionsService.createPost(
      title: title,
      description: description,
      imageUrl: imageUrl,
    );
  }

  Future<void> toggleLikePost(String postId) async {
    // Cloud Function uzerinden yapilir — cift begeni onlenir, sayac guvende
    await _functionsService.toggleLikePost(postId: postId);
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
    // Yorum ekleme + rate limiting + uzunluk kontrolu Cloud Function uzerinden yapilir.
    await _functionsService.addComment(postId: postId, content: content);
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

  /// Yorumu siler. Sahiplik kontrolu Cloud Function tarafinda yapilir.
  Future<void> deleteComment(String postId, String commentId) async {
    await _functionsService.deleteComment(postId: postId, commentId: commentId);
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

  /// Gönderi başlığını ve açıklamasını günceller.
  /// Sahiplik kontrolü Cloud Function tarafında yapılır.
  Future<void> updatePost(
      String postId, String title, String description) async {
    await _functionsService.updatePost(
      postId: postId,
      title: title,
      description: description,
    );
  }

  /// Gonderiyi Firestore'dan siler ve Storage gorselini temizler.
  /// Sahiplik kontrolu ve Storage silme Cloud Function uzerinden yapilir.
  Future<void> deletePost(String postId, String imageUrl) async {
    await _functionsService.deletePost(postId: postId);
  }
}
