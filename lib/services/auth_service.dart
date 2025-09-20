import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/utils/constants.dart';
import 'package:social_app/models/login_request_model.dart';

class AuthService {
  static Future<UserModel> login(String username, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(
              LoginRequestModel(
                username: username,
                password: password,
              ).toJson(),
            ),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> logout() async {
    // SharedPreferences will be used to store the token
  }
}
