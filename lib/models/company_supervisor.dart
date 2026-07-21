import 'user.dart';

class CompanySupervisor {
  User user;
  String company;

  CompanySupervisor({
    required this.user,
    required this.company,
  });

  factory CompanySupervisor.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>;
    final companyRaw = json['company'];
    String companyName;
    if (companyRaw is Map<String, dynamic>) {
      companyName = companyRaw['name'] as String? ?? '';
    } else if (companyRaw is String) {
      companyName = companyRaw;
    } else {
      companyName = '';
    }
    return CompanySupervisor(
      user: User.fromJson(userJson),
      company: companyName,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'company': company,
  };
}
