import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/router/app_routes.dart';
import '../mock/settlement_mock.dart';

class TableDetailView extends StatelessWidget {
  const TableDetailView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    final players = SettlementMock.players;
    final events = SettlementMock.events;
    final you = players.firstWhere((p) => p.role == 'VOCÊ');

    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Column(
            children: [
              SpAppHeader(
                left: SpBackButton(
                  onPressed: () => context.go(AppRoutes.history),
                ),
                title: 'Detalhes da mesa',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  children: [
                    _HeaderCard(you: you),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: SpFieldLabel('Linha do tempo'),
                    ),
                    const SizedBox(height: 12),
                    _TimelineList(events: events),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: SpFieldLabel('Resultado por jogador'),
                    ),
                    const SizedBox(height: 12),
                    _PlayerResultsList(players: players),
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.you});
  final SettlementMockPlayer you;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.55),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -18,
              child: Opacity(
                opacity: 0.25,
                child: PokerChipStack(
                  size: 100,
                  color: SpColors.gold,
                  count: 3,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${SettlementMock.date} · ENCERRADA'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: SpColors.gold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  SettlementMock.table,
                  style: const TextStyle(
                    fontFamily: SpTypography.displayFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: SpColors.cream,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _MetricColumn(
                      label: 'Duração',
                      value: SettlementMock.duration,
                    ),
                    const SizedBox(width: 20),
                    _MetricColumn(
                      label: 'Pote',
                      value: brl(SettlementMock.totalPot),
                    ),
                    const SizedBox(width: 20),
                    _MetricColumn(
                      label: 'Jogadores',
                      value: '${SettlementMock.players.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const GoldDivider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SEU RESULTADO',
                            style: TextStyle(
                              fontFamily: SpTypography.uiFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: SpColors.goldDark,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Investiu ${brl(you.invested)} · Saiu ${brl(you.out)}',
                            style: const TextStyle(
                              fontFamily: SpTypography.uiFamily,
                              fontSize: 12,
                              color: SpColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      (you.pl >= 0 ? '+' : '') + brl(you.pl),
                      style: TextStyle(
                        fontFamily: SpTypography.numFamily,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: you.pl >= 0
                            ? SpColors.successSoft
                            : SpColors.dangerSoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: SpTypography.numFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: SpColors.cream,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: SpColors.muted,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.events});
  final List<SettlementMockEvent> events;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.55),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (final e in events) _TimelineEventRow(event: e),
        ],
      ),
    );
  }
}

class _TimelineEventRow extends StatelessWidget {
  const _TimelineEventRow({required this.event});
  final SettlementMockEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              event.time,
              style: const TextStyle(
                fontFamily: SpTypography.numFamily,
                fontSize: 11,
                color: SpColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: SpColors.gold.withValues(alpha: 0.12),
              border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: _iconFor(event.kind),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event.text,
              style: const TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 13,
                color: SpColors.cream,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconFor(String kind) {
    switch (kind) {
      case 'start':
      case 'close':
        return const SuitGlyph(
          suit: Suit.spade,
          size: 10,
          color: SpColors.gold,
        );
      case 'join':
        return const Text(
          '+',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: SpColors.successSoft,
          ),
        );
      case 'rebuy':
        return const Text(
          '↻',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: SpColors.goldBright,
          ),
        );
      case 'out':
        return const Text(
          '−',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: SpColors.dangerSoft,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _PlayerResultsList extends StatelessWidget {
  const _PlayerResultsList({required this.players});
  final List<SettlementMockPlayer> players;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.55),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var i = 0; i < players.length; i++) ...[
            _PlayerResultRow(player: players[i]),
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

class _PlayerResultRow extends StatelessWidget {
  const _PlayerResultRow({required this.player});
  final SettlementMockPlayer player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SpAvatar(name: player.name, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SpColors.cream,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${brl(player.invested)} → ${brl(player.out)}',
                  style: const TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 10,
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
              fontSize: 14,
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
