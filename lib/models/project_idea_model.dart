import 'package:equatable/equatable.dart';

class ProjectIdeaModel extends Equatable {
  const ProjectIdeaModel({
    required this.id,
    required this.staffId,
    required this.title,
    required this.description,
    required this.tags,
  });

  final String id;
  final String staffId;
  final String title;
  final String description;
  final String tags;

  factory ProjectIdeaModel.fromJson(Map<String, dynamic> json) {
    return ProjectIdeaModel(
      id: json['id']?.toString() ?? '',
      staffId: json['staffId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      tags: json['tags']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'title': title,
      'description': description,
      'tags': tags,
    };
  }

  ProjectIdeaModel copyWith({
    String? id,
    String? staffId,
    String? title,
    String? description,
    String? tags,
  }) {
    return ProjectIdeaModel(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [id, staffId, title, description, tags];
}
