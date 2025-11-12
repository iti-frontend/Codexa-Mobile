class InstructorCourseDto {
  InstructorCourseDto({
      this.id, 
      this.title, 
      this.description, 
      this.category, 
      this.price, 
      this.instructor, 
      this.videos, 
      this.coverImage, 
      this.level, 
      this.status, 
      this.prerequisites, 
      this.enrolledStudents, 
      this.progress, 
      this.createdAt, 
      this.updatedAt,});

  InstructorCourseDto.fromJson(dynamic json) {
    id = json['_id'];
    title = json['title'];
    description = json['description'];
    category = json['category'];
    price = json['price'];
    instructor = json['instructor'] != null ? Instructor.fromJson(json['instructor']) : null;
    if (json['videos'] != null) {
      videos = [];
      json['videos'].forEach((v) {
        videos?.add(Videos.fromJson(v));
      });
    }
    coverImage = json['coverImage'] != null ? CoverImage.fromJson(json['coverImage']) : null;
    level = json['level'];
    status = json['status'];
    prerequisites = json['prerequisites'];
    if (json['enrolledStudents'] != null) {
      enrolledStudents = [];
      json['enrolledStudents'].forEach((v) {
        enrolledStudents?.add(Dynamic.fromJson(v));
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
  }
  String? id;
  String? title;
  String? description;
  String? category;
  int? price;
  Instructor? instructor;
  List<Videos>? videos;
  CoverImage? coverImage;
  String? level;
  String? status;
  String? prerequisites;
  List<dynamic>? enrolledStudents;
  List<dynamic>? progress;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['category'] = category;
    map['price'] = price;
    if (instructor != null) {
      map['instructor'] = instructor?.toJson();
    }
    if (videos != null) {
      map['videos'] = videos?.map((v) => v.toJson()).toList();
    }
    if (coverImage != null) {
      map['coverImage'] = coverImage?.toJson();
    }
    map['level'] = level;
    map['status'] = status;
    map['prerequisites'] = prerequisites;
    if (enrolledStudents != null) {
      map['enrolledStudents'] = enrolledStudents?.map((v) => v.toJson()).toList();
    }
    if (progress != null) {
      map['progress'] = progress?.map((v) => v.toJson()).toList();
    }
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    return map;
  }

}

class CoverImage {
  CoverImage({
      this.url, 
      this.publicId,});

  CoverImage.fromJson(dynamic json) {
    url = json['url'];
    publicId = json['public_id'];
  }
  String? url;
  String? publicId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['public_id'] = publicId;
    return map;
  }

}

class Videos {
  Videos({
      this.id, 
      this.title, 
      this.url, 
      this.publicId,});

  Videos.fromJson(dynamic json) {
    id = json['_id'];
    title = json['title'];
    url = json['url'];
    publicId = json['public_id'];
  }
  String? id;
  String? title;
  String? url;
  String? publicId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['title'] = title;
    map['url'] = url;
    map['public_id'] = publicId;
    return map;
  }

}

class Instructor {
  Instructor({
      this.id, 
      this.name, 
      this.profileImage,});

  Instructor.fromJson(dynamic json) {
    id = json['_id'];
    name = json['name'];
    profileImage = json['profileImage'];
  }
  String? id;
  String? name;
  String? profileImage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['profileImage'] = profileImage;
    return map;
  }

}