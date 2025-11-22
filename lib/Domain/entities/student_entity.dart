class StudentEntity {
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

  StudentEntity({
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
