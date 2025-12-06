class CommunityEntity {
  final String? id;
  final AuthorEntity? author;
  final String? authorType;
  final String? type;
  final String? content;
  final String? image;
  final dynamic linkUrl;
  final List<dynamic>? attachments;
  final dynamic poll;
  List<LikesEntity>? likes;
  List<CommentsEntity>? comments;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  CommunityEntity({
    this.id,
    this.author,
    this.authorType,
    this.type,
    this.content,
    this.image,
    this.linkUrl,
    this.attachments,
    this.poll,
    this.likes,
    this.comments,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory CommunityEntity.fromDto(dynamic dto) {
    return CommunityEntity(
      id: dto.id,
      author: dto.author != null
          ? AuthorEntity(
              id: dto.author.id,
              name: dto.author.name,
              profileImage: dto.author.profileImage,
            )
          : null,
      authorType: dto.authorType,
      type: dto.type,
      content: dto.content,
      image: dto.image,
      linkUrl: dto.linkUrl,
      attachments: dto.attachments,
      poll: dto.poll,
      likes: dto.likes
          ?.map<LikesEntity>((l) => LikesEntity(
                user: l.user,
                userType: l.userType,
                id: l.id,
              ))
          .toList(),
      comments: dto.comments
          ?.map<CommentsEntity>((c) => CommentsEntity(
                user: c.user != null
                    ? UserEntity(
                        id: c.user.id,
                        name: c.user.name,
                        profileImage: c.user.profileImage,
                      )
                    : null,
                userType: c.userType,
                text: c.text,
                id: c.id,
                createdAt: c.createdAt,
                replies: c.replies,
              ))
          .toList(),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      v: dto.v,
    );
  }
}

class CommentsEntity {
  final UserEntity? user;
  final String? userType;
  final String? text;
  final String? id;
  final String? createdAt;
  List<dynamic>? replies; // لو عايز ممكن تعمل RepliesEntity

  CommentsEntity({
    this.user,
    this.userType,
    this.text,
    this.id,
    this.createdAt,
    this.replies,
  });
}

class UserEntity {
  final String? id;
  final String? name;
  final String? profileImage;

  UserEntity({
    this.id,
    this.name,
    this.profileImage,
  });
}

class LikesEntity {
  final String? user;
  final String? userType;
  final String? id;

  LikesEntity({
    this.user,
    this.userType,
    this.id,
  });
}

class AuthorEntity {
  final String? id;
  final String? name;
  final String? profileImage;

  AuthorEntity({
    this.id,
    this.name,
    this.profileImage,
  });
}
