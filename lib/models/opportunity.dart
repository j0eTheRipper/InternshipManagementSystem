class Opportunity {
  int opportunityId;
  String title;
  String jobRole;
  String description;
  String location;
  String status;
  int headhunterId;
  String? createdAt;
  String? company;

  Opportunity({
    required this.opportunityId,
    required this.title,
    required this.jobRole,
    required this.description,
    required this.location,
    required this.status,
    required this.headhunterId,
    this.createdAt,
    this.company,
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      opportunityId: json['opportunity_id'],
      title: json['title'],
      jobRole: json['job_role'],
      description: json['description'],
      location: json['location'],
      status: json['status'],
      headhunterId: json['headhunter_id'],
      createdAt: json['created_at'],
      company: json['company'],
    );
  }

  Map<String, dynamic> toJson() => {
    'opportunity_id': opportunityId,
    'title': title,
    'job_role': jobRole,
    'description': description,
    'location': location,
    'status': status,
    'headhunter_id': headhunterId,
    'created_at': createdAt,
    'company': company,
  };
}
