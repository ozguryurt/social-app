import 'package:social_app/models/comment_model.dart';

class CommentsResponse {
  final List<CommentModel> comments;
  final int total;

  CommentsResponse({required this.comments, required this.total});

  factory CommentsResponse.fromJson(Map<String, dynamic> json) {
    return CommentsResponse(
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => CommentModel.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}
