import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/router/app_routes.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  static const _tables = <_HistoryRow>[
    _HistoryRow(
      date: 'Ontem',
      name: 'Sexta na casa do Léo',
      players: 7,
      pl: 340,
      duration: '4h 12min',
      isHost: false,
    ),
    _HistoryRow(
      date: '12 abr',
      name: 'Mesa do escritório',
      players: 5,
      pl: -120,
      duration: '3h 05min',
      isHost: false,
    ),
    _HistoryRow(
      date: '05 abr',
      name: 'Aniversário do Caio',
      players: 6,
      pl: 622,
      duration: '5h 40min',
      isHost: true,
    ),
    _HistoryRow(
      date: '29 mar',
      name: 'Domingo regular',
      players: 8,
      pl: -210,
      duration: '3h 50min',
      isHost: true,
    ),
    _HistoryRow(
      date: '22 mar',
      name: 'Terça quick',
      players: 4,
      pl: 180,
      duration: '2h 10min',
      isHost: false,
    ),
    _HistoryRow(
      date: '15 mar',
      name: 'Sexta na casa do Léo',
      players: 7,
      pl: 90,
      duration: '4h 30min',
      isHost: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final total = _tables.fold<int>(0, (s, t) => s + t.pl);
    final wins = _tables.where((t) => t.pl > 0).length;
    final hosts = _tables.where((t) => t.isHost).length;

    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Column(
            children: [
              SpAppHeader(
                left: SpBackButton(
                  onPressed: () => context.go(AppRoutes.home),
                ),
                title: 'Histórico',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                  children: [
                    _StatsPanel(
                      total: total,
                      mesas: _tables.length,
                      wins: wins,
                      hosts: hosts,
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: SpFieldLabel('Todas as mesas'),
                    ),
                    const SizedBox(height: 12),
                    for (final t in _tables)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _HistoryTile(row: t),
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

class _HistoryRow {
  const _HistoryRow({
    required this.date,
    required this.name,
    required this.players,
    required this.pl,
    required this.duration,
    required this.isHost,
  });
  final String date;
  final String name;
  final int players;
  final int pl;
  final String duration;
  final bool isHost;
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.total,
    required this.mesas,
    required this.wins,
    required this.hosts,
  });
  final int total;
  final int mesas;
  final int wins;
  final int hosts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SpColors.gold.withValues(alpha: 0.15),
            SpColors.gold.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'P&L ACUMULADO',
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
            '+${brl(total)}',
            style: const TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatColumn(label: 'Mesas', value: '$mesas'),
              const SizedBox(width: 18),
              _StatColumn(label: 'Vitórias', value: '$wins'),
              const SizedBox(width: 18),
              const _StatColumn(label: 'ROI médio', value: '+18%'),
              const SizedBox(width: 18),
              _StatColumn(label: 'Como host', value: '$hosts'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});
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

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.row});
  final _HistoryRow row;

  @override
  Widget build(BuildContext context) {
    final positive = row.pl >= 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(AppRoutes.tableDetail('history-${row.date}')),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SpColors.feltRail.withValues(alpha: 0.55),
            border:
                Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: positive
                      ? SpColors.success.withValues(alpha: 0.12)
                      : SpColors.danger.withValues(alpha: 0.12),
                  border: Border.all(
                    color: positive
                        ? SpColors.success.withValues(alpha: 0.3)
                        : SpColors.danger.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SuitGlyph(
                  suit: positive ? Suit.heart : Suit.spade,
                  size: 22,
                  color: positive ? SpColors.successSoft : SpColors.dangerSoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SpColors.cream,
                      ),
                    ),
                    const SizedBox(height: 3),
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 11,
                        color: SpColors.muted,
                      ),
                      child: Row(
                        children: [
                          Text(row.date),
                          const Text(' · '),
                          Text('${row.players} jog.'),
                          const Text(' · '),
                          Text(row.duration),
                          if (row.isHost) ...[
                            const Text(' · '),
                            const Text(
                              'Host',
                              style: TextStyle(color: SpColors.gold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                (positive ? '+' : '') + brl(row.pl),
                style: TextStyle(
                  fontFamily: SpTypography.numFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color:
                      positive ? SpColors.successSoft : SpColors.dangerSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
