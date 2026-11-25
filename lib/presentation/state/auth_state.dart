import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';

enum LoginOutcome { success, needsOtp, failed }

class AuthState extends ChangeNotifier {
  AuthState(this._repository);

  final AuthRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<void> logout() => _repository.logout();

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