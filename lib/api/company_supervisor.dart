import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/config.dart';

Future<Map<String, dynamic>> getCompanySupervisorProfile() async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$baseUrl/company-supervisor/profile'),
    headers: {if (token != null) 'Authorization': 'Bearer $token'},
  );
  AuthState.requireAuth(response);
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch profile');
}

Future<List<Map<String, dynamic>>> getAssignedStudents() async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$baseUrl/company-supervisor/students'),
    headers: {if (token != null) 'Authorization': 'Bearer $token'},
  );
  AuthState.requireAuth(response);
  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List;
    return list.cast<Map<String, dynamic>>();
  }
  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch students');
}

Future<List<Map<String, dynamic>>> getStudentAttendance(String studentId) async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$baseUrl/company-supervisor/students/$studentId/attendance'),
    headers: {if (token != null) 'Authorization': 'Bearer $token'},
  );
  AuthState.requireAuth(response);
  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List;
    return list.cast<Map<String, dynamic>>();
  }
  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch attendance');
}

Future<List<Map<String, dynamic>>> getStudentWorkLogs(String studentId) async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$baseUrl/company-supervisor/students/$studentId/work-logs'),
    headers: {if (token != null) 'Authorization': 'Bearer $token'},
  );
  AuthState.requireAuth(response);
  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List;
    return list.cast<Map<String, dynamic>>();
  }
  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch work logs');
}

Future<void> verifyAttendance(int attendanceId) async {
  final token = AuthState.token;
  final response = await http.patch(
    Uri.parse('$baseUrl/company-supervisor/attendance/$attendanceId/verify'),
    headers: {if (token != null) 'Authorization': 'Bearer $token'},
  );
  AuthState.requireAuth(response);
  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to verify attendance');
  }
}

Future<void> unverifyAttendance(int attendanceId) async {
  final token = AuthState.token;
  final response = await http.patch(
    Uri.parse('$baseUrl/company-supervisor/attendance/$attendanceId/unverify'),
    headers: {if (token != null) 'Authorization': 'Bearer $token'},
  );
  AuthState.requireAuth(response);
  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to unverify attendance');
  }
}

Future<void> verifyWorkLog(int dailyTaskId) async {
  final token = AuthState.token;
  final response = await http.patch(
    Uri.parse('$baseUrl/company-supervisor/work-logs/$dailyTaskId/verify'),
    headers: {if (token != null) 'Authorization': 'Bearer $token'},
  );
  AuthState.requireAuth(response);
  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to verify work log');
  }
}

Future<void> unverifyWorkLog(int dailyTaskId) async {
  final token = AuthState.token;
  final response = await http.patch(
    Uri.parse('$baseUrl/company-supervisor/work-logs/$dailyTaskId/unverify'),
    headers: {if (token != null) 'Authorization': 'Bearer $token'},
  );
  AuthState.requireAuth(response);
  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to unverify work log');
  }
}
