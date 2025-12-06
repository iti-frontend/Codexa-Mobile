import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/comment_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/likes_cubit.dart';
import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/post_details_screen.dart';
import 'package:codexa_mobile/Ui/utils/widgets/post_card.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_states/posts_state.dart';
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

class CommunityInstructorTab extends StatefulWidget {
  const CommunityInstructorTab({super.key});

  @override
  State<CommunityInstructorTab> createState() => _CommunityInstructorTabState();
}

class _CommunityInstructorTabState extends State<CommunityInstructorTab> {
  late LocalizationService _localizationService;
  late generated.S _translations;

  @override
  void initState() {
    super.initState();
    _initializeLocalization();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityPostsCubit>().fetchPosts();
    });
  }

  void _initializeLocalization() {
    _localizationService = LocalizationService();
    _translations = generated.S(_localizationService.locale);
    _localizationService.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {
        _translations = generated.S(_localizationService.locale);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<CommunityPostsCubit, CommunityPostsState>(
          buildWhen: (prev, curr) => prev != curr,
          builder: (context, state) {
            if (state is CommunityPostsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CommunityPostsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<CommunityPostsCubit>().fetchPosts(),
                      icon: const Icon(Icons.refresh),
                      label: Text(_translations.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is CommunityPostsLoaded) {
              final posts = state.posts;

              if (posts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.post_add,
                          size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _translations.noPostsYet,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _translations.beFirstToShare,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

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

            return Center(child: Text(_translations.noPostsAvailable));
          },
        ),
      ],
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

  @override
  void dispose() {
    _localizationService.removeListener(_onLocaleChanged);
    super.dispose();
  }
}