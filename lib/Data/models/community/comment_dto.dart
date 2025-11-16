
import 'package:codexa_mobile/Domain/entities/community/comment_entity.dart';

class CommunityCommentDto extends CommunityCommentEntity {
  CommunityCommentDto({
    super.id,
    super.authorName,
    super.authorImage,
    super.content,
  });

  factory CommunityCommentDto.fromJson(Map<String, dynamic> json) {
    return CommunityCommentDto(
      id: json['_id']?.toString(),
      authorName: json['authorName']?.toString(),
      authorImage: json['authorImage']?.toString(),
      content: json['content']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'authorName': authorName,
      'authorImage': authorImage,
      'content': content,
    };
  }
}
