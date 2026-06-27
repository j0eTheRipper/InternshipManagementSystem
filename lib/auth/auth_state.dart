import 'dart:convert';

import 'package:internship_management_system/models/student.dart';
import 'package:internship_management_system/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  static User? _currentUser;
  static Student? _currentStudent;
  static String? _token;
  static bool _isLoggedIn = false;

  static User? get currentUser => _currentUser;
  static Student? get currentStudent => _currentStudent;
  static String? get token => _token;
  static bool get isLoggedIn => _isLoggedIn;

  static String get currentRole {
    if (_currentUser == null) return '';
    return _currentUser!.role;
  }

  static bool get isStudent => currentRole == 'student';
  static bool get isMentor => currentRole == 'universityMentor';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_json');
    if (userJson == null) return;

    try {
      final json = jsonDecode(userJson);
      if (json['user'] != null) {
        _currentStudent = Student.fromJson(json);
        _currentUser = _currentStudent!.user;
      } else {
        _currentUser = User.fromJson(json);
        _currentStudent = null;
      }
      _isLoggedIn = true;
    } catch (_) {
      await prefs.remove('user_json');
      await prefs.remove('auth_token');
      _token = null;
    }
  }

  static Future<void> login(dynamic user, {required String token}) async {
    _token = token;
    if (user is Student) {
      _currentStudent = user;
      _currentUser = user.user;
    } else if (user is User) {
      _currentUser = user;
      _currentStudent = null;
    }
    _isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    if (user is Student) {
      await prefs.setString('user_json', jsonEncode(user.toJson()));
    } else if (user is User) {
      await prefs.setString('user_json', jsonEncode(user.toJson()));
    }
    await prefs.setString('auth_token', token);
  }

  static void updateStudentData(Student student) {
    _currentStudent = student;
    _currentUser = student.user;
  }

  static Future<void> logout() async {
    _currentUser = null;
    _currentStudent = null;
    _token = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_json');
    await prefs.remove('auth_token');
  }
}
