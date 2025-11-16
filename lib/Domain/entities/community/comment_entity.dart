class CommunityCommentEntity {
  final String? id;
  final String? authorName;
  final String? authorImage;
  final String? content;

  CommunityCommentEntity({
    this.id,
    this.authorName,
    this.authorImage,
    this.content,
  });

  CommunityCommentEntity copyWith({
    String? id,
    String? authorName,
    String? authorImage,
    String? content,
  }) {
    return CommunityCommentEntity(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
      content: content ?? this.content,
    );
  }
}
