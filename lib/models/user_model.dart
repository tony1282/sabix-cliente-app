// lib/models/user_model.dart
class UserModel {
  final int? id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? userType;
  final bool? isActive;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? token;
  final String? refreshToken;
  
  // ✅ SOLO CAMPOS DE CLIENTE
  final String? address;
  final String? preferredPaymentMethod;

  UserModel({
    this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.userType,
    this.isActive,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
    this.token,
    this.refreshToken,
    this.address,
    this.preferredPaymentMethod,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // El login devuelve {access, refresh, user: {...}}
    // El profile devuelve los campos directamente en la raíz
    final data = json['user'] is Map<String, dynamic>
        ? {...json['user'] as Map<String, dynamic>, 'access': json['access'], 'refresh': json['refresh']}
        : json;

    return UserModel(
      id: data['id'],
      username: data['username'] ?? '',
      email: data['email'],
      firstName: data['first_name'] ?? data['firstName'],
      lastName: data['last_name'] ?? data['lastName'],
      phone: data['phone'],
      userType: data['user_type'] ?? data['userType'],
      isActive: data['is_active'] ?? data['isActive'],
      profileImage: data['profile_image'] ?? data['profileImage'],
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'])
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at'])
          : null,
      token: data['access'] ?? data['token'],
      refreshToken: data['refresh'],
      address: data['address'],
      preferredPaymentMethod: data['preferred_payment_method'] ?? data['preferredPaymentMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      if (email != null) 'email': email,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phone != null) 'phone': phone,
      if (userType != null) 'user_type': userType,
      if (isActive != null) 'is_active': isActive,
      if (profileImage != null) 'profile_image': profileImage,
      if (address != null) 'address': address,
      if (preferredPaymentMethod != null) 'preferred_payment_method': preferredPaymentMethod,
      if (token != null) 'access': token,
      if (refreshToken != null) 'refresh': refreshToken,
    };
  }

  // ✅ REGISTRO - SIEMPRE CLIENTE
  Map<String, dynamic> toRegisterJson(String password) {
    return {
      'username': username,
      'password': password,
      'password2': password,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (firstName != null && firstName!.isNotEmpty) 'first_name': firstName,
      if (lastName != null && lastName!.isNotEmpty) 'last_name': lastName,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      'user_type': 'client',
      if (address != null && address!.isNotEmpty) 'address': address,
      if (preferredPaymentMethod != null && preferredPaymentMethod!.isNotEmpty) 
        'preferred_payment_method': preferredPaymentMethod,
    };
  }

  bool get isClient => userType == 'client';
  String get fullName => '$firstName $lastName'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : username;
}