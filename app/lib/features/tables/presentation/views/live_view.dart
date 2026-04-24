import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/router/app_routes.dart';

class LiveView extends StatelessWidget {
  const LiveView({required this.tableId, super.key});
  final String tableId;

  static const _players = <_Player>[
    _Player('Léo Castro', buyIn: 200, rebuys: [100], role: 'HOST'),
    _Player('Rafael Monteiro', buyIn: 150, rebuys: [], role: 'VOCÊ'),
    _Player('Amanda S.', buyIn: 100, rebuys: [50, 50]),
    _Player('Caio Farias', buyIn: 200, rebuys: []),
    _Player('Bruno T.', buyIn: 100, rebuys: []),
    _Player('Marina R.', buyIn: 150, rebuys: []),
  ];

  @override
  Widget build(BuildContext context) {
    final total = _players.fold<int>(
        0, (sum, p) => sum + p.buyIn + p.rebuys.fold<int>(0, (a, b) => a + b));
    final rebuyCount = _players.fold<int>(0, (s, p) => s + p.rebuys.length);

    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  SpAppHeader(
                    left: SpBackButton(
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                    title: 'Sexta na casa do Léo',
                    subtitle: const SpLiveLabel(text: 'ao vivo · 2h 14min'),
                    right: IconButton(
                      onPressed: () {},
                      color: SpColors.goldBright,
                      icon: const Icon(Icons.more_horiz),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                      children: [
                        _PotCard(total: total, playerCount: _players.length, rebuys: rebuyCount),
                        const SizedBox(height: 18),
                        const _SegmentedTabs(),
                        const SizedBox(height: 14),
                        for (final p in _players)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _PlayerRow(player: p),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _ActionBar(
                  onCashout: () => context.go(AppRoutes.cashout(tableId)),
                  onClose: () => context.go(AppRoutes.closeTable(tableId)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Player {
  const _Player(this.name, {required this.buyIn, required this.rebuys, this.role});
  final String name;
  final int buyIn;
  final List<int> rebuys;
  final String? role;
}

class _PotCard extends StatelessWidget {
  const _PotCard({
    required this.total,
    required this.playerCount,
    required this.rebuys,
  });
  final int total;
  final int playerCount;
  final int rebuys;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SpColors.gold.withValues(alpha: 0.15),
            SpColors.gold.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -10,
              child: Opacity(
                opacity: 0.4,
                child: PokerChipStack(
                  size: 90,
                  color: SpColors.gold,
                  count: 4,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL EM JOGO',
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
                  brl(total),
                  style: const TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$playerCount jogadores · $rebuys rebuys',
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 12,
                    color: SpColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Expanded(child: _TabButton(label: 'Mesa', selected: true)),
          SizedBox(width: 4),
          Expanded(child: _TabButton(label: 'Histórico', selected: false)),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? SpColors.gold.withValues(alpha: 0.2)
            : Colors.transparent,
        border: Border.all(
          color: selected
              ? SpColors.gold.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? SpColors.goldBright : SpColors.muted,
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});
  final _Player player;

  @override
  Widget build(BuildContext context) {
    final total = player.buyIn + player.rebuys.fold<int>(0, (a, b) => a + b);
    final isYou = player.role == 'VOCÊ';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isYou
            ? SpColors.gold.withValues(alpha: 0.1)
            : SpColors.feltRail.withValues(alpha: 0.45),
        border: Border.all(
          color: isYou
              ? SpColors.gold.withValues(alpha: 0.35)
              : SpColors.cream.withValues(alpha: 0.06),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SpAvatar(name: player.name, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: SpTypography.uiFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: SpColors.cream,
                        ),
                      ),
                    ),
                    if (player.role != null) ...[
                      const SizedBox(width: 6),
                      _RoleBadge(role: player.role!),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _secondary(player),
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 12,
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
                brl(total),
                style: const TextStyle(
                  fontFamily: SpTypography.numFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SpColors.cream,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'EM JOGO',
                style: TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: SpColors.goldDark,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _secondary(_Player p) {
    final sum = p.rebuys.fold<int>(0, (a, b) => a + b);
    if (p.rebuys.isEmpty) return 'Entrou ${brl(p.buyIn)}';
    final label = p.rebuys.length == 1 ? 'rebuy' : 'rebuys';
    return 'Entrou ${brl(p.buyIn)} · ${p.rebuys.length} $label (${brl(sum)})';
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final isHost = role == 'HOST';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isHost
            ? SpColors.gold.withValues(alpha: 0.25)
            : SpColors.success.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isHost ? SpColors.goldBright : SpColors.successSoft,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onCashout, required this.onClose});
  final VoidCallback onCashout;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SpColors.feltDeep.withValues(alpha: 0),
            SpColors.feltDeep.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.35],
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: SpGhostButton(label: '+ Rebuy', onPressed: null),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SpGhostButton(
              label: 'Sair da mesa',
              onPressed: onCashout,
              color: SpColors.dangerSoft,
              borderColor: SpColors.dangerSoft.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: SpGoldButton(
              label: 'Fechar mesa',
              onPressed: onClose,
              height: 48,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
