import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/async_state.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/poker_table.dart';
import '../../domain/entities/table_participation.dart';
import '../../domain/entities/table_status.dart';
import '../cubit/table_detail_cubit.dart';

class TableDetailView extends StatelessWidget {
  const TableDetailView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TableDetailCubit>(
      create: (_) => appDI.get<TableDetailCubit>()..load(tableId),
      child: _TableDetailScaffold(tableId: tableId),
    );
  }
}

class _TableDetailScaffold extends StatelessWidget {
  const _TableDetailScaffold({required this.tableId});
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
                title: 'Detalhes da mesa',
              ),
              Expanded(
                child: BlocBuilder<TableDetailCubit, AsyncState<PokerTable>>(
                  builder: (context, state) => switch (state) {
                    AsyncInitial() || AsyncLoading() => const _Loading(),
                    AsyncError(:final failure) =>
                      _ErrorView(failure: failure, tableId: tableId),
                    AsyncSuccess(:final data) =>
                      _Content(table: data, tableId: tableId),
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
  const _ErrorView({required this.failure, required this.tableId});
  final Failure failure;
  final String tableId;

  @override
  Widget build(BuildContext context) {
    final message = switch (failure) {
      UnauthorizedFailure() => 'Sem permissão para ver esta mesa.',
      NotFoundFailure() => 'Mesa não encontrada.',
      NetworkFailure() => 'Sem conexão com o servidor.',
      _ => 'Não foi possível carregar a mesa.',
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
            const SizedBox(height: 16),
            SpGoldButton(
              label: 'Tentar novamente',
              onPressed: () =>
                  context.read<TableDetailCubit>().load(tableId),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.table, required this.tableId});
  final PokerTable table;
  final String tableId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final currentUserId =
        auth is AuthAuthenticated ? auth.user.id : null;

    final myParticipation = currentUserId == null
        ? null
        : table.participations
            .where((p) => p.userId == currentUserId)
            .firstOrNull;

    final ownerParticipation = table.participations
        .where((p) => p.userId == table.ownerId)
        .firstOrNull;
    final ownerName = ownerParticipation?.userName ?? 'Host';

    var totalPot = Decimal.zero;
    for (final p in table.participations) {
      for (final b in p.buyIns) {
        totalPot += b.amount;
      }
    }

    String? durationStr;
    if (table.closedAt != null) {
      final d = table.closedAt!.difference(table.createdAt);
      final h = d.inHours;
      final m = d.inMinutes % 60;
      durationStr =
          h == 0 ? '${m}min' : m == 0 ? '${h}h' : '${h}h ${m}min';
    }

    final playerResults = table.participations.map((p) {
      final invested =
          p.buyIns.fold(Decimal.zero, (acc, b) => acc + b.amount);
      final out = p.cashOut?.amount ?? Decimal.zero;
      return _PlayerResult(
        name: p.userName,
        invested: invested,
        out: out,
        pl: out - invested,
        hasCashOut: p.cashOut != null,
        isMe: p.userId == currentUserId,
      );
    }).toList()
      ..sort((a, b) => b.pl.compareTo(a.pl));

    final events = _buildTimeline(table, ownerName);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        _HeaderCard(
          table: table,
          myParticipation: myParticipation,
          ownerName: ownerName,
          totalPot: totalPot,
          durationStr: durationStr,
        ),
        if (table.status == TableStatus.closed) ...[
          const SizedBox(height: 12),
          SpGoldButton(
            label: 'Ver acertos PIX',
            onPressed: () => context.go(AppRoutes.pix(tableId)),
          ),
        ],
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
        _PlayerResultsList(players: playerResults),
      ],
    );
  }

  static List<_TimelineEvent> _buildTimeline(
      PokerTable table, String ownerName) {
    final events = <_TimelineEvent>[];

    events.add(_TimelineEvent(
      time: table.createdAt,
      kind: 'start',
      text: 'Mesa aberta por $ownerName',
    ));

    for (final p in table.participations) {
      final sorted = [...p.buyIns]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      for (var i = 0; i < sorted.length; i++) {
        final bi = sorted[i];
        events.add(_TimelineEvent(
          time: bi.createdAt,
          kind: i == 0 ? 'join' : 'rebuy',
          text:
              '${p.userName} ${i == 0 ? "entrou" : "rebuy"} · ${brlFromDecimal(bi.amount)}',
        ));
      }
    }

    for (final p in table.participations) {
      if (p.cashOut != null) {
        final invested =
            p.buyIns.fold(Decimal.zero, (acc, b) => acc + b.amount);
        final pl = p.cashOut!.amount - invested;
        final prefix = pl >= Decimal.zero ? '+' : '';
        events.add(_TimelineEvent(
          time: p.cashOut!.createdAt,
          kind: 'out',
          text:
              '${p.userName} saiu · ${brlFromDecimal(p.cashOut!.amount)} ($prefix${brlFromDecimal(pl)})',
        ));
      }
    }

    if (table.closedAt != null) {
      events.add(_TimelineEvent(
        time: table.closedAt!,
        kind: 'close',
        text: 'Mesa fechada',
      ));
    }

    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }
}

