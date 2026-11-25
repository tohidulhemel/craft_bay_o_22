import 'package:craft_bay_app/app/dependency_injection.dart';
import 'package:craft_bay_app/data/datasources/auth_remote_datasource.dart';
import 'package:craft_bay_app/data/datasources/cart_remote_datasource.dart';
import 'package:craft_bay_app/data/datasources/catalog_remote_datasource.dart';
import 'package:craft_bay_app/data/datasources/wishlist_remote_datasource.dart';
import 'package:craft_bay_app/data/repositories/auth_repository_impl.dart';
import 'package:craft_bay_app/data/repositories/cart_repository_impl.dart';
import 'package:craft_bay_app/data/repositories/catalog_repository_impl.dart';
import 'package:craft_bay_app/data/repositories/wishlist_repository_impl.dart';
import 'package:craft_bay_app/domain/repositories/catalog_repository.dart';
import 'package:craft_bay_app/presentation/state/auth_state.dart';
import 'package:craft_bay_app/presentation/state/cart_state.dart';
import 'package:craft_bay_app/presentation/state/category_state.dart';
import 'package:craft_bay_app/presentation/state/home_state.dart';
import 'package:craft_bay_app/presentation/state/wishlist_state.dart';
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
    final catalogRepository = CatalogRepositoryImpl(
      CatalogRemoteDataSource(AppDependencies.apiClient),
    );
    final cartRepository = CartRepositoryImpl(
      CartRemoteDataSource(AppDependencies.apiClient),
    );
    final wishlistRepository = WishlistRepositoryImpl(
      WishlistRemoteDataSource(AppDependencies.apiClient),
    );

    return MultiProvider(
      providers: [
        Provider<CatalogRepository>.value(value: catalogRepository),
        ChangeNotifierProvider(create: (_) => NavState()),
        ChangeNotifierProvider(
          create: (_) => AuthState(
            AuthRepositoryImpl(
              AuthRemoteDataSource(AppDependencies.apiClient),
              AppDependencies.authStorage,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeState(catalogRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryState(catalogRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CartState(cartRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => WishlistState(wishlistRepository),
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