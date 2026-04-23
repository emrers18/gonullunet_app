import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class ApplicationModel {
  final String id;
  final String userId;
  final String eventId;
  final String
      status; // 'pending' (bekliyor), 'approved' (onaylandı), 'rejected' (red)
  final Timestamp appliedAt;

  final String? userName;
  final String? userSurname;
  final String? userImageUrl;

  final int? xp;

  ApplicationModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.status,
    required this.appliedAt,
    this.userName,
    this.userSurname,
    this.userImageUrl,
    this.xp,
  });

  String get timeAgo {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    return timeago.format(appliedAt.toDate(), locale: 'tr');
  }

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      eventId: data['eventId'] ?? '',
      status: data['status'] ?? 'pending',
      appliedAt: data['appliedAt'] ?? Timestamp.now(),
    );
  }

  ApplicationModel copyWithUser({
    String? name,
    String? surname,
    String? imageUrl,
    int? xp,
  }) {
    return ApplicationModel(
      id: id,
      userId: userId,
      eventId: eventId,
      status: status,
      appliedAt: appliedAt,
      userName: name,
      userSurname: surname,
      userImageUrl: imageUrl,
      xp: xp,
    );
  }
}
