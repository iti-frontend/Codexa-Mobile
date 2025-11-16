import 'package:codexa_mobile/Data/models/community/author_dto.dart';
import 'package:codexa_mobile/Data/models/community/comment_dto.dart';
import 'package:codexa_mobile/Domain/entities/community/community_entity.dart';

class CommunityDto extends CommunityEntity {
  CommunityDto({
    super.id,
    super.author,
    super.authorType,
    super.type,
    super.content,
    super.image,
    super.linkUrl,
    super.attachments,
    super.poll,
    super.likes,
    super.comments,
    super.createdAt,
    super.updatedAt,
    super.v,
  });

  factory CommunityDto.fromJson(Map<String, dynamic> json) {
    return CommunityDto(
      id: json['_id']?.toString(),
      author: json['author'] != null
          ? CommunityAuthorDto.fromJson(json['author'])
          : null,
      authorType: json['authorType']?.toString(),
      type: json['type']?.toString(),
      content: json['content']?.toString(),
      image: json['image']?.toString(),
      linkUrl: json['linkUrl']?.toString(),
      attachments: json['attachments'] as List<dynamic>? ?? [],
      poll: json['poll'], // handle later if needed
      likes: (json['likes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      comments: (json['comments'] as List<dynamic>?)
          ?.map((item) => CommunityCommentDto.fromJson(item))
          .toList(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      v: json['__v'] is int ? json['__v'] : int.tryParse('${json['__v']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author': author is CommunityAuthorDto
          ? (author as CommunityAuthorDto).toJson()
          : null,
      'authorType': authorType,
      'type': type,
      'content': content,
      'image': image,
      'linkUrl': linkUrl,
      'attachments': attachments,
      'poll': poll,
      'likes': likes,
      'comments': comments
              ?.map((e) => e is CommunityCommentDto ? e.toJson() : null)
              .toList() ??
          [],
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
