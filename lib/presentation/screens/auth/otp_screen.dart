import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/primary_button.dart';
import '../../state/auth_state.dart';
import 'widgets/auth_header.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.email});

  final String email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 4;
  static const int _expirySeconds = 120;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = _expirySeconds;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _expirySeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
      });
      if (_secondsLeft == 0) timer.cancel();
    });
  }

  Future<void> _verify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < _otpLength) {
      SnackbarUtils.show(context, 'Please enter the 4 digit code.',
          isError: true);
      return;
    }
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthState>();
    final ok = await auth.verifyOtp(widget.email, code);
    if (!mounted) return;

    if (ok) {
      SnackbarUtils.show(context, 'Email verified. Please log in.');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } else {
      SnackbarUtils.show(
        context,
        auth.errorMessage ?? 'Verification failed.',
        isError: true,
      );
    }
  }

  Future<void> _resend() async {
    final auth = context.read<AuthState>();
    final ok = await auth.resendOtp(widget.email);
    if (!mounted) return;

    if (ok) {
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
      setState(_startTimer);
      SnackbarUtils.show(context, 'A new code has been sent.');
    } else {
      SnackbarUtils.show(
        context,
        auth.errorMessage ?? 'Could not resend the code.',
        isError: true,
      );
    }
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 52,
      height: 52,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < _otpLength - 1) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthState>().isLoading;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Enter OTP Code',
                  subtitle: 'A 4 Digit OTP Code has been Sent',
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _otpLength; i++) ...[
                      if (i > 0) const SizedBox(width: 14),
                      _otpBox(i),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Next',
                  isLoading: isLoading,
                  onPressed: _verify,
                ),
                const SizedBox(height: 24),
                Text.rich(
                  TextSpan(
                    text: 'This code will expire in ',
                    children: [
                      TextSpan(
                        text: '${_secondsLeft}s',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textGrey),
                ),
                TextButton(
                  onPressed:
                      _secondsLeft == 0 && !isLoading ? _resend : null,
                  child: const Text('Resend Code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}