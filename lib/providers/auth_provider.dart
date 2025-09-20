import 'package:flutter/material.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final authResult = await AuthService.login(username, password);
      _user = authResult;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Önce loading state'i true yap ki UI güncellensin
      _isLoading = true;
      notifyListeners();

      // Kısa bir delay ekle
      await Future.delayed(const Duration(milliseconds: 50));

      // State'i tamamen temizle
      _user = null;
      _error = null;
      _isLoading = false;

      // UI'ı güncelle
      notifyListeners();

      // UI'ın güncellenmesini bekle
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      print('Logout error in provider: $e');
      // Hata olsa bile state'i temizle
      _user = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
