import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

enum LoginOutcome { success, needsOtp, failed }

class AuthState extends ChangeNotifier {
  AuthState(this._repository);

  final AuthRepository _repository;

  bool _isLoading = false;
  bool _isProfileLoading = false;
  String? _errorMessage;
  UserProfile? _profile;

  bool get isLoading => _isLoading;
  bool get isProfileLoading => _isProfileLoading;
  String? get errorMessage => _errorMessage;
  UserProfile? get profile => _profile;

  Future<bool> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String city,
    required String address,
  }) {
    return _run(() => _repository.signup(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          phone: phone,
          city: city,
          address: address,
        ));
  }

  Future<LoginOutcome> login(String email, String password) async {
    final ok = await _run(
      () => _repository.login(email: email, password: password),
    );
    if (ok) return LoginOutcome.success;

    // If the server says the account is not verified, go to the OTP screen.
    final message = (_errorMessage ?? '').toLowerCase();
    if (message.contains('verif') || message.contains('otp')) {
      return LoginOutcome.needsOtp;
    }
    return LoginOutcome.failed;
  }

  Future<bool> verifyOtp(String email, String otp) =>
      _run(() => _repository.verifyOtp(email: email, otp: otp));

  Future<bool> resendOtp(String email) =>
      _run(() => _repository.resendOtp(email));

  Future<bool> loadProfile({bool force = false}) async {
    if (_isProfileLoading || (_profile != null && !force)) {
      return _profile != null;
    }

    _isProfileLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Could not load profile details.';
      return false;
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String address,
  }) {
    return _run(() async {
      _profile = await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        city: city,
        address: address,
      );
    });
  }

  Future<void> logout() async {
    await _repository.logout();
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Runs an action with loading and error handling. Returns true on success.
  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}