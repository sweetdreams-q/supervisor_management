import 'package:equatable/equatable.dart';

class AuthUserModel extends Equatable {
  const AuthUserModel({
    required this.email,
    required this.password,
    required this.name,
  });

  final String email;
  final String password;
  final String name;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }

  AuthUserModel copyWith({
    String? email,
    String? password,
    String? name,
  }) {
    return AuthUserModel(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [email, password, name];
}
