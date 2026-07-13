import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:internship_management_system/api/attendance.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('getAttendanceHistory', () {
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

    test('returns list of records on 200', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode([
          {
            'attendance_id': 1,
            'student_id': 'TP0112233',
            'checked_at': '2025-07-10 09:00:00',
          },
          {
            'attendance_id': 2,
            'student_id': 'TP0112233',
            'checked_at': '2025-07-09 09:15:00',
          },
        ]), 200),
      ]);

      final result = await getAttendanceHistory(client: client);

      expect(result.length, 2);
      expect(result[0]['attendance_id'], 1);
      expect(result[0]['checked_at'], '2025-07-10 09:00:00');
      expect(result[1]['attendance_id'], 2);
      expect(client.requests[0].headers['Authorization'], 'Bearer test-token');
    });

    test('returns empty list when no records', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode([]), 200),
      ]);

      final result = await getAttendanceHistory(client: client);

      expect(result, isEmpty);
    });

    test('throws on error response', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Forbidden'}), 403),
      ]);

      expect(
        () => getAttendanceHistory(client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('sends GET request to correct endpoint', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode([]), 200),
      ]);

      await getAttendanceHistory(client: client);

      expect(client.requests[0].method, 'GET');
      expect(
        client.requests[0].url.toString(),
        'http://localhost:8000/attendance/history',
      );
    });
  });
}
