import '../models/staff_model.dart';
import '../services/api_service.dart';
import 'base_api_provider.dart';

class StaffProvider extends BaseApiProvider {
  StaffProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  List<StaffModel> _staff = const [];
  StaffModel? _selectedStaff;

  List<StaffModel> get staff => _staff;
  StaffModel? get selectedStaff => _selectedStaff;

  Future<void> loadData() async {
    await runGuarded(() async {
      _staff = await _apiService.getStaff();
      notifyListeners();
    });
  }

  Future<void> loadStaffById(String id) async {
    await runGuarded(() async {
      _selectedStaff = await _apiService.getStaffById(id);
      notifyListeners();
    });
  }

  Future<StaffModel?> addStaff({
    required String name,
    required String email,
    required String department,
    required String bio,
  }) async {
    final createdStaff = await runGuarded(() => _apiService.addStaff(
          name: name,
          email: email,
          department: department,
          bio: bio,
        ));

    if (createdStaff != null) {
      _staff = [..._staff, createdStaff];
      notifyListeners();
    }

    return createdStaff;
  }

  Future<StaffModel?> updateStaff({
    required String id,
    required String name,
    required String email,
    required String department,
    required String bio,
  }) async {
    final updatedStaff = await runGuarded(() => _apiService.updateStaff(
          id: id,
          name: name,
          email: email,
          department: department,
          bio: bio,
        ));

    if (updatedStaff != null) {
      _staff = _staff.map((member) => member.id == updatedStaff.id ? updatedStaff : member).toList();
      if (_selectedStaff?.id == updatedStaff.id) {
        _selectedStaff = updatedStaff;
      }
      notifyListeners();
    }

    return updatedStaff;
  }

  Future<void> deleteStaff(String id) async {
    final deleted = await runGuarded(() => _apiService.deleteStaff(id));

    if (deleted != null) {
      _staff = _staff.where((member) => member.id != id).toList();
      if (_selectedStaff?.id == id) {
        _selectedStaff = null;
      }
      notifyListeners();
    }
  }
}
