enum UserRole { citizen, worker, municipality, admin }

class User {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final UserRole role;
  final String? profileImage;

  User({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role.index,
      'profileImage': profileImage,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      role: UserRole.values[json['role']],
      profileImage: json['profileImage'],
    );
  }
}
