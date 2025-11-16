import 'package:codexa_mobile/Data/Repository/coumminty_repo_impl.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Domain/usecases/community/add_comment_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/add_reply_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/create_post_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/get_all_posts_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/toggle_like_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/post_details_screen.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_cubit/community_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_cubit/community_states.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class CommunityInstructorTab extends StatelessWidget {
  const CommunityInstructorTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final token = userProvider.token ?? "";
    final repository = CommunityRepoImpl(ApiManager(token: token));

    return BlocProvider(
      create: (_) => CommunityCubit(
        getAllPostsUseCase: GetAllPostsUseCase(repository),
        createPostUseCase: CreatePostUseCase(repository),
        toggleLikeUseCase: ToggleLikeUseCase(repository),
        addCommentUseCase: AddCommentUseCase(repository),
        addReplyUseCase: AddReplyUseCase(repository),
      )..fetchPosts(),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<CommunityCubit, CommunityState>(
            buildWhen: (prev, curr) =>
                curr is CommunityLoaded ||
                curr is CommunityError ||
                curr is CommunityInitial,
            builder: (context, state) {
              List posts = [];
              if (state is CommunityLoaded) {
                posts = state.posts;
              }

              if (state is CommunityError) {
                return Center(child: Text(state.message));
              }

              if (posts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostCard(
                    post: post,
                    currentToken: token,
                    onLike: () {
                      context
                          .read<CommunityCubit>()
                          .toggleLike(post.id!, token);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailsScreen(postId: post.id!),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
