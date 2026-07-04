class Application {
  int applicationId;
  String studentId;
  int? opportunityId;
  int resumeId;
  String status;
  bool isExternal;
  String? companyName;
  String? jobTitle;
  String? jobMode;
  String? companyLocation;
  String? applicationScreenshot;

  Application({
    required this.applicationId,
    required this.studentId,
    this.opportunityId,
    required this.resumeId,
    required this.status,
    this.isExternal = false,
    this.companyName,
    this.jobTitle,
    this.jobMode,
    this.companyLocation,
    this.applicationScreenshot,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    final isExternal = json['is_external'] == true;
    return Application(
      applicationId: json['application_id'],
      studentId: json['student_id'],
      opportunityId: json['opportunity_id'],
      resumeId: json['resume_id'],
      status: json['status'],
      isExternal: isExternal,
      companyName: json['company_name'],
      jobTitle: json['job_title'],
      jobMode: json['job_mode'],
      companyLocation: json['company_location'],
      applicationScreenshot: json['application_screenshot'],
    );
  }

  Map<String, dynamic> toJson() => {
    'application_id': applicationId,
    'student_id': studentId,
    'opportunity_id': opportunityId,
    'resume_id': resumeId,
    'status': status,
    'is_external': isExternal,
    'company_name': companyName,
    'job_title': jobTitle,
    'job_mode': jobMode,
    'company_location': companyLocation,
    'application_screenshot': applicationScreenshot,
  };
}
