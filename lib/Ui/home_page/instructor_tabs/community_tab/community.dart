import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/comment_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/likes_cubit.dart';
import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/post_details_screen.dart';
import 'package:codexa_mobile/Ui/utils/widgets/post_card.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_states/posts_state.dart';

class CommunityInstructorTab extends StatefulWidget {
  const CommunityInstructorTab({super.key});

  @override
  State<CommunityInstructorTab> createState() => _CommunityInstructorTabState();
}

class _CommunityInstructorTabState extends State<CommunityInstructorTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityPostsCubit>().fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityPostsCubit, CommunityPostsState>(
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        if (state is CommunityPostsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CommunityPostsError) {
          return Center(child: Text(state.message));
        }

        if (state is CommunityPostsLoaded) {
          final posts = state.posts;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: isWide
                        ? Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: posts.map((post) {
                              return SizedBox(
                                width: 480,
                                child: _buildPostCard(context, post),
                              );
                            }).toList(),
                          )
                        : Column(
                            children: posts.map((post) {
                              return _buildPostCard(context, post);
                            }).toList(),
                          ),
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: Text("No posts available"));
      },
    );
  }

  Widget _buildPostCard(BuildContext context, CommunityEntity post) {
    return PostCard(
      post: post,
      onTap: () {
        final commentCubit = context.read<CommentCubit>();
        final likeCubit = context.read<LikeCubit>();
        final postsCubit = context.read<CommunityPostsCubit>();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: commentCubit),
                BlocProvider.value(value: likeCubit),
                BlocProvider.value(value: postsCubit),
              ],
              child: PostDetailsScreen(post: post),
            ),
          ),
        );
      },
    );
  }
}
