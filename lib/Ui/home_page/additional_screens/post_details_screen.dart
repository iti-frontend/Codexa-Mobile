import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_cubit/community_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_cubit/community_states.dart';
import 'package:provider/provider.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final token = userProvider.token ?? "";
    final name = userProvider.user?["name"] ?? "User";
    final image = userProvider.user?["profileImage"] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: BlocBuilder<CommunityCubit, CommunityState>(
        builder: (context, state) {
          if (state is CommunityLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CommunityError) {
            return Center(child: Text(state.message));
          }

          if (state is CommunityLoaded) {
            final post = state.posts.firstWhere((p) => p.id == widget.postId);

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        post.content ?? "",
                        style: const TextStyle(fontSize: 18, height: 1.4),
                      ),
                      if ((post.image ?? "").isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              post.image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        "Comments",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...?post.comments?.map(
                        (c) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    NetworkImage(c.authorImage ?? ""),
                                backgroundColor: Colors.grey.shade300,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.authorName ?? "User",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(c.content ?? ""),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if ((post.comments ?? []).isEmpty)
                        const Text(
                          "No comments yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),

                /// Add comment
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: "Write a comment...",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () {
                          final text = commentController.text.trim();
                          if (text.isEmpty) return;

                          // استخدام الـ token عند إرسال comment
                          context.read<CommunityCubit>().addComment(
                                widget.postId,
                                text,
                              );

                          commentController.clear();
                        },
                      ),
                    ],
                  ),
                )
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
