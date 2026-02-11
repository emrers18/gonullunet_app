import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final Timestamp createdAt;
  final int likeCount;
  final int commentCount;
  final String publisherId;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.publisherId,
  });

  String get timeAgo {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    return timeago.format(createdAt.toDate(), locale: 'tr');
  }

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Post(
        id: doc.id,
        title: data['title'] ?? 'Başlık yok.',
        description: data['description'] ?? 'Açıklama yok.',
        imageUrl: data['imageUrl'] ?? '',
        createdAt: data['createdAt'] ?? Timestamp.now(),
        likeCount: data['likeCount'] ?? 0,
        commentCount: data['commentCount'] ?? 0,
        publisherId: data['publisherId'] ?? 'Bilinmiyor');
  }
}
