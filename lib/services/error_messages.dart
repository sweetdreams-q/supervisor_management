import 'package:flutter/foundation.dart';

String userFriendlyMessageForError(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is FriendlyAppException) {
    return error.message;
  }

  final message = error.toString();

  if (message.contains('SocketException') ||
      message.contains('ClientException')) {
    return 'Server unavailable. Check your connection and try again.';
  }

  if (message.contains('TimeoutException')) {
    return 'The request timed out. Please try again.';
  }

  if (message.contains('FormatException')) {
    return 'Received an invalid response from the server.';
  }

  return fallback;
}

void logAppError(String source, Object error, [StackTrace? stackTrace]) {
  debugPrint('[$source] $error');
  if (stackTrace != null) {
    debugPrint(stackTrace.toString());
  }
}

class FriendlyAppException implements Exception {
  const FriendlyAppException(this.message);

  final String message;

  @override
  String toString() => message;
}
