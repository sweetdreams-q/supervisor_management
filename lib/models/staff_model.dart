import 'package:equatable/equatable.dart';

class StaffModel extends Equatable {
  const StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.bio,
  });

  final String id;
  final String name;
  final String email;
  final String department;
  final String bio;

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'bio': bio,
    };
  }

  StaffModel copyWith({
    String? id,
    String? name,
    String? email,
    String? department,
    String? bio,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      bio: bio ?? this.bio,
    );
  }

  @override
  List<Object?> get props => [id, name, email, department, bio];
}
