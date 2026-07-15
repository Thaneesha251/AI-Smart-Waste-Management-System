enum UserRole { citizen, worker, municipality, admin }

class User {
  final int? id;
  final String fullName;
  final String email;
  final String? phone;
  final String? password;
  final UserRole role;
  final String? profileImage;
  final String? area;
  final String? address;

  User({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.password,
    required this.role,
    this.profileImage,
    this.area,
    this.address,
  });

  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? password,
    UserRole? role,
    String? profileImage,
    String? area,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      area: area ?? this.area,
      address: address ?? this.address,
    );
  }

  static UserRole _parseRole(dynamic role) {
    if (role == null) return UserRole.citizen;
    if (role is int) {
      if (role >= 0 && role < UserRole.values.length) {
        return UserRole.values[role];
      }
      return UserRole.citizen;
    }
    if (role is String) {
      switch (role.toLowerCase()) {
        case 'citizen':
          return UserRole.citizen;
        case 'worker':
          return UserRole.worker;
        case 'municipality':
          return UserRole.municipality;
        case 'admin':
          return UserRole.admin;
        default:
          return UserRole.citizen;
      }
    }
    return UserRole.citizen;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      if (password != null) 'password': password,
      'role': role.index,
      'profileImage': profileImage,
      'area': area,
      'address': address,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      password: json['password'] as String?,
      role: _parseRole(json['role']),
      profileImage: json['profileImage'] as String?,
      area: json['area'] as String?,
      address: json['address'] as String?,
    );
  }
}
