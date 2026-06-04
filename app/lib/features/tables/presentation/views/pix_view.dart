import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/cubit/cubit.dart';
import '../../domain/entities/settlement.dart';
import '../cubit/pix_cubit.dart';

class PixView extends StatelessWidget {
  const PixView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PixCubit>(
      create: (_) => appDI.get<PixCubit>()..load(tableId),
      child: _PixScaffold(tableId: tableId),
    );
  }
}

class _PixScaffold extends StatelessWidget {
  const _PixScaffold({required this.tableId});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Column(
            children: [
              SpAppHeader(
                left: SpBackButton(
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.home),
                ),
                title: 'Acertos PIX',
              ),
              Expanded(
                child: BlocBuilder<PixCubit, PixState>(
                  builder: (context, state) => switch (state) {
                    PixLoading() => const _Loading(),
                    PixError(:final failure) => _ErrorView(failure: failure),
                    PixLoaded() => _Content(state: state),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
  const _ErrorView({required this.failure});
  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final message = switch (failure) {
      UnauthorizedFailure(:final message) =>
        message ?? 'Sem permissão para esta mesa.',
      NotFoundFailure() => 'Mesa não encontrada.',
      NetworkFailure() => 'Sem conexão com o servidor.',
      _ => 'Não foi possível carregar os pagamentos.',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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

class _Content extends StatelessWidget {
  const _Content({required this.state});
  final PixLoaded state;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final currentUserId = auth is AuthAuthenticated ? auth.user.id : null;

    final all = state.settlements;
    final done =
        all.where((s) => s.status == SettlementStatus.confirmed).length;
    final confirmedAmount = all
        .where((s) => s.status == SettlementStatus.confirmed)
        .fold<Decimal>(Decimal.zero, (acc, s) => acc + s.amount);
    final hasPending =
        all.any((s) => s.status == SettlementStatus.pending);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            children: [
              _ProgressCard(
                doneCount: done,
                total: all.length,
                confirmedAmount: confirmedAmount,
              ),
              if (hasPending) ...[
                const SizedBox(height: 12),
                _ShareSummaryButton(
                  tableName: state.tableName,
                  settlements: all,
                ),
              ],
              const SizedBox(height: 18),
              if (all.isEmpty)
                const _EmptyState()
              else
                for (final s in all)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PixRow(
                      settlement: s,
                      isReceiver: currentUserId == s.toUserId,
                      submitting: state.submittingId == s.id,
                    ),
                  ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: SpGoldButton(
            label: 'Voltar para a home',
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.home),
          ),
        ),
      ],
    );
  }
}

class _ShareSummaryButton extends StatelessWidget {
  const _ShareSummaryButton({
    required this.tableName,
    required this.settlements,
  });
  final String? tableName;
  final List<Settlement> settlements;

  /// Monta o texto compartilhável com os pagamentos ainda pendentes.
  String _buildSummary() {
    final name = (tableName == null || tableName!.trim().isEmpty)
        ? 'mesa'
        : tableName!.trim();
    final pending =
        settlements.where((s) => s.status == SettlementStatus.pending);
    final buf = StringBuffer()..writeln(name);
    for (final s in pending) {
      // Chave PIX cadastrada do recebedor (denormalizada no fechamento).
      buf.writeln(
        '${s.fromName} -> ${s.toName}: ${brlFromDecimal(s.amount)}, pix: ${s.toPixKey};',
      );
    }
    return buf.toString().trimRight();
  }

  Future<void> _share(BuildContext context) async {
    final text = _buildSummary();
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (_) {
      // Fallback (ex.: desktop sem Web Share API): copia o resumo.
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        showSpToast(
          context,
          'Resumo copiado!',
          type: SpToastType.success,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () => _share(context),
        icon: const Icon(Icons.ios_share, size: 16),
        label: const Text('Compartilhar resumo'),
        style: OutlinedButton.styleFrom(
          foregroundColor: SpColors.goldBright,
          side: BorderSide(color: SpColors.gold.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Nenhum acerto pendente.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 13,
          color: SpColors.muted,
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.doneCount,
    required this.total,
    required this.confirmedAmount,
  });
  final int doneCount;
  final int total;
  final Decimal confirmedAmount;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : doneCount / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.55),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROGRESSO',
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: SpColors.gold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$doneCount',
                          style: const TextStyle(
                            fontFamily: SpTypography.numFamily,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: SpColors.goldBright,
                          ),
                        ),
                        Text(
                          ' / $total',
                          style: const TextStyle(
                            fontFamily: SpTypography.numFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: SpColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'CONFIRMADOS',
                    style: TextStyle(
                      fontFamily: SpTypography.uiFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: SpColors.muted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    brlFromDecimal(confirmedAmount),
                    style: const TextStyle(
                      fontFamily: SpTypography.numFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: SpColors.cream,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 6,
              color: SpColors.feltDeep.withValues(alpha: 0.8),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [SpColors.gold, SpColors.goldBright],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PixRow extends StatelessWidget {
  const _PixRow({
    required this.settlement,
    required this.isReceiver,
    required this.submitting,
  });
  final Settlement settlement;
  final bool isReceiver;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    final isPending = settlement.status == SettlementStatus.pending;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.55),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SpAvatar(name: settlement.fromName, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: SpTypography.uiFamily,
                          fontSize: 13,
                          color: SpColors.cream,
                        ),
                        children: [
                          TextSpan(
                            text: settlement.fromName.split(' ').first,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(
                            text: ' → ',
                            style: TextStyle(color: SpColors.muted),
                          ),
                          TextSpan(
                            text: settlement.toName.split(' ').first,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settlement.toPixKey,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: SpTypography.numFamily,
                        fontSize: 11,
                        color: SpColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    brlFromDecimal(settlement.amount),
                    style: const TextStyle(
                      fontFamily: SpTypography.numFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: SpColors.cream,
                    ),
                  ),
                  const SizedBox(height: 3),
                  _StatusTag(status: settlement.status),
                ],
              ),
            ],
          ),
          if (isPending && isReceiver) ...[
            const SizedBox(height: 10),
            SpGoldButton(
              label: 'Marcar como recebido',
              loading: submitting,
              onPressed: submitting
                  ? null
                  : () => context.read<PixCubit>().confirm(settlement.id),
              height: 38,
              fontSize: 12,
            ),
          ],
          if (isPending && !isReceiver) ...[
            const SizedBox(height: 10),
            _CopyPixButton(settlement: settlement),
            const SizedBox(height: 8),
            SpGoldButton(
              label: settlement.isToGuest
                  ? 'Marcar como pago ao convidado'
                  : 'Marcar como pago',
              loading: submitting,
              onPressed: submitting
                  ? null
                  : () => context.read<PixCubit>().confirm(settlement.id),
              height: 38,
              fontSize: 12,
            ),
            if (settlement.isToGuest) ...[
              const SizedBox(height: 6),
              Text(
                '${settlement.toName} é convidado — só o host pode confirmar.',
                style: const TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 11,
                  color: SpColors.muted,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _CopyPixButton extends StatelessWidget {
  const _CopyPixButton({required this.settlement});
  final Settlement settlement;

  void _copy(BuildContext context) {
    final text = settlement.pixCopiaECola ?? settlement.toPixKey;
    Clipboard.setData(ClipboardData(text: text));
    showSpToast(context, 'PIX copiado!',
        type: SpToastType.success, duration: const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: OutlinedButton.icon(
        onPressed: () => _copy(context),
        icon: const Icon(Icons.copy, size: 14),
        label: Text(
          settlement.pixCopiaECola != null ? 'Copiar PIX copia e cola' : 'Copiar chave PIX',
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: SpColors.goldBright,
          side: BorderSide(color: SpColors.gold.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});
  final SettlementStatus status;

  @override
  Widget build(BuildContext context) {
    final isDone = status == SettlementStatus.confirmed;
    final color = isDone ? SpColors.successSoft : SpColors.goldBright;
    final bg =
        (isDone ? SpColors.success : SpColors.gold).withValues(alpha: 0.18);
    final border =
        (isDone ? SpColors.success : SpColors.gold).withValues(alpha: 0.4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isDone ? '✓ PAGO' : 'AGUARDANDO',
        style: TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
