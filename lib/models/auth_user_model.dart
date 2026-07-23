import 'package:equatable/equatable.dart';

class AuthUserModel extends Equatable {
  const AuthUserModel({
    required this.email,
    required this.password,
    required this.name,
    required this.staffId,
  });

  final String email;
  final String password;
  final String name;
  final String staffId;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      staffId: json['staffId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'staffId': staffId,
    };
  }

  AuthUserModel copyWith({
    String? email,
    String? password,
    String? name,
    String? staffId,
  }) {
    return AuthUserModel(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      staffId: staffId ?? this.staffId,
    );
  }

  @override
  List<Object?> get props => [email, password, name, staffId];
}
