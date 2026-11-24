import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Login screen (coming in the next step)'),
              const SizedBox(height: 16),
              // TEMPORARY: lets us look at the main shell before auth exists.
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.main),
                child: const Text('Skip (temporary)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}