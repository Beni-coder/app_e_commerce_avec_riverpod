import 'package:equatable/equatable.dart';

/// Mock authenticated user shown on the profile screen.
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.loyaltyPoints,
    required this.memberSince,
    required this.avatarInitials,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final int loyaltyPoints;
  final DateTime memberSince;
  final String avatarInitials;

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? city,
    int? loyaltyPoints,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      memberSince: memberSince,
      avatarInitials: _initials(fullName ?? this.fullName),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  List<Object?> get props => [id, fullName, email, phone, address, city, loyaltyPoints];
}
