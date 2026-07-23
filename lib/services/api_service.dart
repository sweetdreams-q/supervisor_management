import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/interest_model.dart';
import '../models/staff_browse_model.dart';
import '../models/project_idea_model.dart';
import '../models/staff_model.dart';

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiConstants.baseUrl).trim();

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedBaseUrl = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBaseUrl$normalizedPath').replace(queryParameters: queryParameters);
  }

  Future<List<StaffModel>> getStaff() async {
    final response = await _client.get(_uri(ApiConstants.staffList));
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (payload['data'] as List<dynamic>? ?? const []);
    return data.map((item) => StaffModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<StaffModel> getStaffById(String id) async {
    final response = await _client.get(_uri(ApiConstants.staffById(id)));
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return StaffModel.fromJson(Map<String, dynamic>.from(payload['data'] as Map));
  }

  Future<List<StaffBrowseModel>> getBrowseStaff({String? interest}) async {
    final response = await _client.get(
      _uri(
        ApiConstants.studentsStaff,
        interest == null || interest.trim().isEmpty ? null : {'interest': interest},
      ),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (payload['data'] as List<dynamic>? ?? const []);
    return data.map((item) => StaffBrowseModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<StaffModel> addStaff({
    required String name,
    required String email,
    required String department,
    required String bio,
  }) async {
    final response = await _client.post(
      _uri(ApiConstants.addStaff),
      headers: _jsonHeaders,
      body: jsonEncode({
        'name': name,
        'email': email,
        'department': department,
        'bio': bio,
      }),
    );
    _validateResponse(response, expectedStatusCodes: {201});

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return StaffModel.fromJson(Map<String, dynamic>.from(payload['data'] as Map));
  }

  Future<StaffModel> updateStaff({
    required String id,
    required String name,
    required String email,
    required String department,
    required String bio,
  }) async {
    final response = await _client.put(
      _uri(ApiConstants.updateStaff(id)),
      headers: _jsonHeaders,
      body: jsonEncode({
        'name': name,
        'email': email,
        'department': department,
        'bio': bio,
      }),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return StaffModel.fromJson(Map<String, dynamic>.from(payload['data'] as Map));
  }

  Future<void> deleteStaff(String id) async {
    final response = await _client.delete(_uri(ApiConstants.deleteStaff(id)));
    _validateResponse(response);
  }

  Future<List<InterestModel>> getInterests(String staffId, {String? interest}) async {
    final response = await _client.get(
      _uri(
        ApiConstants.staffInterests(staffId),
        interest == null || interest.trim().isEmpty ? null : {'interest': interest},
      ),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (payload['data'] as List<dynamic>? ?? const []);
    return data.map((item) => InterestModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<List<ProjectIdeaModel>> getProjects(String staffId) async {
    final response = await _client.get(_uri(ApiConstants.staffProjects(staffId)));
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (payload['data'] as List<dynamic>? ?? const []);
    return data.map((item) => ProjectIdeaModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<InterestModel> addInterest({
    required String staffId,
    required String title,
    required String description,
  }) async {
    final response = await _client.post(
      _uri(ApiConstants.addInterest),
      headers: _jsonHeaders,
      body: jsonEncode({
        'staffId': staffId,
        'title': title,
        'description': description,
      }),
    );
    _validateResponse(response, expectedStatusCodes: {201});

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return InterestModel.fromJson(Map<String, dynamic>.from(payload['data'] as Map));
  }

  Future<InterestModel> updateInterest({
    required String id,
    required String staffId,
    required String title,
    required String description,
  }) async {
    final response = await _client.put(
      _uri(ApiConstants.updateInterest(id)),
      headers: _jsonHeaders,
      body: jsonEncode({
        'staffId': staffId,
        'title': title,
        'description': description,
      }),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return InterestModel.fromJson(Map<String, dynamic>.from(payload['data'] as Map));
  }

  Future<void> deleteInterest(String id) async {
    final response = await _client.delete(_uri(ApiConstants.deleteInterest(id)));
    _validateResponse(response);
  }

  Future<ProjectIdeaModel> addProject({
    required String staffId,
    required String title,
    required String description,
    required String tags,
  }) async {
    final response = await _client.post(
      _uri(ApiConstants.addProject),
      headers: _jsonHeaders,
      body: jsonEncode({
        'staffId': staffId,
        'title': title,
        'description': description,
        'tags': tags,
      }),
    );
    _validateResponse(response, expectedStatusCodes: {201});

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return ProjectIdeaModel.fromJson(Map<String, dynamic>.from(payload['data'] as Map));
  }

  Future<ProjectIdeaModel> updateProject({
    required String id,
    required String staffId,
    required String title,
    required String description,
    required String tags,
  }) async {
    final response = await _client.put(
      _uri(ApiConstants.updateProject(id)),
      headers: _jsonHeaders,
      body: jsonEncode({
        'staffId': staffId,
        'title': title,
        'description': description,
        'tags': tags,
      }),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return ProjectIdeaModel.fromJson(Map<String, dynamic>.from(payload['data'] as Map));
  }

  Future<void> deleteProject(String id) async {
    final response = await _client.delete(_uri(ApiConstants.deleteProject(id)));
    _validateResponse(response);
  }

  void _validateResponse(http.Response response, {Set<int> expectedStatusCodes = const {200}}) {
    if (expectedStatusCodes.contains(response.statusCode)) {
      return;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractMessage(response.body) ?? 'Request failed',
    );
  }

  String? _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        return message?.toString();
      }
    } catch (_) {
      // Ignore JSON parsing errors and fall back to null.
    }
    return null;
  }

  Map<String, String> get _jsonHeaders => const {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      };
}

class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
