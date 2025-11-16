import 'package:codexa_mobile/Domain/entities/community/author_entity.dart';

class CommunityAuthorDto extends CommunityAuthorEntity {
  CommunityAuthorDto({
    super.id,
    super.name,
    super.profileImage,
  });

  factory CommunityAuthorDto.fromJson(Map<String, dynamic> json) {
    return CommunityAuthorDto(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      profileImage: json['profileImage']?.toString(),
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
