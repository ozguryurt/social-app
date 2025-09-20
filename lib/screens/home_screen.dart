import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/post_model.dart';
import 'package:social_app/models/posts_response.dart';
import 'package:social_app/services/post_service.dart';
import 'package:social_app/widgets/post_card.dart';
import 'package:social_app/widgets/comments_bottom_sheet.dart';
import 'package:social_app/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PostsResponse? postsData;
  final int itemsPerPage = 5;
  int currentPage = 1;
  bool isLoading = false;
  String? errorMessage;

  Future<void> _loadPosts() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedPostsData = await PostService.getPosts(
        page: currentPage,
        limit: itemsPerPage,
      );
      if (mounted) {
        setState(() {
          postsData = loadedPostsData;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void handleReaction(PostModel post, String reactionType) async {
    try {
      final res = await PostService.reactToPost(post, reactionType);
      setState(() {
        postsData!.posts[postsData!.posts.indexOf(post)].reactions.likes =
            res.reactions.likes;
        postsData!.posts[postsData!.posts.indexOf(post)].reactions.dislikes =
            res.reactions.dislikes;
      });
      debugPrint('Reaction response: ${res.reactions.likes}');
    } catch (e) {
      print('Reaction error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Eğer user giriş yapmamışsa loading göster
    if (!authProvider.isLoggedIn) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // User null ise loading göster
    if (authProvider.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Social App"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Welcome Message
              if (authProvider.user != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(authProvider.user!.image),
                        child: authProvider.user!.image.isEmpty
                            ? Icon(Icons.person, size: 30, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${authProvider.user!.firstName}!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '@${authProvider.user!.username}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (errorMessage != null)
                Center(child: Text(errorMessage!)),
              if (postsData != null && postsData!.posts.isNotEmpty)
                Expanded(
                  child: postsData!.posts.isEmpty
                      ? const Center(child: Text('No posts found'))
                      : ListView.builder(
                          itemCount: postsData!.posts.length,
                          itemBuilder: (context, index) {
                            return PostCard(
                              post: postsData!.posts[index],
                              onLike: () => handleReaction(
                                postsData!.posts[index],
                                'like',
                              ),
                              onDislike: () => handleReaction(
                                postsData!.posts[index],
                                'dislike',
                              ),
                              onComment: () => showCommentsBottomSheet(
                                context,
                                postsData!.posts[index],
                              ),
                            );
                          },
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
