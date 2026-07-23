import 'package:flutter/foundation.dart';

import '../models/auth_user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  AuthUserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthUserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(email: email, password: password);
      if (user == null) {
        _errorMessage = 'Invalid staff email or password.';
        return false;
      }

      _currentUser = user;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
