/// Foydalanuvchi entity — domain qatlami
/// Backend UUID (String) ishlatadi
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role; // 'STUDENT' | 'TEACHER' | 'ADMIN'
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.createdAt,
  });

  bool get isStudent => role == 'STUDENT';
  bool get isTeacher => role == 'TEACHER' || role == 'ADMIN';
  bool get isAdmin => role == 'ADMIN';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserEntity(id: $id, name: $name, role: $role)';
}
