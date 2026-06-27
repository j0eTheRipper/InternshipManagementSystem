class ResumeData {
  int resumeId;
  String studentId;
  String file;
  bool verified;

  ResumeData({
    required this.resumeId,
    required this.studentId,
    required this.file,
    required this.verified,
  });

  factory ResumeData.fromJson(Map<String, dynamic> json) {
    return ResumeData(
      resumeId: json['resume_id'],
      studentId: json['student_id'],
      file: json['file'],
      verified: json['verified'],
    );
  }

  Map<String, dynamic> toJson() => {
    'resume_id': resumeId,
    'student_id': studentId,
    'file': file,
    'verified': verified,
  };
}
