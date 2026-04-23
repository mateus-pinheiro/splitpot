import 'package:flutter/material.dart';

import 'core/di/app_dependencies.dart';
import 'core/di/di_container.dart';
import 'core/di/get_it_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  setAppDI(GetItContainer());
  registerAppDependencies(appDI);

  runApp(const SplitPotApp());
}

class SplitPotApp extends StatefulWidget {
  const SplitPotApp({super.key});

  @override
  State<SplitPotApp> createState() => _SplitPotAppState();
}

class _SplitPotAppState extends State<SplitPotApp> {
  final AppRouter _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SplitPot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router.router,
    );
  }
}
