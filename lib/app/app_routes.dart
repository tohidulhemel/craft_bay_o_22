import 'package:flutter/material.dart';

import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/otp_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/main_shell/main_shell.dart';
import '../presentation/screens/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp'; // argument: the email (String)
  static const String main = '/main';
  // More routes are added here as we build each screen.

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page;

    switch (settings.name) {
      case splash:
        page = const SplashScreen();
        break;
      case login:
        page = const LoginScreen();
        break;
      case signup:
        page = const SignupScreen();
        break;
      case otp:
        page = OtpScreen(email: settings.arguments as String);
        break;
      case main:
        page = const MainShell();
        break;
      default:
        page = Scaffold(
          body: Center(child: Text('No route for ${settings.name}')),
        );
    }

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}