enum UserRole {
  owner,
  staff,
}

class User {
  final String id;
  final String name;
  final String username;
  final String password;
  final UserRole role;
  final String phone;
  final bool isActive;
  final String recoveryCode;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    this.phone = '',
    this.isActive = true,
    this.recoveryCode = '',
  });

  bool get isOwner => role == UserRole.owner;
  bool get isStaff => role == UserRole.staff;

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    UserRole? role,
    String? phone,
    bool? isActive,
    String? recoveryCode,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      recoveryCode: recoveryCode ?? this.recoveryCode,
    );
  }
}

