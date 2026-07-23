import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart' show ClientException;

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
  static const Duration _requestTimeout = Duration(seconds: 12);

  Uri _uri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedBaseUrl = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '$normalizedBaseUrl$normalizedPath',
    ).replace(queryParameters: queryParameters);
  }

  Future<List<StaffModel>> getStaff() async {
    final response = await _send(
      () => _client.get(_uri(ApiConstants.staffList)),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (payload['data'] as List<dynamic>? ?? const []);
    return data
        .map(
          (item) => StaffModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<StaffModel> getStaffById(String id) async {
    final response = await _send(
      () => _client.get(_uri(ApiConstants.staffById(id))),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return StaffModel.fromJson(
      Map<String, dynamic>.from(payload['data'] as Map),
    );
  }

  Future<List<StaffBrowseModel>> getBrowseStaff({String? interest}) async {
    final response = await _send(
      () => _client.get(
        _uri(
          ApiConstants.studentsStaff,
          interest == null || interest.trim().isEmpty
              ? null
              : {'interest': interest},
        ),
      ),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (payload['data'] as List<dynamic>? ?? const []);
    return data
        .map(
          (item) =>
              StaffBrowseModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<StaffModel> addStaff({
    required String name,
    required String email,
    required String department,
    required String bio,
  }) async {
    final response = await _send(
      () => _client.post(
        _uri(ApiConstants.addStaff),
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'department': department,
          'bio': bio,
        }),
      ),
    );
    _validateResponse(response, expectedStatusCodes: {201});

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return StaffModel.fromJson(
      Map<String, dynamic>.from(payload['data'] as Map),
    );
  }

  Future<StaffModel> updateStaff({
    required String id,
    required String name,
    required String email,
    required String department,
    required String bio,
  }) async {
    final response = await _send(
      () => _client.put(
        _uri(ApiConstants.updateStaff(id)),
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'department': department,
          'bio': bio,
        }),
      ),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return StaffModel.fromJson(
      Map<String, dynamic>.from(payload['data'] as Map),
    );
  }

  Future<void> deleteStaff(String id) async {
    final response = await _send(
      () => _client.delete(_uri(ApiConstants.deleteStaff(id))),
    );
    _validateResponse(response);
  }

  Future<List<InterestModel>> getInterests(
    String staffId, {
    String? interest,
  }) async {
    final response = await _send(
      () => _client.get(
        _uri(
          ApiConstants.staffInterests(staffId),
          interest == null || interest.trim().isEmpty
              ? null
              : {'interest': interest},
        ),
      ),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (payload['data'] as List<dynamic>? ?? const []);
    return data
        .map(
          (item) =>
              InterestModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<ProjectIdeaModel>> getProjects(String staffId) async {
    final response = await _send(
      () => _client.get(_uri(ApiConstants.staffProjects(staffId))),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (payload['data'] as List<dynamic>? ?? const []);
    return data
        .map(
          (item) =>
              ProjectIdeaModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<InterestModel> addInterest({
    required String staffId,
    required String title,
    required String description,
  }) async {
    final response = await _send(
      () => _client.post(
        _uri(ApiConstants.addInterest),
        headers: _jsonHeaders,
        body: jsonEncode({
          'staffId': staffId,
          'title': title,
          'description': description,
        }),
      ),
    );
    _validateResponse(response, expectedStatusCodes: {201});

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return InterestModel.fromJson(
      Map<String, dynamic>.from(payload['data'] as Map),
    );
  }

  Future<InterestModel> updateInterest({
    required String id,
    required String staffId,
    required String title,
    required String description,
  }) async {
    final response = await _send(
      () => _client.put(
        _uri(ApiConstants.updateInterest(id)),
        headers: _jsonHeaders,
        body: jsonEncode({
          'staffId': staffId,
          'title': title,
          'description': description,
        }),
      ),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return InterestModel.fromJson(
      Map<String, dynamic>.from(payload['data'] as Map),
    );
  }

  Future<void> deleteInterest(String id) async {
    final response = await _send(
      () => _client.delete(_uri(ApiConstants.deleteInterest(id))),
    );
    _validateResponse(response);
  }

  Future<ProjectIdeaModel> addProject({
    required String staffId,
    required String title,
    required String description,
    required String tags,
  }) async {
    final response = await _send(
      () => _client.post(
        _uri(ApiConstants.addProject),
        headers: _jsonHeaders,
        body: jsonEncode({
          'staffId': staffId,
          'title': title,
          'description': description,
          'tags': tags,
        }),
      ),
    );
    _validateResponse(response, expectedStatusCodes: {201});

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return ProjectIdeaModel.fromJson(
      Map<String, dynamic>.from(payload['data'] as Map),
    );
  }

  Future<ProjectIdeaModel> updateProject({
    required String id,
    required String staffId,
    required String title,
    required String description,
    required String tags,
  }) async {
    final response = await _send(
      () => _client.put(
        _uri(ApiConstants.updateProject(id)),
        headers: _jsonHeaders,
        body: jsonEncode({
          'staffId': staffId,
          'title': title,
          'description': description,
          'tags': tags,
        }),
      ),
    );
    _validateResponse(response);

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return ProjectIdeaModel.fromJson(
      Map<String, dynamic>.from(payload['data'] as Map),
    );
  }

  Future<void> deleteProject(String id) async {
    final response = await _send(
      () => _client.delete(_uri(ApiConstants.deleteProject(id))),
    );
    _validateResponse(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_requestTimeout);
    } on SocketException catch (error, stackTrace) {
      developer.log(
        'Network request failed',
        error: error,
        stackTrace: stackTrace,
        name: 'ApiService',
      );
      throw const ApiException.network(
        'Server unavailable. Check your connection and try again.',
      );
    } on TimeoutException catch (error, stackTrace) {
      developer.log(
        'Request timed out',
        error: error,
        stackTrace: stackTrace,
        name: 'ApiService',
      );
      throw const ApiException.network(
        'The request timed out. Please try again.',
      );
    } on ClientException catch (error, stackTrace) {
      developer.log(
        'HTTP client error',
        error: error,
        stackTrace: stackTrace,
        name: 'ApiService',
      );
      throw const ApiException.network(
        'Server unavailable. Check your connection and try again.',
      );
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected request failure',
        error: error,
        stackTrace: stackTrace,
        name: 'ApiService',
      );
      rethrow;
    }
  }

  void _validateResponse(
    http.Response response, {
    Set<int> expectedStatusCodes = const {200},
  }) {
    if (expectedStatusCodes.contains(response.statusCode)) {
      return;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message:
          _extractMessage(response.body) ?? _statusMessage(response.statusCode),
    );
  }

  String _statusMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Please check your input and try again.';
      case 401:
        return 'You are not authorized to perform this action.';
      case 403:
        return 'This action is forbidden.';
      case 404:
        return 'The requested item was not found.';
      case 409:
        return 'A record with the same details already exists.';
      case 422:
        return 'Validation failed. Please review the form fields.';
      case 500:
        return 'The server encountered a problem. Please try again later.';
      case 503:
        return 'Server unavailable. Please try again later.';
      default:
        return 'Request failed with status code $statusCode.';
    }
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
  const ApiException({
    required this.statusCode,
    required this.message,
    this.isNetworkError = false,
  });

  const ApiException.network(this.message)
    : statusCode = 503,
      isNetworkError = true;

  final int statusCode;
  final String message;
  final bool isNetworkError;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}
