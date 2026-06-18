import 'dart:convert';

import 'package:internship_management_system/models/student.dart';
import 'package:http/http.dart' as http;

const _baseUrl = 'http://localhost:8000';

Future<Student> getStudent(String userId) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/student?user_id=$userId'),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return Student.fromJson(json);
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch student data');
}
