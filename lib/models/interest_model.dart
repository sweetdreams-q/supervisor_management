import 'package:equatable/equatable.dart';

class InterestModel extends Equatable {
  const InterestModel({
    required this.id,
    required this.staffId,
    required this.title,
    required this.description,
  });

  final String id;
  final String staffId;
  final String title;
  final String description;

  factory InterestModel.fromJson(Map<String, dynamic> json) {
    return InterestModel(
      id: json['id']?.toString() ?? '',
      staffId: json['staffId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'title': title,
      'description': description,
    };
  }

  InterestModel copyWith({
    String? id,
    String? staffId,
    String? title,
    String? description,
  }) {
    return InterestModel(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, staffId, title, description];
}
