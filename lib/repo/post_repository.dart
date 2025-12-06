import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gonullunet_app/models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _limit =
      10; //10 adet post yüklensin diye kararlaştırdım, performans için

  Future<List<Post>> fetchPosts({DocumentSnapshot? lastDocument}) async {
    Query query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(_limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  Future<void> addPost(String title, String description, String imageUrl,
      String publisherId) async {
    await _firestore.collection('posts').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'publisherId': publisherId,
      'createdAt': Timestamp.now(),
      'likeCount': 0,
      'commentCount': 0,
    });
  }

  Future<DocumentSnapshot?> getLastDocumentFromQuery(
      {DocumentSnapshot? lastDocument}) async {
    Query query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(_limit);

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
