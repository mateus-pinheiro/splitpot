import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/app_dependencies.dart';
import 'core/di/di_container.dart';
import 'core/di/get_it_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/services/firebase_rest_auth_service.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/views/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setAppDI(GetItContainer());
  registerAppDependencies(appDI);

  // Só inicializar o plugin é rápido (setup de JS). O que era lento —
  // attemptLightweightAuthentication — agora roda unawaited no service.
  final firebase = appDI.get<FirebaseRestAuthService>();
  await firebase.initialize();

  final authCubit = appDI.get<AuthCubit>();
  unawaited(authCubit.bootstrap());

  runApp(SplitPotApp(authCubit: authCubit));
}

class SplitPotApp extends StatefulWidget {
  const SplitPotApp({required this.authCubit, super.key});

  final AuthCubit authCubit;

  @override
  State<SplitPotApp> createState() => _SplitPotAppState();
}

class _SplitPotAppState extends State<SplitPotApp> {
  late final AppRouter _router = AppRouter(authCubit: widget.authCubit);

  final GlobalKey<SplashViewState> _splashKey = GlobalKey<SplashViewState>();
  bool _splashVisible = true;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    // Minimum display time so the splash doesn't flash away instantly.
    const minDisplay = Duration(milliseconds: 1000);
    final minFuture = Future<void>.delayed(minDisplay);

    _authSub = widget.authCubit.stream
        .where((s) => s is! AuthAuthenticating)
        .take(1)
        .listen((_) async {
      await minFuture;
      if (!mounted) return;
      _splashKey.currentState?.startExit();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: widget.authCubit,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            MaterialApp.router(
              title: 'SplitPot',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              routerConfig: _router.router,
            ),
            if (_splashVisible)
              SplashView(
                key: _splashKey,
                onDismiss: () => setState(() => _splashVisible = false),
              ),
          ],
        ),
      ),
    );
  }
}
