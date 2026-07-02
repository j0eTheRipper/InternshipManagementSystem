class OfferLetter {
  final int offerLetterId;
  final int applicationId;
  final String studentId;
  final String file;
  final bool verified;
  final String? createdAt;

  OfferLetter({
    required this.offerLetterId,
    required this.applicationId,
    required this.studentId,
    required this.file,
    required this.verified,
    this.createdAt,
  });

  factory OfferLetter.fromJson(Map<String, dynamic> json) => OfferLetter(
    offerLetterId: json['offer_letter_id'],
    applicationId: json['application_id'],
    studentId: json['student_id'],
    file: json['file'],
    verified: json['verified'] ?? false,
    createdAt: json['created_at'],
  );
}
