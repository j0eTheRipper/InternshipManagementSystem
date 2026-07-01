class Application {
  int applicationId;
  String studentId;
  int opportunityId;
  int resumeId;
  String status;

  Application({
    required this.applicationId,
    required this.studentId,
    required this.opportunityId,
    required this.resumeId,
    required this.status,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      applicationId: json['application_id'],
      studentId: json['student_id'],
      opportunityId: json['opportunity_id'],
      resumeId: json['resume_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'application_id': applicationId,
    'student_id': studentId,
    'opportunity_id': opportunityId,
    'resume_id': resumeId,
    'status': status,
  };
}
