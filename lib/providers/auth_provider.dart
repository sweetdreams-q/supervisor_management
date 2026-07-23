import 'package:flutter/foundation.dart';

import '../models/auth_user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/error_messages.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  AuthUserModel? _currentUser;
  final ApiService _apiService = ApiService();

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
      logAppError(runtimeType.toString(), error);
      _errorMessage = userFriendlyMessageForError(
        error,
        fallback: 'Unable to log in right now. Please try again.',
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final staffRecords = await _apiService.getStaff();
      if (staffRecords.isEmpty) {
        _errorMessage =
            'No staff records exist yet. Please add staff records first.';
        return false;
      }

      // Bind dummy accounts to the first staff profile so dashboard data can load.
      final linkedStaffId = staffRecords.first.id;
      final user = await _authService.signup(
        email: email,
        password: password,
        name: name,
        staffId: linkedStaffId,
      );

      _currentUser = user;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } on AuthSignupException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error) {
      logAppError(runtimeType.toString(), error);
      _errorMessage = userFriendlyMessageForError(
        error,
        fallback: 'Unable to create account right now. Please try again.',
      );
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
