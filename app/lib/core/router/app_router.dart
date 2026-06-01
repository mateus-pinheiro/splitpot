import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/cubit.dart';
import '../../features/auth/presentation/views/views.dart';
import '../../features/home/presentation/views/home_view.dart';
import '../../features/tables/presentation/views/views.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';

Page<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enter = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOutCubic));

      final exit = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.25, 0.0),
      ).chain(CurveTween(curve: Curves.easeInOutCubic));

      return SlideTransition(
        position: secondaryAnimation.drive(exit),
        child: SlideTransition(
          position: animation.drive(enter),
          child: child,
        ),
      );
    },
  );
}

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
        pageBuilder: (_, s) => _slide(s, const LoginView()),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        pageBuilder: (_, s) => _slide(s, const CompleteProfileView()),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (_, s) => _slide(s, const HomeView()),
      ),
      GoRoute(
        path: AppRoutes.createTable,
        pageBuilder: (_, s) => _slide(
          s,
          CreateTableView(
            initialName: s.uri.queryParameters['name'],
            initialMinBuyIn: s.uri.queryParameters['minBuyIn'],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.joinTable,
        pageBuilder: (_, s) => _slide(s, const JoinView()),
      ),
      GoRoute(
        path: AppRoutes.history,
        pageBuilder: (_, s) => _slide(s, const HistoryView()),
      ),
      GoRoute(
        path: AppRoutes.qrPattern,
        pageBuilder: (_, s) =>
            _slide(s, QrView(tableId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.livePattern,
        pageBuilder: (_, s) =>
            _slide(s, LiveView(tableId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.cashoutPattern,
        pageBuilder: (_, s) =>
            _slide(s, CashoutView(tableId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.closePattern,
        pageBuilder: (_, s) =>
            _slide(s, CloseTableView(tableId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.checkPattern,
        pageBuilder: (_, s) =>
            _slide(s, CheckTableView(tableId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.pixPattern,
        pageBuilder: (_, s) =>
            _slide(s, PixView(tableId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.joinByIdPattern,
        pageBuilder: (_, s) =>
            _slide(s, JoinByIdView(tableId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.addPlayerPattern,
        pageBuilder: (_, s) =>
            _slide(s, AddPlayerView(tableId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.editBuyInsPattern,
        pageBuilder: (_, s) => _slide(
          s,
          EditBuyInsView(
            tableId: s.pathParameters['id']!,
            participationId: s.pathParameters['pid']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.tableDetailPattern,
        pageBuilder: (_, s) =>
            _slide(s, TableDetailView(tableId: s.pathParameters['id']!)),
      ),
    ],
  );

  /// Redireciona preservando o destino original em `?next=`. Sem isso, um
  /// link compartilhado (ex.: `/table/:id/join`) perde a intenção e o
  /// usuário cai na home depois do login.
  String? _redirect(BuildContext _, GoRouterState state) {
    final auth = _authCubit.state;
    final location = state.matchedLocation;
    final uri = state.uri;

    return switch (auth) {
      AuthUnauthenticated() || AuthError() => _toLogin(location, uri),
      AuthNeedsProfile() ||
      AuthUpdatingProfile() =>
        _toCompleteProfile(location, uri),
      AuthAuthenticated() => _afterAuth(location, uri),
      AuthAuthenticating() => null,
    };
  }

  String? _toLogin(String location, Uri uri) {
    if (location == AppRoutes.login) return null;
    final next = uri.toString();
    if (next.isEmpty || next == AppRoutes.home) {
      return AppRoutes.login;
    }
    return '${AppRoutes.login}?next=${Uri.encodeQueryComponent(next)}';
  }

  String? _toCompleteProfile(String location, Uri uri) {
    if (location == AppRoutes.completeProfile) return null;
    final next = uri.queryParameters['next'];
    if (next == null || next.isEmpty) {
      return AppRoutes.completeProfile;
    }
    return '${AppRoutes.completeProfile}?next=${Uri.encodeQueryComponent(next)}';
  }

  String? _afterAuth(String location, Uri uri) {
    if (location != AppRoutes.login && location != AppRoutes.completeProfile) {
      return null;
    }
    final next = uri.queryParameters['next'];
    if (next != null && next.isNotEmpty) {
      return next;
    }
    return AppRoutes.home;
  }
}
