import 'package:codexa_mobile/Domain/entities/student_entity.dart';

class StudentDto extends StudentEntity {
  StudentDto({
    super.id,
    super.name,
    super.email,
    super.profileImage,
    super.role,
    super.isAdmin,
    super.isActive,
    super.emailVerified,
    super.authProvider,
    super.token,
    this.googleId,
    this.githubId,
    this.purchasedCourses,
    this.enrolledCourses,
    this.notes,
    this.progress,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory StudentDto.fromJson(Map<String, dynamic> json) {
    return StudentDto(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      role: json['role'],
      authProvider: json['authProvider'],
      googleId: json['googleId'],
      githubId: json['githubId'],
      emailVerified: json['emailVerified'],
      purchasedCourses: List<dynamic>.from(json['purchasedCourses'] ?? []),
      enrolledCourses: List<dynamic>.from(json['enrolledCourses'] ?? []),
      notes: List<dynamic>.from(json['notes'] ?? []),
      progress: List<dynamic>.from(json['progress'] ?? []),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      isAdmin: json['isAdmin'],
      isActive: json['isActive'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['profileImage'] = profileImage;
    map['role'] = role;
    map['authProvider'] = authProvider;
    map['googleId'] = googleId;
    map['githubId'] = githubId;
    map['emailVerified'] = emailVerified;
    map['purchasedCourses'] = purchasedCourses;
    map['enrolledCourses'] = enrolledCourses;
    map['notes'] = notes;
    map['progress'] = progress;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    map['isAdmin'] = isAdmin;
    map['isActive'] = isActive;
    return map;
  }

  String? googleId;
  String? githubId;
  List<dynamic>? purchasedCourses;
  List<dynamic>? enrolledCourses;
  List<dynamic>? notes;
  List<dynamic>? progress;
  String? createdAt;
  String? updatedAt;
  int? v;
}

class StudentUserDto {
  StudentUserDto({
    this.token,
    this.student,
  });

  factory StudentUserDto.fromJson(Map<String, dynamic> json) {
    return StudentUserDto(
      token: json['token'],
      student:
          json['student'] != null ? StudentDto.fromJson(json['student']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = token;
    if (student != null) {
      map['student'] = student?.toJson();
    }
    return map;
  }

  String? token;
  StudentDto? student;
}
