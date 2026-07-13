import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';

const _baseUrl = 'http://localhost:8000';

Future<Map<String, dynamic>> submitDailyTask({
  required String updateText,
  http.Client? client,
}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$_baseUrl/daily-task'),
  );
  request.headers.addAll({
    if (token != null) 'Authorization': 'Bearer $token',
  });
  request.fields['update_text'] = updateText;

  final streamed = await c.send(request);
  final response = await http.Response.fromStream(streamed);

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to submit daily task');
}

Future<Map<String, dynamic>?> getTodayTask({
  http.Client? client,
}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.get(
    Uri.parse('$_baseUrl/daily-task/today'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    if (body == null) return null;
    return body as Map<String, dynamic>;
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch daily task');
}

Future<List<dynamic>> getDailyTaskHistory({
  http.Client? client,
}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.get(
    Uri.parse('$_baseUrl/daily-task/history'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch daily task history');
}
