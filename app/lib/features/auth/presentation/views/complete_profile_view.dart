import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:splitpot/core/router/app_routes.dart';

import '../../../../core/design/design_system.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pixController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthCubit>().state;
    _nameController.text = switch (state) {
      AuthNeedsProfile(:final suggestedName) => suggestedName,
      AuthUpdatingProfile(:final suggestedName) => suggestedName,
      _ => '',
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pixController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty ||
        _pixController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SpColors.danger,
          content: Text('Preencha nome e chave PIX.'),
        ),
      );
      return;
    }
    context.read<AuthCubit>().completeProfile(
          name: _nameController.text.trim(),
          pixKey: _pixController.text.trim(),
        );
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
                  left: SpBackButton(
                    onPressed: () => context.go(AppRoutes.login),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _OnboardingBody(
                      nameController: _nameController,
                      pixController: _pixController,
                      onSubmit: _submit,
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
    required this.nameController,
    required this.pixController,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController pixController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
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
        const SpInput(enabled: false, hintText: 'conectado pelo Google'),
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
