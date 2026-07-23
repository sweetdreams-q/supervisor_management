import 'package:equatable/equatable.dart';

import 'interest_model.dart';
import 'project_idea_model.dart';
import 'staff_model.dart';

class StaffBrowseModel extends Equatable {
  const StaffBrowseModel({
    required this.staffProfile,
    required this.areasOfInterest,
    required this.projectIdeas,
  });

  final StaffModel staffProfile;
  final List<InterestModel> areasOfInterest;
  final List<ProjectIdeaModel> projectIdeas;

  factory StaffBrowseModel.fromJson(Map<String, dynamic> json) {
    return StaffBrowseModel(
      staffProfile: StaffModel.fromJson(Map<String, dynamic>.from(json['staffProfile'] as Map)),
      areasOfInterest: (json['areasOfInterest'] as List<dynamic>? ?? const [])
          .map((item) => InterestModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      projectIdeas: (json['projectIdeas'] as List<dynamic>? ?? const [])
          .map((item) => ProjectIdeaModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffProfile': staffProfile.toJson(),
      'areasOfInterest': areasOfInterest.map((interest) => interest.toJson()).toList(),
      'projectIdeas': projectIdeas.map((project) => project.toJson()).toList(),
    };
  }

  StaffBrowseModel copyWith({
    StaffModel? staffProfile,
    List<InterestModel>? areasOfInterest,
    List<ProjectIdeaModel>? projectIdeas,
  }) {
    return StaffBrowseModel(
      staffProfile: staffProfile ?? this.staffProfile,
      areasOfInterest: areasOfInterest ?? this.areasOfInterest,
      projectIdeas: projectIdeas ?? this.projectIdeas,
    );
  }

  @override
  List<Object?> get props => [staffProfile, areasOfInterest, projectIdeas];
}
