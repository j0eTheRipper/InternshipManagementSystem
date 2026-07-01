import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:internship_management_system/models/headhunter.dart';
import 'package:internship_management_system/models/student.dart';
import 'package:internship_management_system/models/user.dart';

const _baseUrl = 'http://localhost:8000';

class LoginResult {
  final dynamic user;
  final String token;

  LoginResult({required this.user, required this.token});
}

Future<LoginResult> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final token = json['access_token'] as String;
    final userJson = json['user'] as Map<String, dynamic>;
    final role = json['role'] as String;

    dynamic user;
    if (role == 'student') {
      user = Student.fromJson(userJson);
    } else if (role == 'headhunter') {
      user = Headhunter.fromJson(userJson);
    } else {
      user = User.fromJson(userJson);
    }

    return LoginResult(user: user, token: token);
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Login failed');
}
