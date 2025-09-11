class PostModel {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final Reactions reactions;
  final int views;
  final int userId;

  PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.reactions,
    required this.views,
    required this.userId,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      reactions: Reactions(
        likes: json['reactions']['likes'] ?? 0,
        dislikes: json['reactions']['dislikes'] ?? 0,
      ),
      views: json['views'] ?? 0,
      userId: json['userId'] ?? 0,
    );
  }
}

class Reactions {
  int likes;
  int dislikes;

  Reactions({required this.likes, required this.dislikes});
}
