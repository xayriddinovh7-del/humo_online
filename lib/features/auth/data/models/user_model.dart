import '../../domain/entities/user_entity.dart';

/// API javobidan UserEntity ga konvertatsiya qiluvchi model
/// Backend: { id (UUID), fullName, email, role, avatar }
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.avatarUrl,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: (json['fullName'] ?? json['name'] ?? '') as String,
      email: json['email'] as String,
      role: (json['role'] as String? ?? 'STUDENT').toUpperCase(),
      avatarUrl: json['avatar'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': name,
        'email': email,
        'role': role,
        'avatar': avatarUrl,
        'createdAt': createdAt?.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
