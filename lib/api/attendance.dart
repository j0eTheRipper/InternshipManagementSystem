import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/config.dart';

Future<bool> getTodaysAttendance() async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$baseUrl/attendance/today'),
    headers: {if (token != null) 'Authorization': 'Bearer $token'},
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['checked_in'] == true;
  }

  return false;
}

Future<List<Map<String, dynamic>>> getAttendanceHistory({
  http.Client? client,
}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.get(
    Uri.parse('$baseUrl/attendance/history'),
    headers: {if (token != null) 'Authorization': 'Bearer $token'},
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List;
    return list.cast<Map<String, dynamic>>();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch attendance history');
}

Future<Map<String, dynamic>> checkIn() async {
  final token = AuthState.token;
  final response = await http.post(
    Uri.parse('$baseUrl/attendance/check-in'),
    headers: {if (token != null) 'Authorization': 'Bearer $token'},
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to check in');
}
