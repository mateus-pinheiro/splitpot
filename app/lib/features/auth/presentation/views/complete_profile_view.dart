import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:splitpot/core/router/app_routes.dart';

import '../../../../core/design/design_system.dart';
import '../../domain/entities/auth_provider.dart';
import '../cubit/cubit.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pixController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthCubit>().state;
    _nameController.text = switch (state) {
      AuthNeedsProfile(:final suggestedName) => suggestedName,
      AuthUpdatingProfile(:final suggestedName) => suggestedName,
      _ => '',
    };
    // No fluxo password, a senha digitada no login vem aqui pré-preenchida
    // (campo continua editável — usuário confirma/ajusta antes de cadastrar).
    if (state is AuthNeedsProfile && state.draftPassword != null) {
      _passwordController.text = state.draftPassword!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pixController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  AuthProvider _providerFromState(AuthState state) => switch (state) {
        AuthNeedsProfile(:final provider) => provider,
        AuthUpdatingProfile(:final provider) => provider,
        _ => AuthProvider.google,
      };

  String? _draftEmail(AuthState state) =>
      state is AuthNeedsProfile ? state.draftEmail : null;

  void _submit() {
    final cubit = context.read<AuthCubit>();
    final provider = _providerFromState(cubit.state);

    final name = _nameController.text.trim();
    final pixKey = _pixController.text.trim();
    if (name.isEmpty || pixKey.isEmpty) {
      _toast('Preencha nome e chave PIX.');
      return;
    }
    if (provider == AuthProvider.password) {
      final password = _passwordController.text;
      if (password.length < 6) {
        _toast('A senha precisa ter pelo menos 6 caracteres.');
        return;
      }
      cubit.signUpAndCompleteProfile(name: name, pixKey: pixKey);
    } else {
      cubit.completeProfile(name: name, pixKey: pixKey);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SpColors.danger,
        content: Text(message),
      ),
    );
  }

  void _back() {
    context.read<AuthCubit>().cancelPendingSignup();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SpAppHeader(
                  left: SpBackButton(onPressed: _back),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (p, c) =>
                          _providerFromState(p) != _providerFromState(c) ||
                          _draftEmail(p) != _draftEmail(c),
                      builder: (context, state) {
                        return _OnboardingBody(
                          provider: _providerFromState(state),
                          email: _draftEmail(state),
                          nameController: _nameController,
                          pixController: _pixController,
                          passwordController: _passwordController,
                          obscure: _obscure,
                          onToggleObscure: () =>
                              setState(() => _obscure = !_obscure),
                          onSubmit: _submit,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthUpdatingProfile;
                      return SpGoldButton(
                        label: 'Entrar no Splitpot',
                        loading: loading,
                        onPressed: loading ? null : _submit,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingBody extends StatelessWidget {
  const _OnboardingBody({
    required this.provider,
    required this.email,
    required this.nameController,
    required this.pixController,
    required this.passwordController,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final AuthProvider provider;
  final String? email;
  final TextEditingController nameController;
  final TextEditingController pixController;
  final TextEditingController passwordController;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  String get _emailHint => switch (provider) {
        AuthProvider.google => 'conectado pelo Google',
        AuthProvider.apple => 'conectado pelo Apple',
        AuthProvider.password => email ?? '',
      };

  @override
  Widget build(BuildContext context) {
    final isPasswordFlow = provider == AuthProvider.password;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Complete seu\nperfil',
          style: TextStyle(
            fontFamily: SpTypography.displayFamily,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: SpColors.cream,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Essas informações aparecem quando você entra em uma mesa.',
          style: TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 14,
            color: SpColors.muted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        const SpFieldLabel('Nome'),
        const SizedBox(height: 8),
        SpInput(controller: nameController),
        const SizedBox(height: 18),
        const SpFieldLabel('Email'),
        const SizedBox(height: 8),
        SpInput(
          enabled: false,
          initialValue: isPasswordFlow ? email : null,
          hintText: _emailHint,
        ),
        if (isPasswordFlow) ...[
          const SizedBox(height: 18),
          const SpFieldLabel('Senha'),
          const SizedBox(height: 8),
          SpInput(
            controller: passwordController,
            obscureText: obscure,
            hintText: 'mínimo 6 caracteres',
            autofillHints: const [AutofillHints.newPassword],
            suffix: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: SpColors.muted,
                size: 20,
              ),
              splashRadius: 18,
              tooltip: obscure ? 'Mostrar senha' : 'Ocultar senha',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Você vai usar essa senha pra entrar no SplitPot da próxima vez.',
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 12,
              color: SpColors.muted,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 18),
        const SpFieldLabel('Chave PIX'),
        const SizedBox(height: 8),
        SpInput(
          controller: pixController,
          hintText: 'CPF, telefone, email ou aleatória',
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 6),
        const Text(
          'Usada apenas para receber acertos ao fim da mesa.',
          style: TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 12,
            color: SpColors.muted,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
