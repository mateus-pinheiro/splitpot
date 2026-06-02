import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/cubit/cubit.dart';
import '../../domain/entities/entities.dart';
import '../cubit/cashout_cubit.dart';

class CashoutView extends StatelessWidget {
  const CashoutView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthCubit>().state;
    final currentUserId = auth is AuthAuthenticated ? auth.user.id : '';
    return BlocProvider<CashoutCubit>(
      create: (_) => appDI.get<CashoutCubit>()
        ..load(tableId: tableId, currentUserId: currentUserId),
      child: _CashoutScaffold(tableId: tableId),
    );
  }
}

class _CashoutScaffold extends StatelessWidget {
  const _CashoutScaffold({required this.tableId});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: BlocConsumer<CashoutCubit, CashoutState>(
            listener: (context, state) {
              if (state is CashoutSubmitted) {
                context.go(AppRoutes.home);
              } else if (state is CashoutAwaitingApproval) {
                context.go(AppRoutes.live(tableId));
              } else if (state is CashoutSubmitError) {
                showSpToast(context, _messageFor(state.failure),
                    type: SpToastType.error);
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  SpAppHeader(
                    left: SpBackButton(
                      onPressed: () => context.go(AppRoutes.live(tableId)),
                    ),
                    title: 'Sair da mesa',
                  ),
                  Expanded(child: _Body(state: state, tableId: tableId)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static String _messageFor(Failure failure) => switch (failure) {
        ValidationFailure(:final message) => message,
        UnauthorizedFailure(:final message) =>
          message ?? 'Sem permissão para alterar esta participação.',
        NotFoundFailure(:final message) =>
          message ?? 'Participação não encontrada.',
        NetworkFailure() => 'Sem conexão com o servidor.',
        UnexpectedFailure(:final message) =>
          message ?? 'Não foi possível registrar a saída.',
        SignInCancelledFailure() => 'Ação cancelada.',
      };
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.tableId});
  final CashoutState state;
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      CashoutLoading() => const _Loading(),
      CashoutError(:final failure) =>
        _ErrorView(message: _errorMessage(failure)),
      CashoutReady(:final participation) =>
        _Form(participation: participation, submitting: false),
      CashoutSubmitting(:final participation) =>
        _Form(participation: participation, submitting: true),
      CashoutSubmitError(:final participation) =>
        _Form(participation: participation, submitting: false),
      CashoutSubmitted() => const _Loading(),
      CashoutAwaitingApproval() => const _Loading(),
    };
  }

  static String _errorMessage(Failure failure) => switch (failure) {
        NotFoundFailure(:final message) =>
          message ?? 'Participação não encontrada.',
        UnauthorizedFailure(:final message) =>
          message ?? 'Sem acesso a esta mesa.',
        NetworkFailure() => 'Sem conexão com o servidor.',
        _ => 'Não foi possível carregar a mesa.',
      };
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: SpColors.goldBright,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: SpColors.dangerSoft, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 14,
                color: SpColors.cream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({required this.participation, required this.submitting});
  final TableParticipation participation;
  final bool submitting;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Campo sempre começa vazio — pré-preencher induz a confirmar sem revisar.
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Decimal? get _stack {
    final raw = _controller.text.replaceAll(',', '.').trim();
    if (raw.isEmpty) return null;
    return Decimal.tryParse(raw);
  }

