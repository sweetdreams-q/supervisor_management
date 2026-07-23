import 'package:flutter/foundation.dart';

import '../services/api_service.dart';
import '../services/error_messages.dart';

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
      logAppError(runtimeType.toString(), error);
      _setError(_friendlyErrorMessage(error));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> runGuardedVoid(Future<void> Function() action) async {
    _setLoading(true);
    clearError();

    try {
      await action();
      return true;
    } catch (error) {
      logAppError(runtimeType.toString(), error);
      _setError(_friendlyErrorMessage(error));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _friendlyErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return userFriendlyMessageForError(error);
  }
}
