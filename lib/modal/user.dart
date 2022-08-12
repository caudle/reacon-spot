// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid; //unique uid
  final String phone;
  final String email;
  final String name;
  final String password;
  final String dp;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  final DateTime createdAt;
  final String userType;
  User({
    required this.uid,
    required this.phone,
    required this.email,
    required this.name,
    required this.password,
    required this.dp,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.createdAt,
    required this.userType,
  });

  User copyWith({
    String? uid,
    String? phone,
    String? email,
    String? name,
    String? password,
    String? dp,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    String? userType,
  }) {
    return User(
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      dp: dp ?? this.dp,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      userType: userType ?? this.userType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'phone': phone,
      'email': email,
      'name': name,
      'password': password,
      'dp': dp,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt,
      'userType': userType,
    };
  }

// to local storage db
  Map<String, dynamic> toDbMap() {
    return <String, dynamic>{
      'uid': uid,
      'phone': phone,
      'email': email,
      'name': name,
      'password': password,
      'dp': dp,
      'isEmailVerified': isEmailVerified ? 1 : 0,
      'isPhoneVerified': isPhoneVerified ? 1 : 0,
      'createdAt': createdAt.toString(),
      'userType': userType,
    };
  }

// to firestore db
  Map<String, dynamic> toSnapshotMap() {
    return <String, dynamic>{
      'phone': phone,
      'email': email,
      'name': name,
      'password': password,
      'dp': dp,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt,
      'userType': userType,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      password: map['password'] as String,
      dp: map['dp'] as String,
      isEmailVerified: map['isEmailVerified'] as bool,
      isPhoneVerified: map['isPhoneVerified'] as bool,
      createdAt: map['createdAt'] as DateTime,
      userType: map['userType'] as String,
    );
  }

  factory User.fromDbMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      password: map['password'] as String,
      dp: map['dp'] as String,
      isEmailVerified: map['isEmailVerified'] == 1 ? true : false,
      isPhoneVerified: map['isPhoneVerified'] == 1 ? true : false,
      createdAt: DateTime.parse(map['createdAt']),
      userType: map['userType'] as String,
    );
  }

  factory User.fromSnapshotMap(Map<String, dynamic> map, String uid) {
    return User(
      uid: uid,
      phone: map['phone'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      password: map['password'] as String,
      dp: map['dp'] as String,
      isEmailVerified: map['isEmailVerified'] as bool,
      isPhoneVerified: map['isPhoneVerified'] as bool,
      createdAt: map['createdAt'] as DateTime,
      userType: map['userType'] as String,
    );
  }

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    return User.fromSnapshotMap(
        snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(uid: $uid, phone: $phone, email: $email, name: $name, password: $password, dp: $dp, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, createdAt: $createdAt, userType: $userType)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.phone == phone &&
        other.email == email &&
        other.name == name &&
        other.password == password &&
        other.dp == dp &&
        other.isEmailVerified == isEmailVerified &&
        other.isPhoneVerified == isPhoneVerified &&
        other.createdAt == createdAt &&
        other.userType == userType;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        name.hashCode ^
        password.hashCode ^
        dp.hashCode ^
        isEmailVerified.hashCode ^
        isPhoneVerified.hashCode ^
        createdAt.hashCode ^
        userType.hashCode;
  }
}
