import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_model.dart';

/// Holds the mock authenticated user profile.
class ProfileNotifier extends StateNotifier<UserModel> {
  ProfileNotifier()
      : super(
          UserModel(
            id: 'u_001',
            fullName: 'Camille Laurent',
            email: 'camille.laurent@exemple.fr',
            phone: '+33 6 12 34 56 78',
            address: '14 rue des Lilas',
            city: 'Lyon',
            loyaltyPoints: 320,
            memberSince: DateTime(2024, 3, 12),
            avatarInitials: 'CL',
          ),
        );

  void updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? city,
  }) {
    state = state.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
      city: city,
    );
  }

  void addLoyaltyPoints(int points) {
    state = state.copyWith(loyaltyPoints: state.loyaltyPoints + points);
  }
}

/// The mock user profile state.
final profileProvider = StateNotifierProvider<ProfileNotifier, UserModel>(
  (ref) => ProfileNotifier(),
);
