import 'package:flutter/foundation.dart';

abstract class BaseApiProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<T?> runGuarded<T>(Future<T> Function() action) async {
    _setLoading(true);
    clearError();

    try {
      return await action();
    } catch (error) {
      _setError(error.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }
}
