import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:social_app/models/comments_response.dart';
import 'package:social_app/models/post_model.dart';
import 'package:social_app/models/posts_response.dart';
import 'dart:convert';
import 'package:social_app/utils/constants.dart';

class PostService {
  static Future<PostsResponse> getPosts({int page = 1, int limit = 10}) async {
    try {
      final skip = (page - 1) * limit;
      final uri = Uri.parse('$baseUrl/posts?skip=$skip&limit=$limit');
      final response = await http.get(uri).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final postsResponse = PostsResponse.fromJson(data);

        // Her post için comment sayısını al
        final postsWithCommentCount = await Future.wait(
          postsResponse.posts.map((post) async {
            try {
              final commentCount = await getPostCommentCount(post.id);
              return PostModel(
                id: post.id,
                title: post.title,
                body: post.body,
                tags: post.tags,
                reactions: post.reactions,
                views: post.views,
                userId: post.userId,
                commentCount: commentCount,
              );
            } catch (e) {
              // Hata durumunda comment sayısını 0 olarak ayarla
              return PostModel(
                id: post.id,
                title: post.title,
                body: post.body,
                tags: post.tags,
                reactions: post.reactions,
                views: post.views,
                userId: post.userId,
                commentCount: 0,
              );
            }
          }),
        );

        return PostsResponse(
          posts: postsWithCommentCount,
          total: postsResponse.total,
        );
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<PostModel> reactToPost(
    PostModel post,
    String reactionType,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/posts/${post.id}');
      final body = {
        'reactions': {
          'likes': post.reactions.likes + (reactionType == 'like' ? 1 : 0),
          'dislikes':
              post.reactions.dislikes + (reactionType == 'dislike' ? 1 : 0),
        },
      };

      final response = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 25));

      debugPrint('Reaction response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PostModel.fromJson(data);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<CommentsResponse> getPostComments(int postId) async {
    try {
      final uri = Uri.parse('$baseUrl/comments/post/$postId');
      final response = await http.get(uri).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CommentsResponse.fromJson(data);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Post'a ait comment sayısını getir
  static Future<int> getPostCommentCount(int postId) async {
    try {
      final uri = Uri.parse('$baseUrl/comments/post/$postId');
      final response = await http.get(uri).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final commentsResponse = CommentsResponse.fromJson(data);
        return commentsResponse.total;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}
