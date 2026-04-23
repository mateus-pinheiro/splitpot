import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/views/complete_profile_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/home/presentation/views/home_view.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  AppRouter({required AuthCubit authCubit}) : _authCubit = authCubit;

  final AuthCubit _authCubit;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: GoRouterRefreshStream(_authCubit.stream),
    redirect: _redirect,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (_, _) => const CompleteProfileView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const HomeView(),
      ),
    ],
  );

  String? _redirect(BuildContext _, GoRouterState state) {
    final authState = _authCubit.state;
    final location = state.matchedLocation;

    return switch (authState) {
      AuthUnauthenticated() || AuthError() =>
        location == AppRoutes.login ? null : AppRoutes.login,
      AuthNeedsProfile() || AuthUpdatingProfile() =>
        location == AppRoutes.completeProfile ? null : AppRoutes.completeProfile,
      AuthAuthenticated() =>
        (location == AppRoutes.login || location == AppRoutes.completeProfile)
            ? AppRoutes.home
            : null,
      AuthAuthenticating() => null,
    };
  }
}
