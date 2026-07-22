import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/opportunity.dart';
import 'package:internship_management_system/config.dart';

Future<List<Opportunity>> getOpportunities({
  String? fieldOfStudy,
  int? limit,
  int? offset,
  bool otherFields = false,
}) async {
  final queryParams = <String, String>{};
  if (fieldOfStudy != null) queryParams['field_of_study'] = fieldOfStudy;
  if (limit != null) queryParams['limit'] = limit.toString();
  if (offset != null) queryParams['offset'] = offset.toString();
  if (otherFields) queryParams['other_fields'] = 'true';

  final uri = Uri.parse('$baseUrl/opportunities').replace(
    queryParameters: queryParams.isNotEmpty ? queryParams : null,
  );

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final List json = jsonDecode(response.body);
    return json.map((e) => Opportunity.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch opportunities');
}

Future<Opportunity> getOpportunity(int id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/opportunities/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    return Opportunity.fromJson(jsonDecode(response.body));
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch opportunity');
}

Future<List<Opportunity>> getMyOpportunities() async {
  final response = await http.get(
    Uri.parse('$baseUrl/opportunities/my'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final List json = jsonDecode(response.body);
    return json.map((e) => Opportunity.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch opportunities');
}

Future<Opportunity> createOpportunity({
  required String title,
  required String jobRole,
  required String description,
  required String location,
  String status = 'remote',
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/opportunities'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
    body: jsonEncode({
      'title': title,
      'job_role': jobRole,
      'description': description,
      'location': location,
      'status': status,
    }),
  );

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    return Opportunity.fromJson(jsonDecode(response.body));
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to create opportunity');
}

Future<void> updateOpportunity(int id, {
  required String title,
  required String jobRole,
  required String description,
  required String location,
  required String status,
}) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/opportunities/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
    body: jsonEncode({
      'title': title,
      'job_role': jobRole,
      'description': description,
      'location': location,
      'status': status,
    }),
  );

  AuthState.requireAuth(response);

  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to update opportunity');
  }
}

Future<void> deleteOpportunity(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/opportunities/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthState.token}',
    },
  );

  AuthState.requireAuth(response);

  if (response.statusCode != 200) {
    final json = jsonDecode(response.body);
    throw Exception(json['detail'] ?? 'Failed to delete opportunity');
  }
}
