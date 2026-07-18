class PlacementAgreementData {
  final int placementAgreementId;
  final String studentId;
  final String file;
  final bool verified;

  PlacementAgreementData({
    required this.placementAgreementId,
    required this.studentId,
    required this.file,
    required this.verified,
  });

  factory PlacementAgreementData.fromJson(Map<String, dynamic> json) {
    return PlacementAgreementData(
      placementAgreementId: json['placement_agreement_id'],
      studentId: json['student_id'],
      file: json['file'],
      verified: json['verified'] ?? false,
    );
  }
}
