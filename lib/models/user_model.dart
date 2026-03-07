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
  final String? description;
  final String? location;
  final String? vision;
  final String? mission;
  final String? phone;
  final List<String> following;
  final int followersCount;

  // Volunteer-specific fields
  final String? bio;
  final List<String> interests;
  final List<String> skills;
  final Timestamp? birthDate;
  final String? education;
  final String? city;

  UserModel({
    required this.uid,
    required this.email,
    required this.userType,
    required this.createdAt,
    this.name,
    this.surname,
    this.stkName,
    this.imageUrl,
    this.description,
    this.location,
    this.vision,
    this.mission,
    this.phone,
    this.following = const [],
    this.followersCount = 0,
    this.bio,
    this.interests = const [],
    this.skills = const [],
    this.birthDate,
    this.education,
    this.city,
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
      description: data['description'],
      location: data['location'],
      vision: data['vision'],
      mission: data['mission'],
      phone: data['phone'],
      following: List<String>.from(data['following'] ?? []),
      followersCount: data['followersCount'] ?? 0,
      bio: data['bio'],
      interests: List<String>.from(data['interests'] ?? []),
      skills: List<String>.from(data['skills'] ?? []),
      birthDate: data['birthDate'],
      education: data['education'],
      city: data['city'],
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
      'description': description,
      'location': location,
      'vision': vision,
      'mission': mission,
      'phone': phone,
      'following': following,
      'followersCount': followersCount,
      'bio': bio,
      'interests': interests,
      'skills': skills,
      'birthDate': birthDate,
      'education': education,
      'city': city,
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

  // Profil sayfasındaki baş harfler
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
