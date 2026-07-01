import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/application.dart';

const _baseUrl = 'http://localhost:8000';

Future<Application> apply({required int opportunityId, required int resumeId}) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/applications'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
    body: jsonEncode({
      'opportunity_id': opportunityId,
      'resume_id': resumeId,
    }),
  );

  if (response.statusCode == 200) {
    return Application.fromJson(jsonDecode(response.body));
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to apply');
}

Future<List<Application>> getMyApplications() async {
  final response = await http.get(
    Uri.parse('$_baseUrl/applications/my'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
  );

  if (response.statusCode == 200) {
    final List json = jsonDecode(response.body);
    return json.map((e) => Application.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch applications');
}

Future<List<Application>> getApplicants(int opportunityId) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/applications/opportunity/$opportunityId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
  );

  if (response.statusCode == 200) {
    final List json = jsonDecode(response.body);
    return json.map((e) => Application.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch applicants');
}

Future<void> updateApplicationStatus(int applicationId, String status) async {
  final response = await http.patch(
    Uri.parse('$_baseUrl/applications/$applicationId/status'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
    body: jsonEncode({'status': status}),
  );

  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to update status');
  }
}

Future<void> acceptApplication(int applicationId) async {
  final response = await http.patch(
    Uri.parse('$_baseUrl/applications/$applicationId/accept'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
  );

  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to accept application');
  }
}
