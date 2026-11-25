import 'package:flutter/material.dart';

import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/otp_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/main_shell/main_shell.dart';
import '../presentation/screens/products/product_details_screen.dart';
import '../presentation/screens/products/product_list_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/reviews/create_review_screen.dart';
import '../presentation/screens/reviews/reviews_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp'; // argument: the email (String)
  static const String main = '/main';
  static const String profile = '/profile';
  static const String productList = '/products'; // argument: ProductListArgs
  static const String productDetails =
      '/product-details'; // argument: ProductDetailsArgs
  static const String reviews = '/reviews'; // argument: productId (String)
  static const String createReview =
      '/create-review'; // argument: productId (String)
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
      case profile:
        page = const ProfileScreen();
        break;
      case productList:
        final args = settings.arguments as ProductListArgs?;
        page = ProductListScreen(
          args: args ?? const ProductListArgs(title: 'Products'),
        );
        break;
      case productDetails:
        final args = settings.arguments as ProductDetailsArgs;
        page = ProductDetailsScreen(args: args);
        break;
      case reviews:
        page = ReviewsScreen(productId: settings.arguments as String);
        break;
      case createReview:
        page = CreateReviewScreen(productId: settings.arguments as String);
        break;
      default:
        page = Scaffold(
          body: Center(child: Text('No route for ${settings.name}')),
        );
    }

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}