  void _submit() {
    final stack = _stack;
    if (stack == null || stack < Decimal.zero) {
      showSpToast(context, 'Informe um valor válido (zero ou mais).',
          type: SpToastType.error);
      return;
    }
    context.read<CashoutCubit>().submit(stack);
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary(widget.participation);
    final stack = _stack ?? Decimal.zero;
    final pl = stack - summary.invested;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            children: [
              const Text(
                'Com quanto você\nestá saindo?',
                style: TextStyle(
                  fontFamily: SpTypography.displayFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: SpColors.cream,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Conte suas fichas e informe o valor final. Se estiver zerado, informe R\$ 0.',
                style: TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 13,
                  color: SpColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              _InvestedSummary(summary: summary),
              const SizedBox(height: 20),
              const SpFieldLabel('Valor em fichas ao sair'),
              const SizedBox(height: 10),
              _StackInput(controller: _controller),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _QuickPill(
                      label: 'Zerado',
                      dangerous: true,
                      onTap: () => _controller.text = '0',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickPill(
                      label: 'Empate',
                      dangerous: false,
                      onTap: () =>
                          _controller.text = summary.invested.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _PnlPreview(pl: pl),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
          child: SpGoldButton(
            label: 'Confirmar saída',
            loading: widget.submitting,
            onPressed: widget.submitting || _stack == null ? null : _submit,
          ),
        ),
      ],
    );
  }

  static _ParticipationSummary _summary(TableParticipation p) {
    final sorted = [...p.buyIns]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final initial = sorted.isEmpty ? Decimal.zero : sorted.first.amount;
    final rebuys = sorted.length <= 1
        ? const <BuyIn>[]
        : sorted.sublist(1);
    final rebuysSum = rebuys.fold<Decimal>(
      Decimal.zero,
      (acc, b) => acc + b.amount,
    );
    return _ParticipationSummary(
      initial: initial,
      rebuysCount: rebuys.length,
      rebuysSum: rebuysSum,
      invested: initial + rebuysSum,
    );
  }
}

class _ParticipationSummary {
  const _ParticipationSummary({
    required this.initial,
    required this.rebuysCount,
    required this.rebuysSum,
    required this.invested,
  });
  final Decimal initial;
  final int rebuysCount;
  final Decimal rebuysSum;
  final Decimal invested;
}

class _InvestedSummary extends StatelessWidget {
  const _InvestedSummary({required this.summary});
  final _ParticipationSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _Row(
            label: 'Aporte inicial',
            value: brlFromDecimal(summary.initial),
            subtle: true,
          ),
          const SizedBox(height: 8),
          _Row(
            label: 'Rebuys (${summary.rebuysCount})',
            value: brlFromDecimal(summary.rebuysSum),
            subtle: true,
          ),
          const SizedBox(height: 12),
          const GoldDivider(),
          const SizedBox(height: 12),
          _Row(
            label: 'Total investido',
            value: brlFromDecimal(summary.invested),
            valueStyle: const TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SpColors.goldBright,
            ),
            labelStyle: const TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: SpColors.cream,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.subtle = false,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final bool subtle;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ??
              TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 12,
                color: subtle ? SpColors.muted : SpColors.cream,
              ),
        ),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontFamily: SpTypography.numFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: SpColors.cream,
              ),
        ),
      ],
    );
  }
}

class _StackInput extends StatelessWidget {
  const _StackInput({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              cursorColor: SpColors.goldBright,
              style: const TextStyle(
                fontFamily: SpTypography.numFamily,
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: SpColors.cream,
                height: 1.0,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '0',
                hintStyle: TextStyle(
                  fontFamily: SpTypography.numFamily,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: SpColors.cream.withValues(alpha: 0.25),
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPill extends StatelessWidget {
  const _QuickPill({
    required this.label,
    required this.dangerous,
    required this.onTap,
  });
  final String label;
  final bool dangerous;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = dangerous ? SpColors.dangerSoft : SpColors.cream;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dangerous
                ? SpColors.danger.withValues(alpha: 0.12)
                : SpColors.cream.withValues(alpha: 0.08),
            border: Border.all(
              color: dangerous
                  ? SpColors.danger.withValues(alpha: 0.3)
                  : SpColors.cream.withValues(alpha: 0.15),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _PnlPreview extends StatelessWidget {
  const _PnlPreview({required this.pl});
  final Decimal pl;

  @override
  Widget build(BuildContext context) {
    final positive = pl >= Decimal.zero;
    final bg = positive
        ? SpColors.success.withValues(alpha: 0.1)
        : SpColors.danger.withValues(alpha: 0.1);
    final border = positive
        ? SpColors.success.withValues(alpha: 0.3)
        : SpColors.danger.withValues(alpha: 0.3);
    final label = pl == Decimal.zero
        ? 'Empate zero'
        : positive
            ? 'Você vai receber'
            : 'Você vai pagar';
    final prefix = pl > Decimal.zero ? '+' : '';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RESULTADO',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: SpColors.goldDark,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 13,
                    color: SpColors.cream,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$prefix${brlFromDecimal(pl)}',
            style: TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: positive ? SpColors.successSoft : SpColors.dangerSoft,
            ),
          ),
        ],
      ),
    );
  }
}
