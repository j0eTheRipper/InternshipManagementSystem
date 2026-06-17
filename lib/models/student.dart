import 'user.dart';

class Student {
  User user;
  User universityMentor;
  int yearOfStudy;
  String fieldOfStudy;
  String studentId;
  String progress;

  Student({
    required this.user,
    required this.universityMentor,
    required this.yearOfStudy,
    required this.fieldOfStudy,
    required this.studentId,
    required this.progress,
  });

  Student.fromJson(Map<String, dynamic> json)
    : user = User.fromJson(json['user']),
      universityMentor = User.fromJson(json['university_mentor']),
      yearOfStudy = json['year_of_study'],
      fieldOfStudy = json['field_of_study'],
      studentId = json['student_id'],
      progress = json['progress'];

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'university_mentor': universityMentor.toJson(),
    'year_of_study': yearOfStudy,
    'field_of_study': fieldOfStudy,
    'student_id': studentId,
    'progress': progress,
  };
}