class _TimelineEvent {
  const _TimelineEvent(
      {required this.time, required this.kind, required this.text});
  final DateTime time;
  final String kind;
  final String text;
}

class _PlayerResult {
  const _PlayerResult({
    required this.name,
    required this.invested,
    required this.out,
    required this.pl,
    required this.hasCashOut,
    required this.isMe,
  });
  final String name;
  final Decimal invested;
  final Decimal out;
  final Decimal pl;
  final bool hasCashOut;
  final bool isMe;
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.table,
    required this.myParticipation,
    required this.ownerName,
    required this.totalPot,
    this.durationStr,
  });
  final PokerTable table;
  final TableParticipation? myParticipation;
  final String ownerName;
  final Decimal totalPot;
  final String? durationStr;

  static String _formatDate(DateTime dt) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isClosed = table.status == TableStatus.closed;
    final statusLabel = isClosed ? 'ENCERRADA' : 'AO VIVO';
    final dateLabel = _formatDate(table.createdAt);

    Decimal? myInvested;
    Decimal? myOut;
    Decimal? myPl;
    if (myParticipation != null) {
      final invested = myParticipation!.buyIns
          .fold<Decimal>(Decimal.zero, (acc, b) => acc + b.amount);
      myInvested = invested;
      myOut = myParticipation!.cashOut?.amount;
      if (isClosed && myOut != null) {
        myPl = myOut - invested;
      }
    }

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
                child: PokerChipStack(size: 100, color: SpColors.gold, count: 3),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dateLabel · $statusLabel',
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
                  table.name,
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
                    if (durationStr != null) ...[
                      _MetricColumn(label: 'Duração', value: durationStr!),
                      const SizedBox(width: 20),
                    ],
                    _MetricColumn(
                        label: 'Pote', value: brlFromDecimal(totalPot)),
                    const SizedBox(width: 20),
                    _MetricColumn(
                        label: 'Jogadores',
                        value: '${table.participations.length}'),
                  ],
                ),
                if (myParticipation != null && myInvested != null) ...[
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
                              myOut != null
                                  ? 'Investiu ${brlFromDecimal(myInvested)} · Saiu ${brlFromDecimal(myOut)}'
                                  : 'Investido: ${brlFromDecimal(myInvested)}',
                              style: const TextStyle(
                                fontFamily: SpTypography.uiFamily,
                                fontSize: 12,
                                color: SpColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (myPl != null)
                        Text(
                          (myPl >= Decimal.zero ? '+' : '') +
                              brlFromDecimal(myPl),
                          style: TextStyle(
                            fontFamily: SpTypography.numFamily,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: myPl >= Decimal.zero
                                ? SpColors.successSoft
                                : SpColors.dangerSoft,
                          ),
                        )
                      else
                        const _LiveBadge(),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: SpColors.gold.withValues(alpha: 0.18),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'AO VIVO',
        style: TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: SpColors.goldBright,
          letterSpacing: 0.8,
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
  final List<_TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.55),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [for (final e in events) _TimelineEventRow(event: e)],
      ),
    );
  }
}

class _TimelineEventRow extends StatelessWidget {
  const _TimelineEventRow({required this.event});
  final _TimelineEvent event;

  static String _hhmm(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              _hhmm(event.time),
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
              border:
                  Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
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
        return const SuitGlyph(suit: Suit.spade, size: 10, color: SpColors.gold);
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
  final List<_PlayerResult> players;

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
  final _PlayerResult player;

  @override
  Widget build(BuildContext context) {
    final positive = player.pl >= Decimal.zero;
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
                Row(
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
                    if (player.isMe) ...[
                      const SizedBox(width: 6),
                      const Text(
                        'VOCÊ',
                        style: TextStyle(
                          fontFamily: SpTypography.uiFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: SpColors.gold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  player.hasCashOut
                      ? '${brlFromDecimal(player.invested)} → ${brlFromDecimal(player.out)}'
                      : 'Investido: ${brlFromDecimal(player.invested)}',
                  style: const TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 10,
                    color: SpColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (player.hasCashOut)
            Text(
              (positive ? '+' : '') + brlFromDecimal(player.pl),
              style: TextStyle(
                fontFamily: SpTypography.numFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: positive ? SpColors.successSoft : SpColors.dangerSoft,
              ),
            )
          else
            const Text(
              'em jogo',
              style: TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 11,
                color: SpColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}
