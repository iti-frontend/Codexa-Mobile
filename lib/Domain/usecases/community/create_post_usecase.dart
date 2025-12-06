import 'dart:io';

import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class CreatePostUseCase {
  final CommunityRepo repo;

  CreatePostUseCase(this.repo);

  Future<Either<Failures, CommunityEntity>> call({
    required String content,
    File? imageFile,
    dynamic linkUrl,
    List<dynamic>? attachments,
  }) {
    return repo.createPost(
      content: content,
      imageFile: imageFile,
      linkUrl: linkUrl,
      attachments: attachments,
    );
  }
}
