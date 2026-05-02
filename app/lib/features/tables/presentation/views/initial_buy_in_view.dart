import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/poker_table.dart';
import '../cubit/initial_buy_in_cubit.dart';

/// Tela do owner para declarar o aporte inicial logo após criar a mesa,
/// quando ele marcou que vai jogar.
class InitialBuyInView extends StatelessWidget {
  const InitialBuyInView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthCubit>().state;
    final currentUserId = auth is AuthAuthenticated ? auth.user.id : '';
    return BlocProvider<InitialBuyInCubit>(
      create: (_) => appDI.get<InitialBuyInCubit>()
        ..load(tableId: tableId, currentUserId: currentUserId),
      child: _InitialBuyInScaffold(tableId: tableId),
    );
  }
}

class _InitialBuyInScaffold extends StatelessWidget {
  const _InitialBuyInScaffold({required this.tableId});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: BlocConsumer<InitialBuyInCubit, InitialBuyInState>(
            listener: (context, state) {
              if (state is InitialBuyInSubmitted) {
                context.go(AppRoutes.qr(tableId));
              } else if (state is InitialBuyInSubmitError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: SpColors.danger,
                    content: Text(_messageFor(state.failure)),
                  ),
                );
              }
            },
            builder: (context, state) {
              final table = switch (state) {
                InitialBuyInReady(:final table) => table,
                InitialBuyInSubmitting(:final table) => table,
                InitialBuyInSubmitError(:final table) => table,
                InitialBuyInSubmitted(:final table) => table,
                _ => null,
              };
              final backRoute = table != null
                  ? Uri(
                      path: AppRoutes.createTable,
                      queryParameters: {
                        'name': table.name,
                        'minBuyIn': table.minBuyIn.toString(),
                        'tableId': tableId,
                        'returnTo': 'initialBuyIn',
                      },
                    ).toString()
                  : AppRoutes.home;
              return Column(
                children: [
                  SpAppHeader(
                    left: SpBackButton(
                      onPressed: () => context.go(backRoute),
                    ),
                    title: 'Seu aporte inicial',
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
          message ?? 'Sem permissão para registrar o aporte.',
        NotFoundFailure(:final message) =>
          message ?? 'Participação não encontrada.',
        NetworkFailure() => 'Sem conexão com o servidor.',
        UnexpectedFailure(:final message) =>
          message ?? 'Não foi possível salvar o aporte.',
        SignInCancelledFailure() => 'Ação cancelada.',
      };
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.tableId});
  final InitialBuyInState state;
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      InitialBuyInLoading() => const _Loading(),
      InitialBuyInError(:final failure) =>
        _ErrorView(failure: failure, tableId: tableId),
      InitialBuyInReady(:final table) =>
        _Form(table: table, submitting: false, tableId: tableId),
      InitialBuyInSubmitting(:final table) =>
        _Form(table: table, submitting: true, tableId: tableId),
      InitialBuyInSubmitError(:final table) =>
        _Form(table: table, submitting: false, tableId: tableId),
      InitialBuyInSubmitted(:final table) =>
        _Form(table: table, submitting: true, tableId: tableId),
    };
  }
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
  const _ErrorView({required this.failure, required this.tableId});
  final Failure failure;
  final String tableId;

  @override
  Widget build(BuildContext context) {
    final message = switch (failure) {
      NotFoundFailure(:final message) =>
        message ?? 'Participação não encontrada.',
      _ => 'Não foi possível carregar a mesa.',
    };
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 18),
          SpGoldButton(
            label: 'Ir para o QR',
            onPressed: () => context.go(AppRoutes.qr(tableId)),
            expand: false,
          ),
        ],
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({
    required this.table,
    required this.submitting,
    required this.tableId,
  });
  final PokerTable table;
  final bool submitting;
  final String tableId;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.table.minBuyIn.toBigInt().toString(),
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
    if (amount < widget.table.minBuyIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SpColors.danger,
          content: Text('Buy-in mínimo é R\$ ${widget.table.minBuyIn}.'),
        ),
      );
      return;
    }
    context.read<InitialBuyInCubit>().submit(amount);
  }

  @override
  Widget build(BuildContext context) {
    final amount = _amount;
    final buttonLabel = amount != null
        ? 'Confirmar · R\$ ${_format(amount)}'
        : 'Confirmar aporte';
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
            children: [
              _MesaCard(table: widget.table),
              const SizedBox(height: 22),
              const Text(
                'Você marcou que vai jogar. Quanto está colocando na mesa pra começar?',
                style: TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 13,
                  color: SpColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              _AmountInput(controller: _controller),
              const SizedBox(height: 6),
              Text(
                'Mínimo R\$ ${widget.table.minBuyIn}.',
                style: const TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 12,
                  color: SpColors.muted,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
          child: SpGoldButton(
            label: buttonLabel,
            loading: widget.submitting,
            onPressed: widget.submitting ? null : _submit,
          ),
        ),
      ],
    );
  }

  static String _format(Decimal d) {
    if (d.toBigInt().toString() == d.toString()) return d.toBigInt().toString();
    return d.toString();
  }
}

class _MesaCard extends StatelessWidget {
  const _MesaCard({required this.table});
  final PokerTable table;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MESA RECÉM-CRIADA',
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: SpColors.gold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            table.name,
            style: const TextStyle(
              fontFamily: SpTypography.displayFamily,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: SpColors.cream,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Buy-in mínimo R\$ ${table.minBuyIn}',
            style: const TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 12,
              color: SpColors.muted,
            ),
          ),
        ],
      ),
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
