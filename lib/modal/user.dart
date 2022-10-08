import 'dart:convert';

class User {
  final String userId; //unique userId
  final String phone;
  final String email;
  final String name;
  final String password;
  final String dp;
  final String type;
  final bool isemailVerified;
  final bool isphoneVerified;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.phone,
    required this.email,
    required this.name,
    required this.password,
    required this.dp,
    required this.isemailVerified,
    required this.isphoneVerified,
    required this.createdAt,
    required this.type,
  });

  User copyWith({
    String? userId,
    String? phone,
    String? email,
    String? name,
    String? password,
    String? dp,
    bool? isemailVerified,
    bool? isphoneVerified,
    DateTime? createdAt,
    String? type,
  }) {
    return User(
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      dp: dp ?? this.dp,
      isemailVerified: isemailVerified ?? this.isemailVerified,
      isphoneVerified: isphoneVerified ?? this.isphoneVerified,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'phone': phone,
      'email': email,
      'name': name,
      'password': password,
      'dp': dp,
      'isemailVerified': isemailVerified,
      'isphoneVerified': isphoneVerified,
      'createdAt': createdAt.toString(),
      'type': type,
    };
  }

// to local storage db
  Map<String, dynamic> toDbMap() {
    return <String, dynamic>{
      'userId': userId,
      'phone': phone,
      'email': email,
      'name': name,
      'dp': dp,
      'isemailVerified': isemailVerified ? 1 : 0,
      'isphoneVerified': isphoneVerified ? 1 : 0,
      'createdAt': createdAt.toString(),
      'type': type,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['_id'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      password: map['password'] as String,
      dp: map['dp'] ?? '',
      isemailVerified: map['isemailVerified'] as bool,
      isphoneVerified: map['isphoneVerified'] as bool,
      createdAt: DateTime.parse(map['createdAt']),
      type: map['type'] as String,
    );
  }

  factory User.fromDbMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      password: "",
      dp: map['dp'] as String,
      isemailVerified: map['isemailVerified'] == 1 ? true : false,
      isphoneVerified: map['isphoneVerified'] == 1 ? true : false,
      createdAt: DateTime.parse(map['createdAt']),
      type: map['type'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(userId: $userId, phone: $phone, email: $email, name: $name, password: $password, dp: $dp, isemailVerified: $isemailVerified, isphoneVerified: $isphoneVerified, createdAt: $createdAt, type: $type)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.phone == phone &&
        other.email == email &&
        other.name == name &&
        other.password == password &&
        other.dp == dp &&
        other.isemailVerified == isemailVerified &&
        other.isphoneVerified == isphoneVerified &&
        other.createdAt == createdAt &&
        other.type == type;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        name.hashCode ^
        password.hashCode ^
        dp.hashCode ^
        isemailVerified.hashCode ^
        isphoneVerified.hashCode ^
        createdAt.hashCode ^
        type.hashCode;
  }
}
