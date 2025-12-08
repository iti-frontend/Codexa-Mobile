import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/cubits/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/cubits/comment_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/cubits/likes_cubit.dart';
import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/post_details_screen.dart';
import 'package:codexa_mobile/Ui/utils/widgets/post_card.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/states/posts_state.dart';
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

/// Unified Community Tab for both Student and Instructor roles
class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
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
  void dispose() {
    _localizationService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = _localizationService.isRTL();

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: BlocBuilder<CommunityPostsCubit, CommunityPostsState>(
        buildWhen: (prev, curr) => prev != curr,
        builder: (context, state) {
          if (state is CommunityPostsLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).progressIndicatorTheme.color,
              ),
            );
          }

          if (state is CommunityPostsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: isRTL ? TextAlign.right : TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<CommunityPostsCubit>().fetchPosts(),
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    label: Text(
                      _translations.retry,
                      style: TextStyle(
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).progressIndicatorTheme.color,
                    ),
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
                    Icon(
                      Icons.post_add,
                      size: 80,
                      color: Theme.of(context).dividerColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _translations.noPostsYet,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).dividerColor,
                      ),
                      textAlign: isRTL ? TextAlign.right : TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _translations.beFirstToShare,
                      style: TextStyle(
                        color: Theme.of(context).dividerColor.withOpacity(0.7),
                      ),
                      textAlign: isRTL ? TextAlign.right : TextAlign.center,
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

          return Center(
            child: Text(
              _translations.noPostsAvailable,
              style: TextStyle(
                color: Theme.of(context).dividerColor,
              ),
              textAlign: isRTL ? TextAlign.right : TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, CommunityEntity post) {
    return PostCard(
      post: post,
      onTap: () {
        final commentCubit = context.read<CommentCubit>();
        final likeCubit = context.read<LikeCubit>();
        final postsCubit = context.read<CommunityPostsCubit>();
        final isRTL = _localizationService.isRTL();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Directionality(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: commentCubit),
                  BlocProvider.value(value: likeCubit),
                  BlocProvider.value(value: postsCubit),
                ],
                child: PostDetailsScreen(post: post),
              ),
            ),
          ),
        );
      },
    );
  }
}
