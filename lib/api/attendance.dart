import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';

const _baseUrl = 'http://localhost:8000';

Future<bool> getTodaysAttendance() async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$_baseUrl/attendance/today'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['checked_in'] == true;
  }

  return false;
}

Future<Map<String, dynamic>> checkIn() async {
  final token = AuthState.token;
  final response = await http.post(
    Uri.parse('$_baseUrl/attendance/check-in'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to check in');
}
