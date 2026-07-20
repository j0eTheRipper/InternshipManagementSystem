class ContactData {
  int userId;
  String fullname;
  String email;
  String role;

  ContactData({
    required this.userId,
    required this.fullname,
    required this.email,
    required this.role,
  });

  factory ContactData.fromJson(Map<String, dynamic> json) {
    return ContactData(
      userId: json['user_id'],
      fullname: json['fullname'],
      email: json['email'],
      role: json['role'],
    );
  }
}
