import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/design/tokens.dart';
import 'core/design/widgets/sp_loader.dart';
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
  usePathUrlStrategy();
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
            if (!_splashVisible)
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final authenticating = state is AuthAuthenticating;
                  return AnimatedOpacity(
                    opacity: authenticating ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeIn,
                    child: IgnorePointer(
                      ignoring: !authenticating,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(0, -1.2),
                            radius: 1.3,
                            colors: [
                              SpColors.feltLight,
                              SpColors.felt,
                              SpColors.feltDeep,
                            ],
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                        child: SizedBox.expand(
                          child: Center(child: SpLoader()),
                        ),
                      ),
                    ),
                  );
                },
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
