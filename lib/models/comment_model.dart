class CommentModel {
  final int id;
  final String body;
  final int postId;
  final int likes;
  final CommentUserModel user;

  CommentModel({
    required this.id,
    required this.body,
    required this.postId,
    required this.likes,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      body: json['body'] ?? '',
      postId: json['postId'] ?? 0,
      likes: json['likes'] ?? 0,
      user: CommentUserModel(
        id: json['user']['id'] ?? 0,
        username: json['user']['username'] ?? '',
        fullName: json['user']['fullName'] ?? '',
      ),
    );
  }
}

class CommentUserModel {
  int id;
  String username;
  String fullName;

  CommentUserModel({
    required this.id,
    required this.username,
    required this.fullName,
  });
}
