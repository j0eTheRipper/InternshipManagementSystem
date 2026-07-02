import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';

const _baseUrl = 'http://localhost:8000';

Future<Map<String, dynamic>> uploadOfferLetter({
  required int applicationId,
  required List<int> fileBytes,
  required String fileName,
}) async {
  final token = AuthState.token;
  final uri = Uri.parse('$_baseUrl/offer-letter/upload');
  final request = http.MultipartRequest('POST', uri);

  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  request.fields['application_id'] = applicationId.toString();
  request.files.add(http.MultipartFile.fromBytes(
    'file',
    fileBytes,
    filename: fileName,
  ));

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to upload offer letter');
}

Future<Map<String, dynamic>> getOfferLetterByApplication(int applicationId) async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$_baseUrl/offer-letter/by-application/$applicationId'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
  if (response.statusCode == 404) {
    throw Exception('Not found');
  }
  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch offer letter');
}

Future<List<dynamic>> getPendingOfferLetters() async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$_baseUrl/offer-letter/pending'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch pending offer letters');
}

Future<Uint8List> downloadOfferLetter(int offerLetterId) async {
  final token = AuthState.token;
  final response = await http.get(
    Uri.parse('$_baseUrl/offer-letter/download/$offerLetterId'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return response.bodyBytes;
  }

  try {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to download offer letter');
  } catch (_) {
    throw Exception('Failed to download offer letter');
  }
}

Future<void> approveOfferLetter(int offerLetterId) async {
  final token = AuthState.token;
  final response = await http.patch(
    Uri.parse('$_baseUrl/offer-letter/$offerLetterId/approve'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) return;

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to approve offer letter');
}

Future<void> rejectOfferLetter(int offerLetterId) async {
  final token = AuthState.token;
  final response = await http.patch(
    Uri.parse('$_baseUrl/offer-letter/$offerLetterId/reject'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) return;

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to reject offer letter');
}
