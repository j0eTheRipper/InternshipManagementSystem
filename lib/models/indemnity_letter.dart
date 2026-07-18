class IndemnityLetterData {
  final int indemnityLetterId;
  final String studentId;
  final String file;
  final bool verified;

  IndemnityLetterData({
    required this.indemnityLetterId,
    required this.studentId,
    required this.file,
    required this.verified,
  });

  factory IndemnityLetterData.fromJson(Map<String, dynamic> json) {
    return IndemnityLetterData(
      indemnityLetterId: json['indemnity_letter_id'],
      studentId: json['student_id'],
      file: json['file'],
      verified: json['verified'] ?? false,
    );
  }
}
