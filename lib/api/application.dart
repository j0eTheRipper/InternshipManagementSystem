import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/application.dart';
import 'package:internship_management_system/config.dart';

Future<Application> apply({required int opportunityId, required int resumeId}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/applications'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
    body: jsonEncode({
      'opportunity_id': opportunityId,
      'resume_id': resumeId,
    }),
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    return Application.fromJson(jsonDecode(response.body));
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to apply');
}

Future<Application> createExternalApplication({
  required String companyName,
  required String jobTitle,
  required String jobMode,
  required String companyLocation,
  required int resumeId,
  required List<int> screenshotBytes,
  required String screenshotFileName,
}) async {
  final token = AuthState.token;
  final uri = Uri.parse('$baseUrl/applications/external');
  final request = http.MultipartRequest('POST', uri);

  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  request.fields['company_name'] = companyName;
  request.fields['job_title'] = jobTitle;
  request.fields['job_mode'] = jobMode;
  request.fields['company_location'] = companyLocation;
  request.fields['resume_id'] = resumeId.toString();
  request.files.add(http.MultipartFile.fromBytes(
    'screenshot',
    screenshotBytes,
    filename: screenshotFileName,
  ));

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return Application.fromJson(jsonDecode(response.body));
  }

  AuthState.requireAuth(response);

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to create external application');
}

Future<List<Application>> getMyApplications() async {
  final response = await http.get(
    Uri.parse('$baseUrl/applications/my'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final List json = jsonDecode(response.body);
    return json.map((e) => Application.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch applications');
}

Future<Application> getApplication(int applicationId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/applications/$applicationId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    return Application.fromJson(jsonDecode(response.body));
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch application');
}

Future<Uint8List> downloadScreenshot(int applicationId) async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$baseUrl/applications/$applicationId/screenshot'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    return response.bodyBytes;
  }

  try {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to download screenshot');
  } catch (_) {
    throw Exception('Failed to download screenshot');
  }
}

Future<List<Application>> getApplicants(int opportunityId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/applications/opportunity/$opportunityId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final List json = jsonDecode(response.body);
    return json.map((e) => Application.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch applicants');
}

Future<void> updateApplicationStatus(int applicationId, String status) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/applications/$applicationId/status'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
    body: jsonEncode({'status': status}),
  );

  AuthState.requireAuth(response);

  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to update status');
  }
}

Future<void> acceptApplication(int applicationId) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/applications/$applicationId/accept'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to accept application');
  }
}
