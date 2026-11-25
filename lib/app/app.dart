import 'package:craft_bay_app/app/dependency_injection.dart';
import 'package:craft_bay_app/data/datasources/auth_remote_datasource.dart';
import 'package:craft_bay_app/data/repositories/auth_repository_impl.dart';
import 'package:craft_bay_app/presentation/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/state/nav_state.dart';
import 'app_constants.dart';
import 'app_routes.dart';
import 'app_theme.dart';

class CraftyBayApp extends StatelessWidget {
  const CraftyBayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavState()),
         ChangeNotifierProvider(
          create: (_) => AuthState(
            AuthRepositoryImpl(
              AuthRemoteDataSource(AppDependencies.apiClient),
              AppDependencies.authStorage,
            ),
          ),
        ),
        // More providers will be added here in later steps.
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}