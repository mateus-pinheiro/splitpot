import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/entities.dart';
import '../cubit/edit_buy_ins_cubit.dart';

/// Tela onde o host edita ou remove buy-ins de um jogador específico.
/// Acessada pelo menu "Editar entradas" no `_PlayerHostMenu`.
class EditBuyInsView extends StatelessWidget {
  const EditBuyInsView({
    required this.tableId,
    required this.participationId,
    super.key,
  });

  final String tableId;
  final String participationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditBuyInsCubit>(
      create: (_) =>
          appDI.get<EditBuyInsCubit>()..load(tableId, participationId),
      child: _EditBuyInsScaffold(tableId: tableId),
    );
  }
}

class _EditBuyInsScaffold extends StatelessWidget {
  const _EditBuyInsScaffold({required this.tableId});
  final String tableId;

  String _messageFor(Failure failure) => switch (failure) {
        ValidationFailure(:final message) => message,
        UnauthorizedFailure(:final message) =>
          message ?? 'Sua sessão expirou. Entre novamente.',
        NotFoundFailure(:final message) =>
          message ?? 'Participação não encontrada.',
        NetworkFailure() => 'Sem conexão com o servidor.',
        UnexpectedFailure(:final message) =>
          message ?? 'Não foi possível editar a entrada.',
        SignInCancelledFailure() => 'Ação cancelada.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: BlocConsumer<EditBuyInsCubit, EditBuyInsState>(
            listener: (context, state) {
              if (state is EditBuyInsError) {
                showSpToast(context, _messageFor(state.failure),
                    type: SpToastType.error);
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  SpAppHeader(
                    left: SpBackButton(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go(AppRoutes.live(tableId)),
                    ),
                    title: state is EditBuyInsLoaded
                        ? 'Entradas de ${state.participation.userName}'
                        : 'Editar entradas',
                  ),
                  Expanded(
                    child: switch (state) {
                      EditBuyInsLoading() => const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: SpColors.goldBright,
                            ),
                          ),
                        ),
                      EditBuyInsLoaded(:final participation) =>
                        _BuyInsList(participation: participation),
                      EditBuyInsError(:final failure) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _messageFor(failure),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: SpTypography.uiFamily,
                                fontSize: 14,
                                color: SpColors.cream,
                              ),
                            ),
                          ),
                        ),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BuyInsList extends StatelessWidget {
  const _BuyInsList({required this.participation});

  final TableParticipation participation;

  @override
  Widget build(BuildContext context) {
    final sorted = [...participation.buyIns]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (sorted.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Esse jogador ainda não tem nenhuma entrada.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              color: SpColors.muted,
            ),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final b = sorted[i];
        final isInitial = i == 0;
        return _BuyInRow(buyIn: b, indexLabel: isInitial ? 'Buy-in inicial' : 'Rebuy #$i');
      },
    );
  }
}

class _BuyInRow extends StatelessWidget {
  const _BuyInRow({required this.buyIn, required this.indexLabel});

  final BuyIn buyIn;
  final String indexLabel;

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<EditBuyInsCubit>();
    final newAmount = await showDialog<Decimal>(
      context: context,
      builder: (_) => _AmountDialog(
        title: 'Editar valor',
        initial: buyIn.amount,
      ),
    );
    if (newAmount == null) return;
    await cubit.updateAmount(buyIn.id, newAmount);
  }

  Future<void> _remove(BuildContext context) async {
    final cubit = context.read<EditBuyInsCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SpColors.feltDeep,
        title: const Text(
          'Remover entrada?',
          style: TextStyle(
            fontFamily: SpTypography.uiFamily,
            color: SpColors.cream,
          ),
        ),
        content: Text(
          'Vai apagar essa entrada de ${brlFromDecimal(buyIn.amount)}. Essa ação não pode ser desfeita.',
          style: const TextStyle(
            fontFamily: SpTypography.uiFamily,
            color: SpColors.muted,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: SpColors.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Remover',
              style: TextStyle(color: SpColors.dangerSoft),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await cubit.remove(buyIn.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.06)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  indexLabel,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 11,
                    color: SpColors.muted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  brlFromDecimal(buyIn.amount),
                  style: const TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SpColors.cream,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _edit(context),
            icon: const Icon(Icons.edit_outlined, color: SpColors.goldBright),
            tooltip: 'Editar valor',
          ),
          IconButton(
            onPressed: () => _remove(context),
            icon: const Icon(Icons.delete_outline, color: SpColors.dangerSoft),
            tooltip: 'Remover',
          ),
        ],
      ),
    );
  }
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({required this.title, required this.initial});

  final String title;
  final Decimal initial;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial.toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final raw = _ctrl.text.replaceAll(',', '.').trim();
    final amount = Decimal.tryParse(raw);
    if (amount == null || amount <= Decimal.zero) {
      showSpToast(context, 'Valor inválido', type: SpToastType.error);
      return;
    }
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SpColors.feltDeep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: SpColors.gold.withValues(alpha: 0.3)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: SpTypography.displayFamily,
                  fontSize: 18,
                  color: SpColors.goldBright,
                ),
              ),
              const SizedBox(height: 16),
              SpInput(
                controller: _ctrl,
                hintText: 'Ex.: 100,00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SpGhostButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SpGoldButton(
                      label: 'Salvar',
                      onPressed: _confirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
