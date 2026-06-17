class User {
  int userId;
  String fullname;
  String email;
  String role;

  User({
    required this.userId,
    required this.fullname,
    required this.email,
    required this.role,
  });

  User.fromJson(Map<String, dynamic> json)
    : userId = json['user_id'],
      fullname = json['fullname'],
      email = json['email'],
      role = json['role'];

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'fullname': fullname,
    'email': email,
    'role': role,
  };
}
