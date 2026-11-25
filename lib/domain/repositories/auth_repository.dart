import '../models/user_profile.dart';

abstract class AuthRepository {
  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String city,
    required String address,
  });

  // Saves the auth token on success.
  Future<void> login({required String email, required String password});

  Future<void> verifyOtp({required String email, required String otp});

  Future<void> resendOtp(String email);

  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String address,
  });

  Future<void> logout();
}