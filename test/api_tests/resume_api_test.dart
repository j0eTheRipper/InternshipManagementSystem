import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:internship_management_system/api/resume.dart';
import 'package:internship_management_system/auth/auth_state.dart';
import 'package:internship_management_system/models/resume.dart';
import 'package:internship_management_system/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Resume API', () {
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

    test('getResume returns list on 200', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode([
          {
            'resume_id': 1,
            'student_id': 'TP001',
            'file': '/path/to/resume.pdf',
            'verified': false,
          },
        ]), 200),
      ]);

      final result = await getResume(client: client);

      expect(result.length, 1);
      expect(result[0].resumeId, 1);
      expect(client.requests[0].headers['Authorization'], 'Bearer test-token');
    });

    test('getResume includes studentId query param', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode([]), 200),
      ]);

      await getResume(studentId: 'TP002', client: client);

      expect(
        client.requests[0].url.toString(),
        contains('request_student_id=TP002'),
      );
    });

    test('getResume returns empty on 404', () async {
      final client = MockHttpClient([
        http.Response('Not found', 404),
      ]);

      expect(await getResume(client: client), []);
    });

    test('getResume throws on error', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Error'}), 500),
      ]);

      expect(() => getResume(client: client), throwsA(isA<Exception>()));
    });

    test('downloadResume returns bytes on 200', () async {
      final client = MockHttpClient([
        http.Response.bytes([0x25, 0x50, 0x44, 0x46], 200),
      ]);

      final result = await downloadResume(1, client: client);

      expect(result, [0x25, 0x50, 0x44, 0x46]);
      expect(result, isA<Uint8List>());
      expect(
        client.requests[0].url.toString(),
        'http://localhost:8000/resume/download/1',
      );
    });

    test('downloadResume throws on error', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Not found'}), 404),
      ]);

      expect(
        () => downloadResume(999, client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('approveResume succeeds on 200', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'message': 'ok'}), 200),
      ]);

      await approveResume(1, client: client);

      expect(client.requests[0].method, 'PATCH');
      expect(
        client.requests[0].url.toString(),
        'http://localhost:8000/resume/1/approve',
      );
    });

    test('approveResume throws on error', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Forbidden'}), 403),
      ]);

      expect(
        () => approveResume(1, client: client),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ResumeData model', () {
    test('fromJson parses correctly', () {
      final data = ResumeData.fromJson({
        'resume_id': 1,
        'student_id': 'TP001',
        'file': '/path/to/resume.pdf',
        'verified': true,
      });

      expect(data.resumeId, 1);
      expect(data.studentId, 'TP001');
      expect(data.verified, true);
    });

    test('toJson produces correct map', () {
      final data = ResumeData(
        resumeId: 1,
        studentId: 'TP001',
        file: '/path/to/resume.pdf',
        verified: false,
      );

      expect(data.toJson()['resume_id'], 1);
      expect(data.toJson()['verified'], false);
    });
  });
}
