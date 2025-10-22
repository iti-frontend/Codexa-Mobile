class StudentUser {
  StudentUser({
      this.token, 
      this.student,});

  StudentUser.fromJson(dynamic json) {
    token = json['token'];
    student = json['student'] != null ? Student.fromJson(json['student']) : null;
  }
  String? token;
  Student? student;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = token;
    if (student != null) {
      map['student'] = student?.toJson();
    }
    return map;
  }

}

class Student {
  Student({
      this.name, 
      this.email, 
      this.password, 
      this.profileImage, 
      this.role, 
      this.authProvider, 
      this.googleId, 
      this.githubId, 
      this.emailVerified, 
      this.purchasedCourses, 
      this.enrolledCourses, 
      this.id, 
      this.notes, 
      this.progress, 
      this.createdAt, 
      this.updatedAt, 
      this.v,});

  Student.fromJson(dynamic json) {
    name = json['name'];
    email = json['email'];
    password = json['password'];
    profileImage = json['profileImage'];
    role = json['role'];
    authProvider = json['authProvider'];
    googleId = json['googleId'];
    githubId = json['githubId'];
    emailVerified = json['emailVerified'];
    if (json['purchasedCourses'] != null) {
      purchasedCourses = [];
      json['purchasedCourses'].forEach((v) {
        purchasedCourses?.add(Dynamic.fromJson(v));
      });
    }
    if (json['enrolledCourses'] != null) {
      enrolledCourses = [];
      json['enrolledCourses'].forEach((v) {
        enrolledCourses?.add(Dynamic.fromJson(v));
      });
    }
    id = json['_id'];
    if (json['notes'] != null) {
      notes = [];
      json['notes'].forEach((v) {
        notes?.add(Dynamic.fromJson(v));
      });
    }
    if (json['progress'] != null) {
      progress = [];
      json['progress'].forEach((v) {
        progress?.add(Dynamic.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? name;
  String? email;
  String? password;
  String? profileImage;
  String? role;
  String? authProvider;
  dynamic googleId;
  dynamic githubId;
  bool? emailVerified;
  List<dynamic>? purchasedCourses;
  List<dynamic>? enrolledCourses;
  String? id;
  List<dynamic>? notes;
  List<dynamic>? progress;
  String? createdAt;
  String? updatedAt;
  int? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['email'] = email;
    map['password'] = password;
    map['profileImage'] = profileImage;
    map['role'] = role;
    map['authProvider'] = authProvider;
    map['googleId'] = googleId;
    map['githubId'] = githubId;
    map['emailVerified'] = emailVerified;
    if (purchasedCourses != null) {
      map['purchasedCourses'] = purchasedCourses?.map((v) => v.toJson()).toList();
    }
    if (enrolledCourses != null) {
      map['enrolledCourses'] = enrolledCourses?.map((v) => v.toJson()).toList();
    }
    map['_id'] = id;
    if (notes != null) {
      map['notes'] = notes?.map((v) => v.toJson()).toList();
    }
    if (progress != null) {
      map['progress'] = progress?.map((v) => v.toJson()).toList();
    }
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }

}