import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/conversation.dart';
import 'package:internship_management_system/models/contact.dart';
import 'package:internship_management_system/models/message.dart';
import 'package:internship_management_system/config.dart';

Future<List<ConversationData>> getConversations({http.Client? client}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.get(
    Uri.parse('$baseUrl/chat/conversations'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final list = json['conversations'] as List;
    return list.map((e) => ConversationData.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch conversations');
}

Future<int> createOrGetConversation(int otherUserId, {http.Client? client}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.post(
    Uri.parse('$baseUrl/chat/conversations'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'user_id': otherUserId}),
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json['conversation_id'] as int;
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to create conversation');
}

Future<List<MessageData>> getMessages(
  int conversationId, {
  int? before,
  http.Client? client,
}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final uri = Uri.parse('$baseUrl/chat/conversations/$conversationId/messages').replace(
    queryParameters: {
      if (before != null) 'before': before.toString(),
    },
  );
  final response = await c.get(
    uri,
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final list = json['messages'] as List;
    return list.map((e) => MessageData.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch messages');
}

Future<int> getChatUnreadTotal({http.Client? client}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.get(
    Uri.parse('$baseUrl/chat/unread-total'),
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

Future<void> markConversationRead(int conversationId, {http.Client? client}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.patch(
    Uri.parse('$baseUrl/chat/conversations/$conversationId/read'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);
}

Future<List<ContactData>> getContacts({http.Client? client}) async {
  final c = client ?? http.Client();
  final token = AuthState.token;
  final response = await c.get(
    Uri.parse('$baseUrl/chat/contacts'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (client == null) c.close();

  AuthState.requireAuth(response);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final list = json['contacts'] as List;
    return list.map((e) => ContactData.fromJson(e)).toList();
  }

  final json = jsonDecode(response.body);
  throw Exception(json['detail'] ?? 'Failed to fetch contacts');
}
