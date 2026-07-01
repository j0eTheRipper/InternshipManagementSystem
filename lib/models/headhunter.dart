import 'user.dart';

class Headhunter {
  User user;
  String company;

  Headhunter({
    required this.user,
    required this.company,
  });

  factory Headhunter.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>;
    final companyJson = json['company'] as Map<String, dynamic>?;
    return Headhunter(
      user: User.fromJson(userJson),
      company: companyJson != null ? companyJson['name'] as String : (json['company'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'company': company,
  };
}
