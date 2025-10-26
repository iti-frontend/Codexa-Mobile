import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';

class InstructorDto extends InstructorEntity {
  InstructorDto({
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
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory InstructorDto.fromJson(Map<String, dynamic> json) {
    return InstructorDto(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      role: json['role'],
      authProvider: json['authProvider'],
      googleId: json['googleId'],
      githubId: json['githubId'],
      emailVerified: json['emailVerified'],
      isAdmin: json['isAdmin'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
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
    map['isAdmin'] = isAdmin;
    map['isActive'] = isActive;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }

  dynamic googleId;
  dynamic githubId;
  String? createdAt;
  String? updatedAt;
  int? v;
}

class InstructorUserDto {
  InstructorUserDto({
    this.token,
    this.instructor,
  });

  factory InstructorUserDto.fromJson(Map<String, dynamic> json) {
    return InstructorUserDto(
      token: json['token'],
      instructor: json['instructor'] != null
          ? InstructorDto.fromJson(json['instructor'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = token;
    if (instructor != null) {
      map['instructor'] = instructor?.toJson();
    }
    return map;
  }

  String? token;
  InstructorDto? instructor;
}
