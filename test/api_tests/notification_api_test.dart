import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:internship_management_system/api/notification.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/notification.dart';
import 'package:internship_management_system/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Notification API', () {
    setUp(() {
      AuthState.login(
        User(
          userId: 1,
          fullname: 'Test',
          email: 'test@test.com',
          role: 'student',
        ),
        token: 'test-token',
      );
    });

    tearDown(() {
      AuthState.logout();
    });

    test('getNotifications returns list on 200', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode([
          {
            'notification_id': 1,
            'user_id': 1,
            'message': 'Resume uploaded',
            'type': 'resume_uploaded',
            'related_id': 5,
            'is_read': false,
            'created_at': '2026-06-27T10:00:00',
          },
        ]), 200),
      ]);

      final result = await getNotifications(client: client);

      expect(result.length, 1);
      expect(result[0].notificationId, 1);
      expect(result[0].message, 'Resume uploaded');
      expect(result[0].isRead, false);
      expect(client.requests[0].headers['Authorization'], 'Bearer test-token');
    });

    test('getNotifications throws on error', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Error'}), 500),
      ]);

      expect(
        () => getNotifications(client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('getUnreadCount returns count on 200', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'unread_count': 3}), 200),
      ]);

      expect(await getUnreadCount(client: client), 3);
    });

    test('getUnreadCount returns 0 on error', () async {
      final client = MockHttpClient([
        http.Response('error', 500),
      ]);

      expect(await getUnreadCount(client: client), 0);
    });

    test('markAsRead succeeds on 200', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'message': 'ok'}), 200),
      ]);

      await markAsRead(1, client: client);

      expect(client.requests[0].method, 'PATCH');
      expect(
        client.requests[0].url.toString(),
        'http://localhost:8000/notifications/1/read',
      );
    });

    test('markAsRead throws on error', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Not found'}), 404),
      ]);

      expect(
        () => markAsRead(999, client: client),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('NotificationData model', () {
    test('fromJson parses all fields', () {
      final data = NotificationData.fromJson({
        'notification_id': 1,
        'user_id': 1,
        'message': 'Test',
        'type': 'test_type',
        'related_id': 42,
        'is_read': false,
        'created_at': '2026-06-27T10:00:00',
      });

      expect(data.notificationId, 1);
      expect(data.userId, 1);
      expect(data.message, 'Test');
      expect(data.type, 'test_type');
      expect(data.relatedId, 42);
      expect(data.isRead, false);
      expect(data.createdAt, '2026-06-27T10:00:00');
    });

    test('fromJson handles null optionals', () {
      final data = NotificationData.fromJson({
        'notification_id': 2,
        'user_id': 2,
        'message': 'No optionals',
        'type': 'simple',
        'related_id': null,
        'is_read': true,
        'created_at': null,
      });

      expect(data.relatedId, null);
      expect(data.createdAt, null);
    });

    test('fromJson defaults is_read to false when missing', () {
      final data = NotificationData.fromJson({
        'notification_id': 3,
        'user_id': 3,
        'message': 'No is_read',
        'type': 'simple',
      });

      expect(data.isRead, false);
    });
  });
}
