import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime? lastSeen;
  final String? fcmToken;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.lastSeen,
    this.fcmToken,
  });

  factory UserModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    DateTime? lastSeen;

    final value = map['lastSeen'];

    if (value is Timestamp) {
      lastSeen = value.toDate();
    } else if (value is DateTime) {
      lastSeen = value;
    } else if (value is int) {
      lastSeen = DateTime.fromMillisecondsSinceEpoch(value);
    }

    return UserModel(
      id: id,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString(),
      lastSeen: lastSeen,
      fcmToken: map['fcmToken']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'lastSeen': lastSeen,
      'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? lastSeen,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      lastSeen: lastSeen ?? this.lastSeen,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}