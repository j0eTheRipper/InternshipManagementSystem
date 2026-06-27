import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/student.dart';

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
    if (json case {'Error': _}) {
      throw Exception(json['Error']);
    }
    return Student.fromJson(json);
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch student data');
}

Future<List<Student>> getMentorStudents({http.Client? client}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.get(
    Uri.parse('$_baseUrl/students'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List;
    return list.map((e) => Student.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch students');
}
