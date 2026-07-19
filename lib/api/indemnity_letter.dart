import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/indemnity_letter.dart';
import 'package:internship_management_system/config.dart';

Future<Map<String, dynamic>> uploadIndemnityLetter({
  required List<int> fileBytes,
  required String fileName,
}) async {
  final token = AuthState.token;
  final uri = Uri.parse('$baseUrl/indemnity-letter/upload');
  final request = http.MultipartRequest('POST', uri);

  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  request.files.add(http.MultipartFile.fromBytes(
    'file',
    fileBytes,
    filename: fileName,
    contentType: MediaType('application', 'pdf'),
  ));

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to upload indemnity letter');
}

Future<IndemnityLetterData?> getIndemnityLetterByStudent(String studentId) async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$baseUrl/indemnity-letter/student/$studentId'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final body = response.body;
    if (body == 'null' || body.isEmpty) return null;
    return IndemnityLetterData.fromJson(jsonDecode(body));
  }

  return null;
}

Future<Uint8List> downloadIndemnityLetter(int indemnityLetterId) async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$baseUrl/indemnity-letter/download/$indemnityLetterId'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    return response.bodyBytes;
  }

  try {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to download indemnity letter');
  } catch (_) {
    throw Exception('Failed to download indemnity letter');
  }
}

Future<List<Map<String, dynamic>>> getPendingIndemnityLetters() async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$baseUrl/indemnity-letter/pending'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List;
    return list.cast<Map<String, dynamic>>();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch pending indemnity letters');
}

Future<void> approveIndemnityLetter(int indemnityLetterId) async {
  final token = AuthState.token;
  final response = await http.patch(
    Uri.parse('$baseUrl/indemnity-letter/$indemnityLetterId/approve'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) return;

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to approve indemnity letter');
}
