class InstructorEntity {
  final String? id;
  final String? name;
  final String? email;
  final String? profileImage;
  final String? role;
  final bool? isAdmin;
  final bool? isActive;
  final bool? emailVerified;
  final String? authProvider;
  final String? token;

  InstructorEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.role,
    required this.isAdmin,
    required this.isActive,
    required this.emailVerified,
    required this.authProvider,
    required this.token,
  });

  factory InstructorEntity.fromJson(Map<String, dynamic> json) {
    return InstructorEntity(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      role: json['role'],
      isAdmin: json['isAdmin'],
      isActive: json['isActive'],
      emailVerified: json['emailVerified'],
      authProvider: json['authProvider'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'role': role,
      'isAdmin': isAdmin,
      'isActive': isActive,
      'emailVerified': emailVerified,
      'authProvider': authProvider,
      'token': token,
    };
  }
}
