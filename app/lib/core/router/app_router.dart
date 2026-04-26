import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/views/complete_profile_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/home/presentation/views/home_view.dart';
import '../../features/tables/presentation/views/cashout_view.dart';
import '../../features/tables/presentation/views/close_table_view.dart';
import '../../features/tables/presentation/views/create_table_view.dart';
import '../../features/tables/presentation/views/history_view.dart';
import '../../features/tables/presentation/views/initial_buy_in_view.dart';
import '../../features/tables/presentation/views/join_by_id_view.dart';
import '../../features/tables/presentation/views/join_view.dart';
import '../../features/tables/presentation/views/live_view.dart';
import '../../features/tables/presentation/views/pix_view.dart';
import '../../features/tables/presentation/views/qr_view.dart';
import '../../features/tables/presentation/views/table_detail_view.dart';
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
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginView()),
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (_, _) => const CompleteProfileView(),
      ),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeView()),
      GoRoute(
        path: AppRoutes.createTable,
        builder: (_, _) => const CreateTableView(),
      ),
      GoRoute(path: AppRoutes.joinTable, builder: (_, _) => const JoinView()),
      GoRoute(path: AppRoutes.history, builder: (_, _) => const HistoryView()),
      GoRoute(
        path: AppRoutes.qrPattern,
        builder: (_, s) => QrView(tableId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.initialBuyInPattern,
        builder: (_, s) =>
            InitialBuyInView(tableId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.livePattern,
        builder: (_, s) => LiveView(tableId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.cashoutPattern,
        builder: (_, s) => CashoutView(tableId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.closePattern,
        builder: (_, s) => CloseTableView(tableId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.pixPattern,
        builder: (_, s) => PixView(tableId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.joinByIdPattern,
        builder: (_, s) => JoinByIdView(tableId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.tableDetailPattern,
        builder: (_, s) => TableDetailView(tableId: s.pathParameters['id']!),
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
