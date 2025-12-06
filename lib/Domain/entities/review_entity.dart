/// ReviewEntity - Domain entity for course/instructor reviews
class ReviewEntity {
  final String? id;
  final String? itemId;
  final String? itemType; // "Course" or "Instructor"
  final ReviewAuthorEntity? author;
  final int? rating; // 1-5
  final String? text;
  final String? createdAt;
  final String? updatedAt;

  ReviewEntity({
    this.id,
    this.itemId,
    this.itemType,
    this.author,
    this.rating,
    this.text,
    this.createdAt,
    this.updatedAt,
  });
}

/// ReviewAuthorEntity - Author info for a review
class ReviewAuthorEntity {
  final String? id;
  final String? name;
  final String? profileImage;

  ReviewAuthorEntity({
    this.id,
    this.name,
    this.profileImage,
  });
}

/// AverageRatingEntity - Average rating statistics
class AverageRatingEntity {
  final double? average;
  final int? count;

  AverageRatingEntity({
    this.average,
    this.count,
  });
}
