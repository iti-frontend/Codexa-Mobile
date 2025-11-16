import 'package:codexa_mobile/Domain/entities/community/community_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class EditReplyUseCase {
  final CommunityRepo repo;

  EditReplyUseCase(this.repo);

  Future<Either<Failures, CommunityEntity>> call(
    String postId,
    String commentId,
    String replyId,
    Map<String, dynamic> body,
  ) {
    return repo.editReply(postId, commentId, replyId, body);
  }
}
