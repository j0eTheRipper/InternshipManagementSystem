import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/placement_agreement.dart';

const _baseUrl = 'http://localhost:8000';

Future<Map<String, dynamic>> uploadPlacementAgreement({
  required List<int> fileBytes,
  required String fileName,
}) async {
  final token = AuthState.token;
  final uri = Uri.parse('$_baseUrl/placement-agreement/upload');
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
  throw Exception(json['detail'] ?? 'Failed to upload placement agreement');
}

Future<PlacementAgreementData?> getPlacementAgreementByStudent(String studentId) async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$_baseUrl/placement-agreement/student/$studentId'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final body = response.body;
    if (body == 'null' || body.isEmpty) return null;
    return PlacementAgreementData.fromJson(jsonDecode(body));
  }

  return null;
}

Future<Uint8List> downloadPlacementAgreement(int placementAgreementId) async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$_baseUrl/placement-agreement/download/$placementAgreementId'),
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
    throw Exception(json['detail'] ?? 'Failed to download placement agreement');
  } catch (_) {
    throw Exception('Failed to download placement agreement');
  }
}

Future<List<Map<String, dynamic>>> getPendingPlacementAgreements() async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$_baseUrl/placement-agreement/pending'),
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
  throw Exception(json['detail'] ?? 'Failed to fetch pending placement agreements');
}

Future<void> approvePlacementAgreement(int placementAgreementId) async {
  final token = AuthState.token;
  final response = await http.patch(
    Uri.parse('$_baseUrl/placement-agreement/$placementAgreementId/approve'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) return;

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to approve placement agreement');
}
