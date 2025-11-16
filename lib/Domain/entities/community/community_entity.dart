import 'package:codexa_mobile/Domain/entities/community/author_entity.dart';
import 'package:codexa_mobile/Domain/entities/community/comment_entity.dart';

class CommunityEntity {
  final String? id;
  final CommunityAuthorEntity? author;
  final String? authorType;
  final String? type;
  final String? content;
  final String? image;
  final String? linkUrl;
  final List<dynamic>? attachments;
  final dynamic poll;
  final List<String>? likes;
  final List<CommunityCommentEntity>? comments;
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

  CommunityEntity copyWith({
    String? id,
    CommunityAuthorEntity? author,
    String? authorType,
    String? type,
    String? content,
    String? image,
    String? linkUrl,
    List<dynamic>? attachments,
    dynamic poll,
    List<String>? likes,
    List<CommunityCommentEntity>? comments,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) {
    return CommunityEntity(
      id: id ?? this.id,
      author: author ?? this.author,
      authorType: authorType ?? this.authorType,
      type: type ?? this.type,
      content: content ?? this.content,
      image: image ?? this.image,
      linkUrl: linkUrl ?? this.linkUrl,
      attachments: attachments ?? this.attachments,
      poll: poll ?? this.poll,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }
}
