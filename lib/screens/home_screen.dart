import 'package:flutter/material.dart';
import 'package:social_app/models/posts_response.dart';
import 'package:social_app/services/post_service.dart';
import 'package:social_app/widgets/post_card.dart';

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
      final loadedPostsData = await PostService.getPosts(page: currentPage, limit: itemsPerPage);
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
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Social App"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Center(child: Text(errorMessage!)),
            if (postsData != null && postsData!.posts.isNotEmpty)
              Expanded(
                child: postsData!.posts.isEmpty
                          ? const Center(
                              child: Text('No posts found'),
                            )
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
    );
  }
}