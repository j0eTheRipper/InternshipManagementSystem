import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/company_supervisor.dart';
import 'package:internship_management_system/models/headhunter.dart';
import 'package:internship_management_system/models/student.dart';
import 'package:internship_management_system/models/user.dart';
import 'package:internship_management_system/config.dart';

class LoginResult {
  final dynamic user;
  final String token;

  LoginResult({required this.user, required this.token});
}

Future<LoginResult> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    },
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
    } else if (role == 'companySupervisor') {
      user = CompanySupervisor.fromJson(userJson);
    } else {
      user = User.fromJson(userJson);
    }

    return LoginResult(user: user, token: token);
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Login failed');
}

Future<User> updateProfile({
  required String currentPassword,
  String? newEmail,
  String? newPassword,
}) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
    body: jsonEncode({
      'current_password': currentPassword,
      if (newEmail != null) 'new_email': newEmail,
      if (newPassword != null) 'new_password': newPassword,
    }),
  );

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to update profile');
}
