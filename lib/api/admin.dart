import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/student.dart';
import 'package:internship_management_system/models/user.dart';

const _baseUrl = 'http://localhost:8000';

Map<String, String> _headers() {
  final token = AuthState.token;
  return {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

// ── Students ──────────────────────────────────────────────

Future<void> createStudent({
  required String fullname,
  required String email,
  required String password,
  required String studentId,
  required int yearOfStudy,
  required String fieldOfStudy,
  required int mentorId,
  http.Client? client,
}) async {
  final c = client ?? http.Client();
  final response = await c.post(
    Uri.parse('$_baseUrl/admin/students'),
    headers: _headers(),
    body: jsonEncode({
      'fullname': fullname,
      'email': email,
      'password': password,
      'student_id': studentId,
      'year_of_study': yearOfStudy,
      'field_of_study': fieldOfStudy,
      'mentor_id': mentorId,
    }),
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to create student');
  }
}

Future<List<Student>> getAllStudents({http.Client? client}) async {
  final c = client ?? http.Client();
  final response = await c.get(
    Uri.parse('$_baseUrl/admin/students'),
    headers: _headers(),
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List;
    return list.map((e) => Student.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch students');
}

Future<Student> getStudentById(String studentId, {http.Client? client}) async {
  final c = client ?? http.Client();
  final response = await c.get(
    Uri.parse('$_baseUrl/admin/students/$studentId'),
    headers: _headers(),
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    return Student.fromJson(jsonDecode(response.body));
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch student');
}

Future<void> updateStudentProgress(String studentId, String progress, {http.Client? client}) async {
  final c = client ?? http.Client();
  final response = await c.patch(
    Uri.parse('$_baseUrl/admin/students/$studentId/progress'),
    headers: _headers(),
    body: jsonEncode({'progress': progress}),
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to update progress');
  }
}

Future<void> updateStudentMentor(String studentId, int mentorId, {http.Client? client}) async {
  final c = client ?? http.Client();
  final response = await c.patch(
    Uri.parse('$_baseUrl/admin/students/$studentId/mentor'),
    headers: _headers(),
    body: jsonEncode({'mentor_id': mentorId}),
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to update mentor');
  }
}

// ── Mentors ───────────────────────────────────────────────

Future<void> createMentor({
  required String fullname,
  required String email,
  required String password,
  http.Client? client,
}) async {
  final c = client ?? http.Client();
  final response = await c.post(
    Uri.parse('$_baseUrl/admin/mentors'),
    headers: _headers(),
    body: jsonEncode({
      'fullname': fullname,
      'email': email,
      'password': password,
    }),
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to create mentor');
  }
}

Future<List<User>> getAllMentors({http.Client? client}) async {
  final c = client ?? http.Client();
  final response = await c.get(
    Uri.parse('$_baseUrl/admin/mentors'),
    headers: _headers(),
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List;
    return list.map((e) => User.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch mentors');
}

// ── Attendance ────────────────────────────────────────────

Future<void> addAttendance(String studentId, String date, {http.Client? client}) async {
  final c = client ?? http.Client();
  final response = await c.post(
    Uri.parse('$_baseUrl/admin/attendance'),
    headers: _headers(),
    body: jsonEncode({'student_id': studentId, 'date': date}),
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to add attendance');
  }
}

Future<void> deleteAttendance(int attendanceId, {http.Client? client}) async {
  final c = client ?? http.Client();
  final response = await c.delete(
    Uri.parse('$_baseUrl/admin/attendance/$attendanceId'),
    headers: _headers(),
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to delete attendance');
  }
}

Future<List<Map<String, dynamic>>> getStudentAttendance(String studentId, {http.Client? client}) async {
  final c = client ?? http.Client();
  final response = await c.get(
    Uri.parse('$_baseUrl/admin/attendance/$studentId'),
    headers: _headers(),
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List;
    return list.cast<Map<String, dynamic>>();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch attendance');
}
