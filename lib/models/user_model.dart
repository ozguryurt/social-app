class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String gender;
  final String image;
  final String token;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.gender,
    required this.image,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['firstName'] ?? '',
      gender: json['gender'] ?? '',
      image: json['image'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
