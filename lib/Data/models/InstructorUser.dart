class InstructorUser {
  InstructorUser({
    this.token,
    this.instructor,
  });

  String? token;
  Instructor? instructor;

  InstructorUser.fromJson(dynamic json) {
    token = json['token'];
    instructor = json['instructor'] != null ? Instructor.fromJson(json['instructor']) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = token;
    if (instructor != null) {
      map['instructor'] = instructor?.toJson();
    }
    return map;
  }
}

class Instructor {
  Instructor({
    this.name,
    this.email,
    this.profileImage,
    this.role,
    this.isAdmin,
    this.isActive,
    this.emailVerified,
    this.authProvider,
    this.googleId,
    this.githubId,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  String? name;
  String? email;
  String? profileImage;
  String? role;
  bool? isAdmin;
  bool? isActive;
  bool? emailVerified;
  String? authProvider;
  dynamic googleId;
  dynamic githubId;
  String? id;
  String? createdAt;
  String? updatedAt;
  int? v;

  Instructor.fromJson(dynamic json) {
    name = json['name'];
    email = json['email'];
    profileImage = json['profileImage'];
    role = json['role'];
    isAdmin = json['isAdmin'];
    isActive = json['isActive'];
    emailVerified = json['emailVerified'];
    authProvider = json['authProvider'];
    googleId = json['googleId'];
    githubId = json['githubId'];
    id = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['email'] = email;
    map['profileImage'] = profileImage;
    map['role'] = role;
    map['isAdmin'] = isAdmin;
    map['isActive'] = isActive;
    map['emailVerified'] = emailVerified;
    map['authProvider'] = authProvider;
    map['googleId'] = googleId;
    map['githubId'] = githubId;
    map['_id'] = id;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }
}
