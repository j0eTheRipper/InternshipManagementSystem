import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/notification.dart';
import 'package:internship_management_system/config.dart';

Future<List<NotificationData>> getNotifications({http.Client? client}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.get(
    Uri.parse('$baseUrl/notifications/'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List;
    return list.map((e) => NotificationData.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch notifications');
}

Future<int> getUnreadCount({http.Client? client}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.get(
    Uri.parse('$baseUrl/notifications/unread-count'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json['unread_count'] as int;
  }

  return 0;
}

Future<void> markAsRead(int notificationId, {http.Client? client}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.patch(
    Uri.parse('$baseUrl/notifications/$notificationId/read'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) return;

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to mark notification as read');
}
