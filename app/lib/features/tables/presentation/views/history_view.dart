import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../home/presentation/cubit/home_stats_cubit.dart';
import '../../domain/entities/entities.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeStatsCubit>(
      create: (_) => appDI.get<HomeStatsCubit>()..load(),
      child: const _HistoryScaffold(),
    );
  }
}

class _HistoryScaffold extends StatelessWidget {
  const _HistoryScaffold();

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
                title: 'Histórico',
              ),
              const Expanded(child: _Body()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeStatsCubit, HomeStatsState>(
      builder: (context, state) => switch (state) {
        HomeStatsLoading() => const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: SpColors.goldBright,
              ),
            ),
          ),
        HomeStatsError(:final failure) => _ErrorView(failure: failure),
        HomeStatsLoaded(:final stats) => _Loaded(stats: stats),
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.failure});
  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final message = switch (failure) {
      NetworkFailure() => 'Sem conexão com o servidor.',
      _ => 'Não foi possível carregar o histórico.',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: SpColors.dangerSoft, size: 36),
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
            const SizedBox(height: 16),
            SpGoldButton(
              label: 'Tentar novamente',
              onPressed: () => context.read<HomeStatsCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.stats});
  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final hosts = stats.history.where((t) => t.isHost).length;
    return RefreshIndicator(
      color: SpColors.goldBright,
      backgroundColor: SpColors.feltRail,
      onRefresh: () => context.read<HomeStatsCubit>().load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          _StatsPanel(
            pnlTotal: stats.pnlTotal,
            mesas: stats.history.length,
            wins: stats.wins,
            hosts: hosts,
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: SpFieldLabel('Todas as mesas'),
          ),
          const SizedBox(height: 12),
          if (stats.history.isEmpty)
            const _EmptyState()
          else
            for (final t in stats.history)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _HistoryTile(table: t),
              ),
        ],
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
        'Nenhuma mesa ainda.',
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

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.pnlTotal,
    required this.mesas,
    required this.wins,
    required this.hosts,
  });
  final Decimal pnlTotal;
  final int mesas;
  final int wins;
  final int hosts;

  @override
  Widget build(BuildContext context) {
    final isPositive = pnlTotal >= Decimal.zero;
    final prefix = isPositive ? '+' : '';
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
            '$prefix${brlFromDecimal(pnlTotal)}',
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
  const _HistoryTile({required this.table});
  final RecentTableSummary table;

  String _formatDate(DateTime dt) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String _formatDuration(DateTime start, DateTime end) {
    final d = end.difference(start);
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final isClosed = table.status == TableStatus.closed;
    final isOpen = table.status == TableStatus.open;
    final hasPositivePl = table.pl != null && table.pl! >= Decimal.zero;

    final Color iconBg;
    final Color iconBorder;
    final Suit suit;
    final Color iconColor;

    if (isOpen) {
      iconBg = SpColors.gold.withValues(alpha: 0.12);
      iconBorder = SpColors.gold.withValues(alpha: 0.3);
      suit = Suit.diamond;
      iconColor = SpColors.goldBright;
    } else if (table.pl == null) {
      iconBg = SpColors.muted.withValues(alpha: 0.12);
      iconBorder = SpColors.muted.withValues(alpha: 0.3);
      suit = Suit.club;
      iconColor = SpColors.muted;
    } else if (hasPositivePl) {
      iconBg = SpColors.success.withValues(alpha: 0.12);
      iconBorder = SpColors.success.withValues(alpha: 0.3);
      suit = Suit.heart;
      iconColor = SpColors.successSoft;
    } else {
      iconBg = SpColors.danger.withValues(alpha: 0.12);
      iconBorder = SpColors.danger.withValues(alpha: 0.3);
      suit = Suit.spade;
      iconColor = SpColors.dangerSoft;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isClosed && table.hasPendingSettlements) {
            context.push(AppRoutes.pix(table.id));
          } else {
            context.push(AppRoutes.tableDetail(table.id));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SpColors.feltRail.withValues(alpha: 0.55),
            border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  border: Border.all(color: iconBorder),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SuitGlyph(suit: suit, size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      table.name,
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
                          Text(_formatDate(table.createdAt)),
                          const Text(' · '),
                          Text('${table.players} jog.'),
                          if (isClosed && table.closedAt != null) ...[
                            const Text(' · '),
                            Text(_formatDuration(table.createdAt, table.closedAt!)),
                          ],
                          if (table.isHost) ...[
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
              _PlChip(table: table),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlChip extends StatelessWidget {
  const _PlChip({required this.table});
  final RecentTableSummary table;

  @override
  Widget build(BuildContext context) {
    if (table.status == TableStatus.open) {
      return _Badge(
        label: 'AO VIVO',
        color: SpColors.goldBright,
        bg: SpColors.gold.withValues(alpha: 0.18),
        border: SpColors.gold.withValues(alpha: 0.4),
      );
    }
    if (table.hasPendingSettlements) {
      return _Badge(
        label: 'PIX',
        color: SpColors.goldBright,
        bg: SpColors.gold.withValues(alpha: 0.18),
        border: SpColors.gold.withValues(alpha: 0.4),
      );
    }
    if (table.pl == null) return const SizedBox.shrink();
    final positive = table.pl! >= Decimal.zero;
    final prefix = positive ? '+' : '';
    return Text(
      '$prefix${brlFromDecimal(table.pl!)}',
      style: TextStyle(
        fontFamily: SpTypography.numFamily,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: positive ? SpColors.successSoft : SpColors.dangerSoft,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.bg,
    required this.border,
  });
  final String label;
  final Color color;
  final Color bg;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
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
