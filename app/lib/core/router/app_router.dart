import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/views/login_view.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const _HomePlaceholder(),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (context, state) => const _CompleteProfilePlaceholder(),
      ),
    ],
  );
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home (em construção)')),
    );
  }
}

class _CompleteProfilePlaceholder extends StatelessWidget {
  const _CompleteProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Completar perfil (em construção)')),
    );
  }
}
