import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:internship_management_system/api/admin.dart';
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
        fullname: 'Admin',
        email: 'admin@system.com',
        role: 'admin',
      ),
      token: 'test-token',
    );
  });

  tearDown(() {
    AuthState.logout();
  });

  group('getAllStudents', () {
    test('returns list of students on 200', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode([
          {
            'user': {'user_id': 1, 'fullname': 'John', 'email': 'j@e.com', 'role': 'student'},
            'university_mentor': {'user_id': 2, 'fullname': 'Mentor', 'email': 'm@e.com', 'role': 'universityMentor'},
            'year_of_study': 2,
            'field_of_study': 'CS',
            'student_id': 'TP0112233',
            'progress': 'none',
            'internship_start_date': null,
            'internship_duration_weeks': null,
          },
        ]), 200),
      ]);

      final result = await getAllStudents(client: client);

      expect(result.length, 1);
      expect(result[0].studentId, 'TP0112233');
      expect(client.requests[0].headers['Authorization'], 'Bearer test-token');
    });

    test('returns empty list when no students', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode([]), 200),
      ]);

      final result = await getAllStudents(client: client);
      expect(result, isEmpty);
    });

    test('throws on error response', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Forbidden'}), 403),
      ]);

      expect(
        () => getAllStudents(client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('sends GET to correct endpoint', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode([]), 200),
      ]);

      await getAllStudents(client: client);

      expect(client.requests[0].method, 'GET');
      expect(client.requests[0].url.toString(), 'http://localhost:8000/admin/students');
    });
  });

  group('createStudent', () {
    test('sends POST with correct body on success', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'message': 'Student created'}), 200),
      ]);

      await createStudent(
        fullname: 'New Student',
        email: 'new@e.com',
        password: 'pass123',
        studentId: 'TP0555666',
        yearOfStudy: 3,
        fieldOfStudy: 'Engineering',
        mentorId: 200,
        client: client,
      );

      expect(client.requests[0].method, 'POST');
      final body = jsonDecode((client.requests[0] as http.Request).body);
      expect(body['fullname'], 'New Student');
      expect(body['student_id'], 'TP0555666');
      expect(body['mentor_id'], 200);
    });

    test('throws on error response', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Email already registered'}), 409),
      ]);

      expect(
        () => createStudent(
          fullname: 'Dup',
          email: 'dup@e.com',
          password: 'pass123',
          studentId: 'TP0000000',
          yearOfStudy: 1,
          fieldOfStudy: 'CS',
          mentorId: 200,
          client: client,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getAllMentors', () {
    test('returns list of mentors on 200', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode([
          {'user_id': 2, 'fullname': 'Mentor One', 'email': 'm@e.com', 'role': 'universityMentor'},
        ]), 200),
      ]);

      final result = await getAllMentors(client: client);

      expect(result.length, 1);
      expect(result[0].fullname, 'Mentor One');
    });

    test('throws on error', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Forbidden'}), 403),
      ]);

      expect(
        () => getAllMentors(client: client),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('createMentor', () {
    test('sends POST with correct body on success', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'message': 'Mentor created'}), 200),
      ]);

      await createMentor(
        fullname: 'New Mentor',
        email: 'nm@e.com',
        password: 'pass123',
        client: client,
      );

      expect(client.requests[0].method, 'POST');
      final body = jsonDecode((client.requests[0] as http.Request).body);
      expect(body['fullname'], 'New Mentor');
    });
  });

  group('updateStudentProgress', () {
    test('sends PATCH with correct body', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'message': 'Progress updated'}), 200),
      ]);

      await updateStudentProgress('TP0112233', 'accepted', client: client);

      expect(client.requests[0].method, 'PATCH');
      expect(
        client.requests[0].url.toString(),
        'http://localhost:8000/admin/students/TP0112233/progress',
      );
      final body = jsonDecode((client.requests[0] as http.Request).body);
      expect(body['progress'], 'accepted');
    });
  });

  group('updateStudentMentor', () {
    test('sends PATCH with correct body', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'message': 'Mentor updated'}), 200),
      ]);

      await updateStudentMentor('TP0112233', 300, client: client);

      expect(client.requests[0].method, 'PATCH');
      expect(
        client.requests[0].url.toString(),
        'http://localhost:8000/admin/students/TP0112233/mentor',
      );
      final body = jsonDecode((client.requests[0] as http.Request).body);
      expect(body['mentor_id'], 300);
    });
  });

  group('addAttendance', () {
    test('sends POST with correct body', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'message': 'Attendance added'}), 200),
      ]);

      await addAttendance('TP0112233', '2024-07-15', client: client);

      expect(client.requests[0].method, 'POST');
      final body = jsonDecode((client.requests[0] as http.Request).body);
      expect(body['student_id'], 'TP0112233');
      expect(body['date'], '2024-07-15');
    });
  });

  group('deleteAttendance', () {
    test('sends DELETE to correct endpoint', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'message': 'Attendance deleted'}), 200),
      ]);

      await deleteAttendance(42, client: client);

      expect(client.requests[0].method, 'DELETE');
      expect(
        client.requests[0].url.toString(),
        'http://localhost:8000/admin/attendance/42',
      );
    });
  });

  group('getStudentAttendance', () {
    test('returns list of records on 200', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode([
          {'attendance_id': 1, 'student_id': 'TP0112233', 'checked_at': '2024-07-15 09:00:00'},
          {'attendance_id': 2, 'student_id': 'TP0112233', 'checked_at': '2024-07-14 08:30:00'},
        ]), 200),
      ]);

      final result = await getStudentAttendance('TP0112233', client: client);

      expect(result.length, 2);
      expect(result[0]['attendance_id'], 1);
    });

    test('throws on error', () async {
      final client = MockHttpClient([
        http.Response(jsonEncode({'detail': 'Forbidden'}), 403),
      ]);

      expect(
        () => getStudentAttendance('TP0112233', client: client),
        throwsA(isA<Exception>()),
      );
    });
  });
}
