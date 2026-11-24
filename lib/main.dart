import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDependencies.init();
  runApp(const CraftyBayApp());
}