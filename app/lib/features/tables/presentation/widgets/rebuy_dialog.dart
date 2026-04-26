import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../cubit/rebuy_cubit.dart';

/// Abre o dialog de aporte. `mode = rebuy` mostra "Adicionar rebuy";
/// `mode = rejoin` mostra "Entrar novamente" e usa o endpoint atômico
/// que limpa o cash-out e cria o novo buy-in.
///
/// Resolve em `true` quando o aporte for confirmado com sucesso —
/// o caller usa esse sinal pra refrescar a UI.
Future<bool> showRebuyDialog(
  BuildContext context, {
  required String participationId,
  required Decimal minBuyIn,
  RebuyMode mode = RebuyMode.rebuy,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => BlocProvider<RebuyCubit>(
      create: (_) => appDI.get<RebuyCubit>(),
      child: _RebuyDialog(
        participationId: participationId,
        minBuyIn: minBuyIn,
        mode: mode,
      ),
    ),
  );
  return result ?? false;
}

class _RebuyDialog extends StatefulWidget {
  const _RebuyDialog({
    required this.participationId,
    required this.minBuyIn,
    required this.mode,
  });

  final String participationId;
  final Decimal minBuyIn;
  final RebuyMode mode;

  @override
  State<_RebuyDialog> createState() => _RebuyDialogState();
}

class _RebuyDialogState extends State<_RebuyDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.minBuyIn.toBigInt().toString(),
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Decimal? get _amount {
    final raw = _controller.text.replaceAll(',', '.').trim();
    if (raw.isEmpty) return null;
    return Decimal.tryParse(raw);
  }

  void _submit() {
    final amount = _amount;
    if (amount == null || amount <= Decimal.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SpColors.danger,
          content: Text('Informe um valor maior que zero.'),
        ),
      );
      return;
    }
    context.read<RebuyCubit>().submit(
          participationId: widget.participationId,
          amount: amount,
          mode: widget.mode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final copy = _Copy.forMode(widget.mode);
    return BlocListener<RebuyCubit, RebuyState>(
      listener: (context, state) {
        if (state is RebuySuccess) {
          Navigator.of(context).pop(true);
        } else if (state is RebuyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: SpColors.danger,
              content: Text(_messageFor(state.failure, copy)),
            ),
          );
          context.read<RebuyCubit>().reset();
        }
      },
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
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: BlocBuilder<RebuyCubit, RebuyState>(
              builder: (context, state) {
                final submitting = state is RebuySubmitting;
                final amount = _amount;
                final buttonLabel = amount != null
                    ? '${copy.confirmLabel} · R\$ ${_format(amount)}'
                    : copy.confirmLabel;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      eyebrow: copy.eyebrow,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      copy.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: SpTypography.displayFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: SpColors.cream,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      copy.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 12,
                        color: SpColors.muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AmountInput(controller: _controller),
                    const SizedBox(height: 16),
                    SpGoldButton(
                      label: buttonLabel,
                      loading: submitting,
                      onPressed: submitting ? null : _submit,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static String _format(Decimal d) {
    if (d.toBigInt().toString() == d.toString()) return d.toBigInt().toString();
    return d.toString();
  }

  static String _messageFor(Failure failure, _Copy copy) => switch (failure) {
        ValidationFailure(:final message) => message,
        UnauthorizedFailure(:final message) =>
          message ?? 'Sem permissão para alterar essa participação.',
        NotFoundFailure() => 'Participação não encontrada.',
        NetworkFailure() => 'Sem conexão com o servidor.',
        UnexpectedFailure(:final message) => message ?? copy.errorFallback,
        SignInCancelledFailure() => 'Ação cancelada.',
      };
}

class _Copy {
  const _Copy({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.errorFallback,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String confirmLabel;
  final String errorFallback;

  static _Copy forMode(RebuyMode mode) {
    switch (mode) {
      case RebuyMode.rebuy:
        return const _Copy(
          eyebrow: 'NOVO APORTE',
          title: 'Adicionar rebuy',
          subtitle: 'Quanto você está colocando agora na mesa?',
          confirmLabel: 'Confirmar rebuy',
          errorFallback: 'Não foi possível registrar o rebuy.',
        );
      case RebuyMode.rejoin:
        return const _Copy(
          eyebrow: 'VOLTAR PRA MESA',
          title: 'Entrar novamente',
          subtitle: 'Com quanto você está voltando para o jogo?',
          confirmLabel: 'Confirmar entrada',
          errorFallback: 'Não foi possível voltar pra mesa.',
        );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.eyebrow, required this.onClose});
  final String eyebrow;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: SpColors.gold,
            letterSpacing: 1.5,
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close, size: 20),
          color: SpColors.cream,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.6),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Text(
            'R\$',
            style: TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: SpColors.muted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              cursorColor: SpColors.goldBright,
              style: const TextStyle(
                fontFamily: SpTypography.numFamily,
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: SpColors.cream,
                height: 1.0,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
