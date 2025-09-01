import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/posts_response.dart';
import 'package:social_app/services/post_service.dart';
import 'package:social_app/widgets/post_card.dart';
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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                try {
                  await authProvider.logout();
                  // Router will automatically redirect to the login screen
                } catch (e) {
                  print('Logout error: $e');
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red[600])),
                  ],
                ),
              ),
            ],
            child: CircleAvatar(
              backgroundImage: NetworkImage(authProvider.user?.image ?? ''),
              child: authProvider.user?.image == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
        ],
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
                            return PostCard(post: postsData!.posts[index]);
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
