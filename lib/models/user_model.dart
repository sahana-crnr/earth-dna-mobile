class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? country;
  final String? zipCode;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.country,
    this.zipCode,
    this.role = 'USER',
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      country: json['country'] as String?,
      zipCode: json['zipCode'] as String?,
      role: json['role'] as String? ?? 'USER',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'country': country,
        'zipCode': zipCode,
        'role': role,
        'createdAt': createdAt?.toIso8601String(),
      };
}

