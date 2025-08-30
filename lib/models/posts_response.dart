import 'package:social_app/models/post_model.dart';

class PostsResponse {
  final List<PostModel> posts;
  final int total;

  PostsResponse({required this.posts, required this.total});

  factory PostsResponse.fromJson(Map<String, dynamic> json) {
    return PostsResponse(
      posts: (json['posts'] as List<dynamic>?)
              ?.map((e) => PostModel.fromJson(e))
              .toList() ?? [],
      total: json['total'] ?? 0,
    );
  }
}