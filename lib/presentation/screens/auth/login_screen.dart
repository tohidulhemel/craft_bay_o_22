import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../state/auth_state.dart';
import 'widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthState>();
    final email = _emailController.text.trim();
    final outcome = await auth.login(email, _passwordController.text);
    if (!mounted) return;

    switch (outcome) {
      case LoginOutcome.success:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.main,
          (route) => false,
        );
        break;
      case LoginOutcome.needsOtp:
        SnackbarUtils.show(context, 'Please verify your email first.');
        Navigator.pushNamed(context, AppRoutes.otp, arguments: email);
        break;
      case LoginOutcome.failed:
        SnackbarUtils.show(
          context,
          auth.errorMessage ?? 'Login failed.',
          isError: true,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthState>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Welcome Back',
                    subtitle: 'Please enter your email and password',
                  ),
                  const SizedBox(height: 28),
                  AppTextField(
                    controller: _emailController,
                    hint: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    validator: (v) =>
                        Validators.notEmpty(v, field: 'Password'),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Login',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.signup),
                        child: const Text('Sign up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}