import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String userType;
  final Timestamp createdAt;

  final String? name;
  final String? surname;

  final String? stkName;
  final String? imageUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.userType,
    required this.createdAt,
    this.name,
    this.surname,
    this.stkName,
    this.imageUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;

    return UserModel(
      uid: data['uid'],
      email: data['email'],
      userType: data['userType'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      name: data['name'],
      surname: data['surname'],
      stkName: data['stkName'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'userType': userType,
      'createdAt': createdAt,
      'name': name,
      'surname': surname,
      'stkName': stkName,
      'imageUrl': imageUrl,
    };
  }

  bool get isNgo => userType == 'ngo';
  bool get isVolunteer => userType == 'volunteer';

  String get displayName {
    if (isNgo) {
      return stkName ?? 'STK Adı';
    } else {
      return '${name ?? 'İsim'} ${surname ?? 'Soyisim'}'.trim();
    }
  }

  String get initials {
    if (isNgo && stkName != null && stkName!.isNotEmpty) {
      var parts = stkName!.split(' ');
      if (parts.length > 1) {
        return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
      }
      return stkName![0].toUpperCase();
    } else if (isVolunteer &&
        name != null &&
        surname != null &&
        name!.isNotEmpty &&
        surname!.isNotEmpty) {
      return name![0].toUpperCase() + surname![0].toUpperCase();
    }
    return '?';
  }
}
