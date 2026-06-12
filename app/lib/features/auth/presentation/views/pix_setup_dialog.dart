import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/errors/failure.dart';
import '../cubit/cubit.dart';

/// Dialog bloqueante exibido após login social (Apple/Google) quando o perfil
/// ainda não foi provisionado no backend.
///
/// Pede APENAS a chave PIX — nome e email já vêm do provedor de identidade.
/// A Apple (Guideline 4) proíbe pedir nome/email depois do Sign in with Apple,
/// então não há esses campos aqui. O dialog não fecha sem preencher o PIX
/// (`barrierDismissible: false` + `PopScope`); o único escape é "Sair", que
/// desloga.
///
/// [suggestedName] é o nome capturado do provedor no momento da abertura — é
/// passado explicitamente (e não relido do estado) para sobreviver a um
/// eventual `AuthError`/retry, que troca o estado e perderia o nome original.
Future<void> showPixSetupDialog(
  BuildContext context, {
  required String suggestedName,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => _PixSetupDialog(suggestedName: suggestedName),
  );
}

class _PixSetupDialog extends StatefulWidget {
  const _PixSetupDialog({required this.suggestedName});

  final String suggestedName;

  @override
  State<_PixSetupDialog> createState() => _PixSetupDialogState();
}

class _PixSetupDialogState extends State<_PixSetupDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Rebuild a cada tecla para habilitar/desabilitar o botão "Salvar".
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _pix => _controller.text.trim();
  bool get _canSubmit => _pix.isNotEmpty;

  void _submit() {
    if (!_canSubmit) return;
    final name = widget.suggestedName.trim().isEmpty
        ? 'Jogador'
        : widget.suggestedName.trim();
    context.read<AuthCubit>().completeProfile(name: name, pixKey: _pix);
  }

  void _signOut() {
    context.read<AuthCubit>().signOut();
    Navigator.of(context).pop();
  }

  String _messageFor(Failure failure) => switch (failure) {
        NetworkFailure() => 'Sem conexão com o servidor.',
        ValidationFailure(:final message) => message,
        UnauthorizedFailure(:final message) =>
          message ?? 'Não foi possível salvar. Entre novamente.',
        _ => 'Não foi possível salvar. Tente novamente.',
      };

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pop();
        } else if (state is AuthError) {
          showSpToast(context, _messageFor(state.failure),
              type: SpToastType.error);
        }
      },
      child: PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: SpColors.feltDeep,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: SpColors.gold.withValues(alpha: 0.3)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
              child: BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (p, c) =>
                    (p is AuthUpdatingProfile) != (c is AuthUpdatingProfile),
                builder: (context, state) {
                  final loading = state is AuthUpdatingProfile;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Falta sua chave PIX',
                        style: TextStyle(
                          fontFamily: SpTypography.displayFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: SpColors.cream,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Quase lá! Informe a chave que você usa pra receber os '
                        'acertos ao fim da mesa.',
                        style: TextStyle(
                          fontFamily: SpTypography.uiFamily,
                          fontSize: 13,
                          color: SpColors.muted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SpFieldLabel('Chave PIX'),
                      const SizedBox(height: 8),
                      SpInput(
                        controller: _controller,
                        hintText: 'CPF, telefone, email ou aleatória',
                        enabled: !loading,
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 18),
                      SpGoldButton(
                        label: 'Salvar e entrar',
                        loading: loading,
                        onPressed: (_canSubmit && !loading) ? _submit : null,
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: TextButton(
                          onPressed: loading ? null : _signOut,
                          child: Text(
                            'Sair',
                            style: TextStyle(
                              fontFamily: SpTypography.uiFamily,
                              fontSize: 13,
                              color: SpColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
