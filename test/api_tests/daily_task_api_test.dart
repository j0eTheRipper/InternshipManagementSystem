import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:internship_management_system/api/daily_task.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

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

  group('submitDailyTask', () {
    test('returns success on 200', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({
          'message': 'Daily task submitted',
          'daily_task_id': 1,
        }), 200),
      ]);

      final result = await submitDailyTask(
        updateText: 'Built auth',
        client: client,
      );

      expect(result['message'], 'Daily task submitted');
      expect(result['daily_task_id'], 1);
      expect(client.requests[0].headers['Authorization'], 'Bearer test-token');
    });

    test('throws on error response', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Not accepted'}), 400),
      ]);

      expect(
        () => submitDailyTask(updateText: 'Tasks', client: client),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getTodayTask', () {
    test('returns record on 200', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({
          'daily_task_id': 1,
          'student_id': 'TP0112233',
          'update_text': 'Built auth',
          'update_date': '2025-07-10',
          'week_start_date': '2025-07-07',
          'week_end_date': '2025-07-13',
          'submitted_at': '2025-07-10 10:00:00',
        }), 200),
      ]);

      final result = await getTodayTask(client: client);

      expect(result, isNotNull);
      expect(result!['update_text'], 'Built auth');
      expect(result['update_date'], '2025-07-10');
    });

    test('returns null when no task today', () async {
      final client = MockHttpClient([
        http.Response('null', 200),
      ]);

      final result = await getTodayTask(client: client);

      expect(result, isNull);
    });

    test('throws on server error', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Server error'}), 500),
      ]);

      expect(
        () => getTodayTask(client: client),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getDailyTaskHistory', () {
    test('returns list on 200', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode([
          {'daily_task_id': 1, 'update_text': 'Task 1', 'update_date': '2025-07-10'},
          {'daily_task_id': 2, 'update_text': 'Task 2', 'update_date': '2025-07-11'},
        ]), 200),
      ]);

      final result = await getDailyTaskHistory(client: client);

      expect(result.length, 2);
      expect(result[0]['update_text'], 'Task 1');
    });

    test('throws on error', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Forbidden'}), 403),
      ]);

      expect(
        () => getDailyTaskHistory(client: client),
        throwsA(isA<Exception>()),
      );
    });
  });
}
