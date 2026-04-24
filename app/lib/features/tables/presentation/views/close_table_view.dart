import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/router/app_routes.dart';
import '../mock/settlement_mock.dart';

class CloseTableView extends StatelessWidget {
  const CloseTableView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    final totalPot = SettlementMock.totalPot;
    final players = SettlementMock.players;
    final transfers = SettlementMock.transfers;
    final pairs = players.length * (players.length - 1) ~/ 2;

    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Column(
            children: [
              SpAppHeader(
                left: SpBackButton(
                  onPressed: () => context.go(AppRoutes.live(tableId)),
                ),
                title: 'Fechar mesa',
                subtitle: const Text(
                  'REVISÃO FINAL',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 11,
                    color: SpColors.muted,
                    letterSpacing: 0.55,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  children: [
                    _SummaryCard(totalPot: totalPot),
                    const SizedBox(height: 22),
                    const SpFieldLabel('Resultado da mesa'),
                    const SizedBox(height: 10),
                    _ResultsList(players: players),
                    const SizedBox(height: 22),
                    _SettlementsHeader(
                      pairs: pairs,
                      transferCount: transfers.length,
                    ),
                    const SizedBox(height: 12),
                    for (final t in transfers)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TransferDiagram(transfer: t),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                child: Row(
                  children: [
                    Expanded(
                      child: SpGhostButton(
                        label: 'Voltar',
                        onPressed: () => context.go(AppRoutes.live(tableId)),
                        height: 52,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: SpGoldButton(
                        label: 'Gerar QR Codes PIX',
                        onPressed: () => context.go(AppRoutes.pix(tableId)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalPot});
  final int totalPot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SpColors.gold.withValues(alpha: 0.14),
            SpColors.gold.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'POTE TOTAL',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: SpColors.gold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                GoldFoilText(
                  brl(totalPot),
                  style: const TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'DURAÇÃO',
                style: TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: SpColors.muted,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '4h 12min',
                style: TextStyle(
                  fontFamily: SpTypography.numFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SpColors.cream,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '6 jogadores',
                style: TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 11,
                  color: SpColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.players});
  final List<SettlementMockPlayer> players;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var i = 0; i < players.length; i++) ...[
            _ResultRow(player: players[i]),
            if (i < players.length - 1)
              Divider(
                height: 1,
                color: SpColors.cream.withValues(alpha: 0.06),
              ),
          ],
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.player});
  final SettlementMockPlayer player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SpAvatar(name: player.name, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SpColors.cream,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'entrou ${brl(player.invested)} · saiu ${brl(player.out)}',
                  style: const TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 11,
                    color: SpColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            (player.pl >= 0 ? '+' : '') + brl(player.pl),
            style: TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: player.pl >= 0
                  ? SpColors.successSoft
                  : SpColors.dangerSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementsHeader extends StatelessWidget {
  const _SettlementsHeader({required this.pairs, required this.transferCount});
  final int pairs;
  final int transferCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SpFieldLabel('Acertos PIX · otimizados'),
            Text(
              '$transferCount transferências',
              style: const TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 11,
                color: SpColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Algoritmo minimizou de $pairs para apenas $transferCount pagamentos.',
          style: const TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 12,
            color: SpColors.muted,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _TransferDiagram extends StatelessWidget {
  const _TransferDiagram({required this.transfer});
  final SettlementMockTransfer transfer;

  @override
  Widget build(BuildContext context) {
    final fromFirst = transfer.from.split(' ').first;
    final toFirst = transfer.to.split(' ').first;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SpAvatar(name: transfer.from, size: 30),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              SpColors.gold.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: SpColors.gold.withValues(alpha: 0.18),
                        border: Border.all(
                          color: SpColors.gold.withValues(alpha: 0.35),
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        brl(transfer.amount),
                        style: const TextStyle(
                          fontFamily: SpTypography.numFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: SpColors.goldBright,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              SpColors.gold.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SpAvatar(name: transfer.to, size: 30),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  fromFirst,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 12,
                    color: SpColors.cream,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '→ ${transfer.pix}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 10,
                    color: SpColors.muted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  toFirst,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 12,
                    color: SpColors.cream,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
