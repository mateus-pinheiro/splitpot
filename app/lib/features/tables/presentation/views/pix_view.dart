import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/router/app_routes.dart';
import '../mock/settlement_mock.dart';

class PixView extends StatelessWidget {
  const PixView({required this.tableId, super.key});
  final String tableId;

  // Mock status pra demonstrar os 3 estados (done/pending/failed).
  static const _statuses = <_Status>[
    _Status.done,
    _Status.done,
    _Status.pending,
    _Status.failed,
    _Status.done,
  ];

  @override
  Widget build(BuildContext context) {
    final transfers = SettlementMock.transfers;
    final doneCount = _statuses.where((s) => s == _Status.done).length;
    final confirmedAmount = [
      for (var i = 0; i < transfers.length; i++)
        if (_statuses[i] == _Status.done) transfers[i].amount,
    ].fold<int>(0, (a, b) => a + b);

    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Column(
            children: [
              SpAppHeader(
                left: SpBackButton(
                  onPressed: () => context.go(AppRoutes.closeTable(tableId)),
                ),
                title: 'Acertos PIX',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  children: [
                    _ProgressCard(
                      doneCount: doneCount,
                      total: transfers.length,
                      confirmedAmount: confirmedAmount,
                    ),
                    const SizedBox(height: 18),
                    for (var i = 0; i < transfers.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PixRow(
                          transfer: transfers[i],
                          status: _statuses[i],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                child: SpGoldButton(
                  label: 'Encerrar mesa',
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Status { done, pending, failed }

extension on _Status {
  String get label => switch (this) {
        _Status.done => '✓ Pago',
        _Status.pending => 'Aguardando',
        _Status.failed => 'Falhou',
      };
  Color get color => switch (this) {
        _Status.done => SpColors.successSoft,
        _Status.pending => SpColors.goldBright,
        _Status.failed => SpColors.dangerSoft,
      };
  Color get bg => switch (this) {
        _Status.done => SpColors.success.withValues(alpha: 0.18),
        _Status.pending => SpColors.gold.withValues(alpha: 0.18),
        _Status.failed => SpColors.danger.withValues(alpha: 0.18),
      };
  Color get border => switch (this) {
        _Status.done => SpColors.success.withValues(alpha: 0.4),
        _Status.pending => SpColors.gold.withValues(alpha: 0.4),
        _Status.failed => SpColors.danger.withValues(alpha: 0.4),
      };
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.doneCount,
    required this.total,
    required this.confirmedAmount,
  });
  final int doneCount;
  final int total;
  final int confirmedAmount;

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
                    brl(confirmedAmount),
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
  const _PixRow({required this.transfer, required this.status});
  final SettlementMockTransfer transfer;
  final _Status status;

  @override
  Widget build(BuildContext context) {
    final failed = status == _Status.failed;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.55),
        border: Border.all(
          color: failed ? status.border : SpColors.cream.withValues(alpha: 0.08),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SpAvatar(name: transfer.from, size: 32),
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
                            text: transfer.from.split(' ').first,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(
                            text: ' → ',
                            style: TextStyle(color: SpColors.muted),
                          ),
                          TextSpan(
                            text: transfer.to.split(' ').first,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transfer.pix,
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
                    brl(transfer.amount),
                    style: const TextStyle(
                      fontFamily: SpTypography.numFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: SpColors.cream,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: status.bg,
                      border: Border.all(color: status.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status.label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: status.color,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (status == _Status.pending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SpGoldButton(
                    label: 'Abrir QR Code PIX',
                    onPressed: () {},
                    height: 36,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SpGhostButton(
                    label: 'Marcar pago',
                    onPressed: () {},
                    height: 36,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          if (status == _Status.failed) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: SpColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: SpColors.dangerSoft, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chave PIX inválida. Contate ${transfer.to.split(' ').first}.',
                      style: const TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 11,
                        color: SpColors.dangerSoft,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      'Tentar de novo',
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: SpColors.dangerSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
