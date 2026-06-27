import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/resume.dart';

const _baseUrl = 'http://localhost:8000';

Future<Map<String, dynamic>> uploadResume(
  List<int> fileBytes, {
  String? fileName,
  http.Client? client,
}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final uri = Uri.parse('$_baseUrl/resume/upload');
  final request = http.MultipartRequest('POST', uri);

  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  final safeName = (fileName != null && fileName.toLowerCase().endsWith('.pdf'))
      ? fileName
      : 'resume.pdf';
  request.files.add(http.MultipartFile.fromBytes(
    'file',
    fileBytes,
    filename: safeName,
    contentType: MediaType('application', 'pdf'),
  ));

  final streamedResponse = await c.send(request);
  final response = await http.Response.fromStream(streamedResponse);

  if (client == null) c.close();

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to upload resume');
}

Future<List<ResumeData>> getResume({String? studentId, http.Client? client}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final uri = Uri.parse('$_baseUrl/resume/').replace(
    queryParameters: studentId != null ? {'request_student_id': studentId} : null,
  );

  final response = await c.get(
    uri,
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List;
    return list.map((e) => ResumeData.fromJson(e)).toList();
  }

  if (response.statusCode == 404) {
    return [];
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch resume');
}

Future<Uint8List> downloadResume(int resumeId, {http.Client? client}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.get(
    Uri.parse('$_baseUrl/resume/download/$resumeId'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  if (response.statusCode == 200) {
    return response.bodyBytes;
  }

  try {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to download resume');
  } catch (_) {
    throw Exception('Failed to download resume');
  }
}

Future<void> approveResume(int resumeId, {http.Client? client}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.patch(
    Uri.parse('$_baseUrl/resume/$resumeId/approve'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  if (response.statusCode == 200) return;

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to approve resume');
}
