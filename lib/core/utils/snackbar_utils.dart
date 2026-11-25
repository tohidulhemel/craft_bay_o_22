import 'package:flutter/material.dart';

import '../../app/app_colors.dart';

class SnackbarUtils {
  SnackbarUtils._();

  static void show(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}