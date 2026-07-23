import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/auth_user_model.dart';

class AuthSignupException implements Exception {
  const AuthSignupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({String assetPath = 'assets/data/staff_auth.json'})
    : _assetPath = assetPath;

  final String _assetPath;
  List<AuthUserModel>? _cachedUsers;

  Future<List<AuthUserModel>> _loadUsers() async {
    if (_cachedUsers != null) {
      return _cachedUsers!;
    }

    final rawJson = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    final users = (decoded['users'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              AuthUserModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

    _cachedUsers = users;
    return users;
  }

  Future<AuthUserModel?> login({
    required String email,
    required String password,
  }) async {
    final users = await _loadUsers();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    for (final user in users) {
      if (user.email.trim().toLowerCase() == normalizedEmail &&
          user.password == normalizedPassword) {
        return user;
      }
    }

    return null;
  }

  Future<AuthUserModel> signup({
    required String email,
    required String password,
    required String name,
    required String staffId,
  }) async {
    final users = await _loadUsers();
    final normalizedEmail = email.trim().toLowerCase();

    final emailExists = users.any(
      (user) => user.email.trim().toLowerCase() == normalizedEmail,
    );
    if (emailExists) {
      throw const AuthSignupException(
        'An account with this email already exists.',
      );
    }

    final newUser = AuthUserModel(
      email: email.trim(),
      password: password,
      name: name.trim(),
      staffId: staffId.trim(),
    );

    _cachedUsers = [...users, newUser];
    return newUser;
  }
}
