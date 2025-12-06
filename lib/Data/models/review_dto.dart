import 'package:codexa_mobile/Domain/entities/review_entity.dart';

/// DTO for Review - extends ReviewEntity
class ReviewDto extends ReviewEntity {
  ReviewDto({
    String? id,
    String? itemId,
    String? itemType,
    ReviewAuthorEntity? author,
    int? rating,
    String? text,
    String? createdAt,
    String? updatedAt,
  }) : super(
          id: id,
          itemId: itemId,
          itemType: itemType,
          author: author,
          rating: rating,
          text: text,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ReviewDto.fromJson(dynamic json) {
    if (json == null) return ReviewDto();

    return ReviewDto(
      id: json['_id'],
      itemId: json['itemId'],
      itemType: json['itemType'],
      author: json['author'] != null
          ? ReviewAuthorDto.fromJson(json['author'])
          : null,
      rating: json['rating'],
      text: json['text'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'itemId': itemId,
      'itemType': itemType,
      'author': author != null ? (author as ReviewAuthorDto).toJson() : null,
      'rating': rating,
      'text': text,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

/// DTO for Review Author - extends ReviewAuthorEntity
class ReviewAuthorDto extends ReviewAuthorEntity {
  ReviewAuthorDto({
    String? id,
    String? name,
    String? profileImage,
  }) : super(
          id: id,
          name: name,
          profileImage: profileImage,
        );

  factory ReviewAuthorDto.fromJson(dynamic json) {
    if (json == null) return ReviewAuthorDto();

    return ReviewAuthorDto(
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

/// DTO for Average Rating - extends AverageRatingEntity
class AverageRatingDto extends AverageRatingEntity {
  AverageRatingDto({
    double? average,
    int? count,
  }) : super(
          average: average,
          count: count,
        );

  factory AverageRatingDto.fromJson(dynamic json) {
    if (json == null) return AverageRatingDto();

    return AverageRatingDto(
      average: (json['average'] as num?)?.toDouble(),
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'count': count,
    };
  }
}

/// DTO for paginated reviews list response
class ReviewsListDto {
  final int? total;
  final int? page;
  final int? pageSize;
  final List<ReviewDto>? items;

  ReviewsListDto({
    this.total,
    this.page,
    this.pageSize,
    this.items,
  });

  factory ReviewsListDto.fromJson(dynamic json) {
    if (json == null) return ReviewsListDto();

    return ReviewsListDto(
      total: json['total'],
      page: json['page'],
      pageSize: json['pageSize'],
      items: json['items'] != null
          ? List<ReviewDto>.from(
              json['items'].map((x) => ReviewDto.fromJson(x)))
          : null,
    );
  }
}
