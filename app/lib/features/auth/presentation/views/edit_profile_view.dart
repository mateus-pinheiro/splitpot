import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/cubit.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pixController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) {
      _nameController.text = state.user.name;
      _pixController.text = state.user.pixKey;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pixController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    final name = _nameController.text.trim();
    final pixKey = _pixController.text.trim();
    if (name.isEmpty || pixKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SpColors.danger,
          content: Text('Preencha nome e chave PIX.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<AuthCubit>().editProfile(name: name, pixKey: pixKey);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SpColors.success,
          content: Text('Perfil atualizado.'),
          duration: Duration(seconds: 1),
        ),
      );
      context.go(AppRoutes.home);
    } on Object catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SpColors.danger,
          content: Text('Não foi possível salvar. Tente novamente.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                  left: SpBackButton(onPressed: () => context.go(AppRoutes.home)),
                  title: 'Editar perfil',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _EditProfileBody(
                      nameController: _nameController,
                      pixController: _pixController,
                      onSubmit: _submit,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: SpGoldButton(
                    label: 'Salvar',
                    loading: _saving,
                    onPressed: _saving ? null : _submit,
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

class _EditProfileBody extends StatelessWidget {
  const _EditProfileBody({
    required this.nameController,
    required this.pixController,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController pixController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthCubit, String?>((c) {
      final s = c.state;
      return s is AuthAuthenticated ? s.user.email : null;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Seus dados',
          style: TextStyle(
            fontFamily: SpTypography.displayFamily,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: SpColors.cream,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Atualize seu nome ou chave PIX. Suas alterações aparecem nas próximas mesas.',
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
          initialValue: email,
          hintText: 'conectado pelo Google',
        ),
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
