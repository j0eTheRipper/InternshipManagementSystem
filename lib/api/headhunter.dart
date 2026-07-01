import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/headhunter.dart';
import 'package:internship_management_system/models/user.dart';

const _baseUrl = 'http://localhost:8000';

class RegisterResult {
  final Headhunter headhunter;
  final String token;

  RegisterResult({required this.headhunter, required this.token});
}

Future<RegisterResult> registerHeadhunter({
  required String fullname,
  required String email,
  required String password,
  required String companyName,
  String companyEmail = '',
}) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/register/headhunter'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'fullname': fullname,
      'email': email,
      'password': password,
      'company_name': companyName,
      'company_email': companyEmail,
    }),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final token = json['access_token'] as String;
    final userJson = json['user'] as Map<String, dynamic>;
    final headhunter = Headhunter.fromJson(userJson);
    return RegisterResult(headhunter: headhunter, token: token);
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Registration failed');
}

Future<Headhunter> getHeadhunterProfile() async {
  final response = await http.get(
    Uri.parse('$_baseUrl/headhunter/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return Headhunter.fromJson(json);
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch profile');
}
