// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String token;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userType;
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.createdAt,
    required this.updatedAt,
    required this.userType,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userType,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userType: userType ?? this.userType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userType': userType,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      userType: map['userType'] ?? ''
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, token: $token, createdAt: $createdAt, updatedAt: $updatedAt, userType: $userType)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.token == token &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.userType == userType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      token.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      userType.hashCode;
  }
}
