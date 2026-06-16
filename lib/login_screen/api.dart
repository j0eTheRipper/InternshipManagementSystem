import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';

const _baseUrl = 'http://localhost:8000';

Future<dynamic> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    if (json['user'] != null) {
      return Student.fromJson(json);
    }
    return User.fromJson(json);
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Login failed');
}
