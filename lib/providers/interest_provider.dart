import '../models/interest_model.dart';
import '../services/api_service.dart';
import 'base_api_provider.dart';

class InterestProvider extends BaseApiProvider {
  InterestProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  List<InterestModel> _interests = const [];
  String? _staffId;

  List<InterestModel> get interests => _interests;
  String? get staffId => _staffId;

  Future<void> loadData({required String staffId, String? interest}) async {
    _staffId = staffId;
    await runGuarded(() async {
      _interests = await _apiService.getInterests(staffId, interest: interest);
      notifyListeners();
    });
  }

  Future<InterestModel?> addInterest({
    required String staffId,
    required String title,
    required String description,
  }) async {
    final createdInterest = await runGuarded(() => _apiService.addInterest(
          staffId: staffId,
          title: title,
          description: description,
        ));

    if (createdInterest != null) {
      if (_staffId == staffId) {
        _interests = [..._interests, createdInterest];
      }
      notifyListeners();
    }

    return createdInterest;
  }

  Future<InterestModel?> updateInterest({
    required String id,
    required String staffId,
    required String title,
    required String description,
  }) async {
    final updatedInterest = await runGuarded(() => _apiService.updateInterest(
          id: id,
          staffId: staffId,
          title: title,
          description: description,
        ));

    if (updatedInterest != null) {
      _interests = _interests.map((interest) => interest.id == updatedInterest.id ? updatedInterest : interest).toList();
      notifyListeners();
    }

    return updatedInterest;
  }

  Future<void> deleteInterest(String id) async {
    final deleted = await runGuarded(() => _apiService.deleteInterest(id));

    if (deleted != null) {
      _interests = _interests.where((interest) => interest.id != id).toList();
      notifyListeners();
    }
  }
}
