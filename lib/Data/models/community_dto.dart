import '../../Domain/entities/community_entity.dart';

class CommunityDto extends CommunityEntity {
  CommunityDto({
    String? id,
    AuthorEntity? author,
    String? authorType,
    String? type,
    String? content,
    String? image,
    dynamic linkUrl,
    List<dynamic>? attachments,
    dynamic poll,
    List<LikesEntity>? likes,
    List<CommentsEntity>? comments,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) : super(
          id: id,
          author: author,
          authorType: authorType,
          type: type,
          content: content,
          image: image,
          linkUrl: linkUrl,
          attachments: attachments,
          poll: poll,
          likes: likes,
          comments: comments,
          createdAt: createdAt,
          updatedAt: updatedAt,
          v: v,
        );

  factory CommunityDto.fromJson(dynamic json) {
    return CommunityDto(
      id: json['_id'],
      author:
          json['author'] != null ? AuthorDto.fromJson(json['author']) : null,
      authorType: json['authorType'],
      type: json['type'],
      content: json['content'],
      image: json['image'],
      linkUrl: json['linkUrl'],
      attachments: json['attachments'], // لو عايز تحول لكل عنصر DynamicDto
      poll: json['poll'],
      likes: json['likes'] != null
          ? List<LikesEntity>.from(
              json['likes'].map((x) => LikesDto.fromJson(x)))
          : null,
      comments: json['comments'] != null
          ? List<CommentsEntity>.from(
              json['comments'].map((x) => CommentsDto.fromJson(x)))
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author': author != null ? (author as AuthorDto).toJson() : null,
      'authorType': authorType,
      'type': type,
      'content': content,
      'image': image,
      'linkUrl': linkUrl,
      'attachments': attachments,
      'poll': poll,
      'likes': likes?.map((x) => (x as LikesDto).toJson()).toList(),
      'comments': comments?.map((x) => (x as CommentsDto).toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}

class CommentsDto extends CommentsEntity {
  CommentsDto({
    UserEntity? user,
    String? userType,
    String? text,
    String? id,
    String? createdAt,
    List<dynamic>? replies,
  }) : super(
          user: user,
          userType: userType,
          text: text,
          id: id,
          createdAt: createdAt,
          replies: replies,
        );

  factory CommentsDto.fromJson(dynamic json) {
    if (json == null) {
      return CommentsDto(); // يرجع كومنت فاضي لو الـ json نفسه null
    }

    return CommentsDto(
      user: (json['user'] != null && json['user'] is Map)
          ? UserDto.fromJson(json['user'])
          : null,
      userType: json['userType'],
      text: json['text'],
      id: json['_id'],
      createdAt: json['createdAt'],
      replies: json['replies'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user':
          user != null && user is UserDto ? (user as UserDto).toJson() : null,
      'userType': userType,
      'text': text,
      '_id': id,
      'createdAt': createdAt,
      'replies': replies,
    };
  }
}

class UserDto extends UserEntity {
  UserDto({
    String? id,
    String? name,
    String? profileImage,
  }) : super(id: id, name: name, profileImage: profileImage);

  factory UserDto.fromJson(dynamic json) {
    if (json == null) {
      return UserDto(); // fallback لو الـ user نفسه null
    }

    return UserDto(
      id: json['_id'],
      name: json['name'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'profileImage': profileImage,
    };
  }
}

class LikesDto extends LikesEntity {
  LikesDto({
    String? user,
    String? userType,
    String? id,
  }) : super(user: user, userType: userType, id: id);

  factory LikesDto.fromJson(dynamic json) {
    return LikesDto(
      user: json['user'],
      userType: json['userType'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'userType': userType,
      '_id': id,
    };
  }
}

class AuthorDto extends AuthorEntity {
  AuthorDto({
    String? id,
    String? name,
    String? profileImage,
  }) : super(id: id, name: name, profileImage: profileImage);

  factory AuthorDto.fromJson(dynamic json) {
    return AuthorDto(
      id: json['_id'],
      name: json['name'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'profileImage': profileImage,
    };
  }
}
