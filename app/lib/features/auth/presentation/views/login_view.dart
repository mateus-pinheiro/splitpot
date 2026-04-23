import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/di_container.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => appDI.get<AuthCubit>(),
      child: const _LoginScaffold(),
    );
  }
}

class _LoginScaffold extends StatelessWidget {
  const _LoginScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: _handleStateChange,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Branding(),
                    SizedBox(height: 48),
                    _GoogleSignInButton(),
                    SizedBox(height: 16),
                    _Disclaimer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleStateChange(BuildContext context, AuthState state) {
    switch (state) {
      case AuthAuthenticated():
        context.go(AppRoutes.home);
      case AuthNeedsProfile():
        context.go(AppRoutes.completeProfile);
      case AuthError():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível entrar. Tente novamente.'),
          ),
        );
      case AuthUnauthenticated():
      case AuthAuthenticating():
        break;
    }
  }
}

class _Branding extends StatelessWidget {
  const _Branding();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.casino_outlined,
            size: 40,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'SplitPot',
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Acerte o caixa da mesa sem dor de cabeça.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthAuthenticating;
        return FilledButton.icon(
          onPressed: isLoading
              ? null
              : () => context.read<AuthCubit>().signInWithGoogle(),
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.login),
          label: Text(isLoading ? 'Entrando...' : 'Entrar com Google'),
        );
      },
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Modo desenvolvimento — login mockado.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }
}
