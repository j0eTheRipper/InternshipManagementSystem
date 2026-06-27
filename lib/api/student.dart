import 'dart:convert';

import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/student.dart';
import 'package:http/http.dart' as http;

const _baseUrl = 'http://localhost:8000';

Future<Student> getStudent(String userId) async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$_baseUrl/student?user_id=$userId'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return Student.fromJson(json);
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch student data');
}
