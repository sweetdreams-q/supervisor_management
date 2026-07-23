import '../models/staff_model.dart';
import '../models/staff_browse_model.dart';
import '../services/api_service.dart';
import 'base_api_provider.dart';

class StaffProvider extends BaseApiProvider {
  StaffProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  List<StaffModel> _staff = const [];
  StaffModel? _selectedStaff;
  List<StaffBrowseModel> _browseStaff = const [];
  String _browseSearchQuery = '';
  String _selectedInterest = 'All';

  List<StaffModel> get staff => _staff;
  StaffModel? get selectedStaff => _selectedStaff;
  List<StaffBrowseModel> get browseStaff => _browseStaff;
  String get browseSearchQuery => _browseSearchQuery;
  String get selectedInterest => _selectedInterest;

  List<String> get browseInterestOptions {
    final interests = _browseStaff
        .expand((staff) => staff.areasOfInterest.map((interest) => interest.title.trim()))
        .where((title) => title.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['All', ...interests];
  }

  List<StaffBrowseModel> get filteredBrowseStaff {
    final normalizedQuery = _browseSearchQuery.trim().toLowerCase();
    final normalizedSelectedInterest = _selectedInterest.trim().toLowerCase();

    return _browseStaff.where((staff) {
      final matchesSearch = normalizedQuery.isEmpty || _matchesSearch(staff, normalizedQuery);
      final matchesInterest =
          normalizedSelectedInterest == 'all' || _matchesInterest(staff, normalizedSelectedInterest);

      return matchesSearch && matchesInterest;
    }).toList();
  }

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

  Future<void> loadBrowseData({String? interest}) async {
    await runGuarded(() async {
      _browseStaff = await _apiService.getBrowseStaff(interest: interest);
      notifyListeners();
    });
  }

  void setBrowseSearchQuery(String value) {
    _browseSearchQuery = value;
    notifyListeners();
  }

  void setSelectedInterest(String value) {
    _selectedInterest = value;
    notifyListeners();
  }

  void clearBrowseFilters() {
    _browseSearchQuery = '';
    _selectedInterest = 'All';
    notifyListeners();
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
    final deleted = await runGuardedVoid(() => _apiService.deleteStaff(id));

    if (deleted) {
      _staff = _staff.where((member) => member.id != id).toList();
      if (_selectedStaff?.id == id) {
        _selectedStaff = null;
      }
      notifyListeners();
    }
  }

  bool _matchesSearch(StaffBrowseModel staff, String query) {
    final staffName = staff.staffProfile.name.toLowerCase();
    final department = staff.staffProfile.department.toLowerCase();
    final interestTitles = staff.areasOfInterest.map((interest) => interest.title.toLowerCase()).join(' ');
    final interestDescriptions = staff.areasOfInterest.map((interest) => interest.description.toLowerCase()).join(' ');

    return staffName.contains(query) || department.contains(query) || interestTitles.contains(query) || interestDescriptions.contains(query);
  }

  bool _matchesInterest(StaffBrowseModel staff, String selectedInterest) {
    return staff.areasOfInterest.any((interest) {
      final title = interest.title.toLowerCase();
      final description = interest.description.toLowerCase();
      return title == selectedInterest || title.contains(selectedInterest) || description.contains(selectedInterest);
    });
  }
}
