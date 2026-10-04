
class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String kycStatus;
  final String role;
  final String accountStatus;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    required this.kycStatus,
    required this.role,
    required this.accountStatus,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      kycStatus: json['kycStatus'] as String? ?? 'pending',
      role: json['role'] as String? ?? 'user',
      accountStatus: json['accountStatus'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'kycStatus': kycStatus,
      'role': role,
      'accountStatus': accountStatus,
    };
  }
}