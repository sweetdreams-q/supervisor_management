import '../models/project_idea_model.dart';
import '../services/api_service.dart';
import 'base_api_provider.dart';

class ProjectProvider extends BaseApiProvider {
  ProjectProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  List<ProjectIdeaModel> _projects = const [];
  String? _staffId;

  List<ProjectIdeaModel> get projects => _projects;
  String? get staffId => _staffId;

  Future<void> loadData({required String staffId}) async {
    _staffId = staffId;
    await runGuarded(() async {
      _projects = await _apiService.getProjects(staffId);
      notifyListeners();
    });
  }

  Future<ProjectIdeaModel?> addProject({
    required String staffId,
    required String title,
    required String description,
    required String tags,
  }) async {
    final createdProject = await runGuarded(() => _apiService.addProject(
          staffId: staffId,
          title: title,
          description: description,
          tags: tags,
        ));

    if (createdProject != null) {
      if (_staffId == staffId) {
        _projects = [..._projects, createdProject];
      }
      notifyListeners();
    }

    return createdProject;
  }

  Future<ProjectIdeaModel?> updateProject({
    required String id,
    required String staffId,
    required String title,
    required String description,
    required String tags,
  }) async {
    final updatedProject = await runGuarded(() => _apiService.updateProject(
          id: id,
          staffId: staffId,
          title: title,
          description: description,
          tags: tags,
        ));

    if (updatedProject != null) {
      _projects = _projects.map((project) => project.id == updatedProject.id ? updatedProject : project).toList();
      notifyListeners();
    }

    return updatedProject;
  }

  Future<void> deleteProject(String id) async {
    final deleted = await runGuarded(() => _apiService.deleteProject(id));

    if (deleted != null) {
      _projects = _projects.where((project) => project.id != id).toList();
      notifyListeners();
    }
  }
}
