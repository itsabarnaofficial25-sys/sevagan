class UserModel {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? role;

  UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}