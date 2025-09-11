import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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
        return PostsResponse.fromJson(data);
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
}
