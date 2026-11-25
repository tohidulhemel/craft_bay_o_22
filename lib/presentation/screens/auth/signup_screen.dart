import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../state/auth_state.dart';
import 'widgets/auth_header.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthState>();
    final email = _emailController.text.trim();

    final ok = await auth.signup(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: email,
      password: _passwordController.text,
      phone: _mobileController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
    );
    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.otp, arguments: email);
    } else {
      SnackbarUtils.show(
        context,
        auth.errorMessage ?? 'Sign up failed.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthState>().isLoading;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Complete Profile',
                  subtitle: 'Get started with us with your details',
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _firstNameController,
                  hint: 'First Name',
                  validator: (v) =>
                      Validators.notEmpty(v, field: 'First name'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _lastNameController,
                  hint: 'Last Name',
                  validator: (v) => Validators.notEmpty(v, field: 'Last name'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _emailController,
                  hint: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  isPassword: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _mobileController,
                  hint: 'Mobile',
                  keyboardType: TextInputType.phone,
                  validator: Validators.mobile,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _cityController,
                  hint: 'City',
                  validator: (v) => Validators.notEmpty(v, field: 'City'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _addressController,
                  hint: 'Shipping Address',
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.notEmpty(v, field: 'Address'),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Sign up',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}