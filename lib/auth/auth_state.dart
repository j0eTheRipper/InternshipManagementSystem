import 'package:internship_management_system/login_screen/user_model.dart';

class AuthState {
  static User? _currentUser;
  static Student? _currentStudent;
  static bool _isLoggedIn = false;

  static User? get currentUser => _currentUser;
  static Student? get currentStudent => _currentStudent;
  static bool get isLoggedIn => _isLoggedIn;

  static String get currentRole {
    if (_currentUser == null) return '';
    return _currentUser!.role;
  }

  static bool get isStudent => currentRole == 'student';
  static bool get isMentor => currentRole == 'universityMentor';

  static void login(dynamic user) {
    if (user is Student) {
      _currentStudent = user;
      _currentUser = user.user;
    } else if (user is User) {
      _currentUser = user;
      _currentStudent = null;
    }
    _isLoggedIn = true;
  }

  static void logout() {
    _currentUser = null;
    _currentStudent = null;
    _isLoggedIn = false;
  }
}
