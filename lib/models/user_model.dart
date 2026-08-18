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
  final List<String> followers;
  final int followersCount;
  final String? fcmToken;

  // Volunteer-specific fields
  final String? bio;
  final List<String> interests;
  final List<String> skills;
  final Timestamp? birthDate;
  final String? education;
  final String? city;
  final int xp;

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
    this.followers = const [],
    this.followersCount = 0,
    this.fcmToken,
    this.bio,
    this.interests = const [],
    this.skills = const [],
    this.birthDate,
    this.education,
    this.city,
    this.xp = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    return UserModel(
      uid: data['uid'] as String? ?? doc.id,
      email: data['email'] as String? ?? '',
      userType: data['userType'] as String? ?? 'volunteer',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      name: data['name'] as String?,
      surname: data['surname'] as String?,
      stkName: data['stkName'] as String?,
      imageUrl: data['imageUrl'] as String?,
      description: data['description'] as String?,
      location: data['location'] as String?,
      vision: data['vision'] as String?,
      mission: data['mission'] as String?,
      phone: data['phone'] as String?,
      following: List<String>.from(data['following'] ?? []),
      followers: List<String>.from(data['followers'] ?? []),
      followersCount: (data['followersCount'] as num?)?.toInt() ?? 0,
      fcmToken: data['fcmToken'] as String?,
      bio: data['bio'] as String?,
      interests: List<String>.from(data['interests'] ?? []),
      skills: List<String>.from(data['skills'] ?? []),
      birthDate: data['birthDate'] as Timestamp?,
      education: data['education'] as String?,
      city: data['city'] as String?,
      xp: (data['xp'] as num?)?.toInt() ?? 0,
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
      'followers': followers,
      'followersCount': followersCount,
      'fcmToken': fcmToken,
      'bio': bio,
      'interests': interests,
      'skills': skills,
      'birthDate': birthDate,
      'education': education,
      'city': city,
      'xp': xp,
    };
  }

  bool get isNgo => userType == 'ngo';
  bool get isVolunteer => userType == 'volunteer';

  /// STK profilinin anasayfaya (Kurumlar sekmesi dahil) erişebilmesi için
  /// gerekli tüm alanların doldurulup doldurulmadığını kontrol eder.
  /// Gönüllüler için her zaman true döner.
  bool get isNgoProfileComplete {
    if (!isNgo) return true;
    return (description?.trim().isNotEmpty ?? false) &&
        (location?.trim().isNotEmpty ?? false) &&
        (phone?.trim().isNotEmpty ?? false) &&
        (vision?.trim().isNotEmpty ?? false) &&
        (mission?.trim().isNotEmpty ?? false);
  }

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
