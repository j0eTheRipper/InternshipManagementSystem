class User {
  int userId;
  String fullname;
  String email;
  String role;

  User({
    required this.userId,
    required this.fullname,
    required this.email,
    required this.role,
  });

  User.fromJson(Map<String, dynamic> json)
      : userId = json['user_id'],
        fullname = json['fullname'],
        email = json['email'],
        role = json['role'];

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'fullname': fullname,
        'email': email,
        'role': role,
      };
}

class Student {
  User user;
  User universityMentor;
  int yearOfStudy;
  String fieldOfStudy;
  String studentId;

  Student({
    required this.user,
    required this.universityMentor,
    required this.yearOfStudy,
    required this.fieldOfStudy,
    required this.studentId,
  });

  Student.fromJson(Map<String, dynamic> json)
      : user = User.fromJson(json['user']),
        universityMentor = User.fromJson(json['university_mentor']),
        yearOfStudy = json['year_of_study'],
        fieldOfStudy = json['field_of_study'],
        studentId = json['student_id'];

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'university_mentor': universityMentor.toJson(),
        'year_of_study': yearOfStudy,
        'field_of_study': fieldOfStudy,
        'student_id': studentId,
      };
}
