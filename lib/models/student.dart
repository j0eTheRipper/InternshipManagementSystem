import 'user.dart';

String? _emptyToNull(dynamic value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}

class Student {
  User user;
  User universityMentor;
  int yearOfStudy;
  String fieldOfStudy;
  String studentId;
  String progress;
  String? internshipStartDate;
  int? internshipDurationWeeks;
  User? companySupervisor;

  Student({
    required this.user,
    required this.universityMentor,
    required this.yearOfStudy,
    required this.fieldOfStudy,
    required this.studentId,
    required this.progress,
    this.internshipStartDate,
    this.internshipDurationWeeks,
    this.companySupervisor,
  });

  Student.fromJson(Map<String, dynamic> json)
    : user = User.fromJson(json['user']),
      universityMentor = User.fromJson(json['university_mentor']),
      yearOfStudy = json['year_of_study'],
      fieldOfStudy = json['field_of_study'],
      studentId = json['student_id'],
      progress = json['progress'],
      internshipStartDate = _emptyToNull(json['internship_start_date']),
      internshipDurationWeeks = json['internship_duration_weeks'],
      companySupervisor = json['company_supervisor'] != null
          ? User.fromJson(json['company_supervisor'])
          : null;

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'university_mentor': universityMentor.toJson(),
    'year_of_study': yearOfStudy,
    'field_of_study': fieldOfStudy,
    'student_id': studentId,
    'progress': progress,
    if (internshipStartDate != null) 'internship_start_date': internshipStartDate,
    if (internshipDurationWeeks != null) 'internship_duration_weeks': internshipDurationWeeks,
    if (companySupervisor != null) 'company_supervisor': companySupervisor!.toJson(),
  };
}
