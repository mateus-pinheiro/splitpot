import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../tables/domain/entities/table_status.dart';
import '../../../tables/domain/entities/user_stats.dart';
import '../cubit/home_stats_cubit.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeStatsCubit>(
      create: (_) => appDI.get<HomeStatsCubit>()
        ..load(),
      child: const Scaffold(
        body: FeltBackground(
          child: SafeArea(
            child: _AuthGate(),
          ),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        return _HomeScaffold(user: user);
      },
    );
  }
}

class _HomeScaffold extends StatelessWidget {
  const _HomeScaffold({required this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.name ?? 'Jogador';
    return Column(
      children: [
        SpAppHeader(
          left: GestureDetector(
            onLongPress: () => context.read<AuthCubit>().signOut(),
            child: SpAvatar(name: displayName, size: 32),
          ),
          right: _LogoutIcon(() => context.read<AuthCubit>().signOut()),
        ),
        const Expanded(child: _HomeContent()),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: SpColors.goldBright,
      backgroundColor: SpColors.feltDeep,
      onRefresh: () => context.read<HomeStatsCubit>().load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          const _HeroCreateCard(),
          const SizedBox(height: 24),
          const _DebtsBlock(),
          const _ReceivablesBlock(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Suas estatísticas',
                  style: TextStyle(
                    fontFamily: SpTypography.displayFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SpColors.cream,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.history),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Ver tudo',
                    style: TextStyle(
                      fontFamily: SpTypography.uiFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SpColors.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _StatsGrid(),
          const SizedBox(height: 28),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Mesas recentes',
              style: TextStyle(
                fontFamily: SpTypography.displayFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: SpColors.cream,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _RecentList(),
        ],
      ),
    );
  }
}

class _HeroCreateCard extends StatelessWidget {
  const _HeroCreateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SpColors.gold.withValues(alpha: 0.18),
            SpColors.gold.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.3,
                child: PokerChipStack(size: 90, color: SpColors.gold, count: 3),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMEÇAR AGORA',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: SpColors.gold,
                    letterSpacing: 1.65,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nova mesa\nde cash game',
                  style: TextStyle(
                    fontFamily: SpTypography.displayFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: SpColors.cream,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(
                  width: 220,
                  child: Text(
                    'Crie uma mesa, compartilhe o QR e deixe o app cuidar do caixa.',
                    style: TextStyle(
                      fontFamily: SpTypography.uiFamily,
                      fontSize: 13,
                      color: SpColors.muted,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SpGoldButton(
                  label: 'Criar mesa',
                  onPressed: () => context.go(AppRoutes.createTable),
                  height: 42,
                  fontSize: 14,
                  expand: false,
                  trailing: const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: Color(0xFF2A1D08),
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeStatsCubit, HomeStatsState>(
      builder: (context, state) {
        final loading = state is HomeStatsLoading;
        final stats = state is HomeStatsLoaded ? state.stats : null;

        final pnl = stats == null ? null : _formatPnl(stats.pnlTotal);
        final pnlSub = stats == null
            ? '—'
            : 'em ${stats.mesas} ${stats.mesas == 1 ? 'mesa' : 'mesas'}';
        final pnlColor = stats == null
            ? const Color(0xFF222222)
            : (stats.pnlTotal >= Decimal.zero
                  ? SpColors.success
                  : SpColors.danger);

        final winRate = stats == null
            ? null
            : _formatWinRate(stats.wins, stats.mesas);
        final winSub = stats == null
            ? '—'
            : '${stats.wins} de ${stats.mesas} ${stats.mesas == 1 ? 'mesa' : 'mesas'}';

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'P&L total',
                value: pnl ?? '—',
                sub: pnlSub,
                valueColor: pnlColor,
                loading: loading,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Taxa de vitória',
                value: winRate ?? '—',
                sub: winSub,
                valueColor: const Color(0xFF222222),
                loading: loading,
              ),
            ),
          ],
        );
      },
    );
  }

  static String _formatPnl(Decimal value) {
    final prefix = value > Decimal.zero ? '+' : '';
    return '$prefix${brlFromDecimal(value)}';
  }

  static String _formatWinRate(int wins, int mesas) {
    if (mesas == 0) return '0%';
    final rate = (wins * 100 / mesas).round();
    return '$rate%';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.valueColor,
    required this.loading,
  });

  final String label;
  final String value;
  final String sub;
  final Color valueColor;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5).withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(SpRadius.hero),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: SpColors.goldDark,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          loading
              ? const SizedBox(
                  height: 22,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SpColors.gold,
                      ),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 11,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentList extends StatelessWidget {
  const _RecentList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeStatsCubit, HomeStatsState>(
      builder: (context, state) {
        if (state is HomeStatsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SpColors.goldBright,
                ),
              ),
            ),
          );
        }
        if (state is HomeStatsError) {
          return _StatusMessage(
            text: 'Não foi possível carregar suas mesas.',
            color: SpColors.dangerSoft,
          );
        }
        if (state is HomeStatsLoaded) {
          final recents = state.stats.recents;
          if (recents.isEmpty) {
            return const _StatusMessage(
              text: 'Nenhuma mesa ainda. Crie sua primeira para começar.',
              color: SpColors.muted,
            );
          }
          return Column(
            children: [
              for (final t in recents)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _RecentTableRow(table: t),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.45),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 13,
          color: color,
        ),
      ),
    );
  }
}

class _RecentTableRow extends StatelessWidget {
  const _RecentTableRow({required this.table});
  final RecentTableSummary table;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (table.hasPendingSettlements) {
            context.push(AppRoutes.pix(table.id));
          } else if (table.status == TableStatus.closed) {
            context.push(AppRoutes.tableDetail(table.id));
          } else {
            context.go(AppRoutes.live(table.id));
          }
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: SpColors.feltRail.withValues(alpha: 0.45),
            border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _DateBadge(date: table.createdAt, status: table.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            table.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: SpTypography.uiFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: SpColors.cream,
                            ),
                          ),
                        ),
                        if (table.isHost)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(
                              '· HOST',
                              style: TextStyle(
                                fontFamily: SpTypography.uiFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: SpColors.gold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _secondary(table),
                      style: const TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 12,
                        color: SpColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              _PlValue(table: table),
            ],
          ),
        ),
      ),
    );
  }

  static String _secondary(RecentTableSummary t) {
    final players = '${t.players} ${t.players == 1 ? 'jogador' : 'jogadores'}';
    if (t.hasPendingSettlements) {
      return 'Aguardando pagamentos · $players';
    }
    if (t.status == TableStatus.open) return 'Em andamento · $players';
    return players;
  }
}

class _PlValue extends StatelessWidget {
  const _PlValue({required this.table});
  final RecentTableSummary table;

  @override
  Widget build(BuildContext context) {
    if (table.hasPendingSettlements) {
      return _StatusBadge(
        label: 'AGUARDANDO',
        color: SpColors.goldBright,
        bg: SpColors.gold.withValues(alpha: 0.18),
        border: SpColors.gold.withValues(alpha: 0.4),
      );
    }
    if (table.status == TableStatus.open) {
      return _StatusBadge(
        label: 'AO VIVO',
        color: SpColors.goldBright,
        bg: SpColors.gold.withValues(alpha: 0.18),
        border: SpColors.gold.withValues(alpha: 0.4),
      );
    }
    final pl = table.pl;
    if (pl == null) {
      return const Text(
        '—',
        style: TextStyle(
          fontFamily: SpTypography.numFamily,
          fontSize: 15,
          color: SpColors.muted,
        ),
      );
    }
    final positive = pl >= Decimal.zero;
    final prefix = pl > Decimal.zero ? '+' : '';
    return Text(
      '$prefix${brlFromDecimal(pl)}',
      style: TextStyle(
        fontFamily: SpTypography.numFamily,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: positive ? SpColors.success : SpColors.dangerSoft,
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date, required this.status});
  final DateTime date;
  final TableStatus status;

  static const _months = [
    'JAN',
    'FEV',
    'MAR',
    'ABR',
    'MAI',
    'JUN',
    'JUL',
    'AGO',
    'SET',
    'OUT',
    'NOV',
    'DEZ',
  ];

  @override
  Widget build(BuildContext context) {
    final color = status == TableStatus.open
        ? SpColors.gold
        : SpColors.goldDark;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: SpColors.gold.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _months[date.month - 1],
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1.0,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date.day.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontFamily: SpTypography.displayFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: SpColors.cream,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutIcon extends StatelessWidget {
  final VoidCallback? onPressed;

  const _LogoutIcon(this.onPressed);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.logout),
      color: SpColors.goldBright,
      splashRadius: 20,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
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
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

/// Bloco "Você deve" — só aparece quando há settlements pendentes.
class _DebtsBlock extends StatefulWidget {
  const _DebtsBlock();

  @override
  State<_DebtsBlock> createState() => _DebtsBlockState();
}

class _DebtsBlockState extends State<_DebtsBlock> {
  final Set<String> _seenDebtIds = <String>{};
  bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeStatsCubit, HomeStatsState>(
      buildWhen: (p, c) => c is HomeStatsLoaded || p is HomeStatsLoaded,
      builder: (context, state) {
        if (state is! HomeStatsLoaded) return const SizedBox.shrink();
        final debts = state.stats.debts;
        if (debts.isEmpty) return const SizedBox.shrink();

        if (!_seeded) {
          _seenDebtIds.addAll(debts.map((d) => d.id));
          _seeded = true;
        }

        final total = debts.fold<Decimal>(
          Decimal.zero,
          (acc, d) => acc + d.amount,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Você deve',
                      style: TextStyle(
                        fontFamily: SpTypography.displayFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: SpColors.cream,
                      ),
                    ),
                    Text(
                      '−${brlFromDecimal(total)}',
                      style: const TextStyle(
                        fontFamily: SpTypography.numFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SpColors.dangerSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final d in debts)
                Padding(
                  key: ValueKey('debt-${d.id}'),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NewHomeItemReveal(
                    animate: _markAndCheckNewDebt(d.id),
                    child: _DebtRow(debt: d),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _markAndCheckNewDebt(String id) {
    if (_seenDebtIds.contains(id)) return false;
    _seenDebtIds.add(id);
    return true;
  }
}

/// Bloco "Você tem a receber" — só aparece quando há settlements pendentes
/// em que o usuário é recebedor.
class _ReceivablesBlock extends StatefulWidget {
  const _ReceivablesBlock();

  @override
  State<_ReceivablesBlock> createState() => _ReceivablesBlockState();
}

class _ReceivablesBlockState extends State<_ReceivablesBlock> {
  final Set<String> _seenReceivableIds = <String>{};
  bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeStatsCubit, HomeStatsState>(
      buildWhen: (p, c) => c is HomeStatsLoaded || p is HomeStatsLoaded,
      builder: (context, state) {
        if (state is! HomeStatsLoaded) return const SizedBox.shrink();
        final receivables = state.stats.receivables;
        if (receivables.isEmpty) return const SizedBox.shrink();

        if (!_seeded) {
          _seenReceivableIds.addAll(receivables.map((r) => r.id));
          _seeded = true;
        }

        final total = receivables.fold<Decimal>(
          Decimal.zero,
          (acc, r) => acc + r.amount,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Você tem a receber',
                      style: TextStyle(
                        fontFamily: SpTypography.displayFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: SpColors.cream,
                      ),
                    ),
                    Text(
                      '+${brlFromDecimal(total)}',
                      style: const TextStyle(
                        fontFamily: SpTypography.numFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SpColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final r in receivables)
                Padding(
                  key: ValueKey('receivable-${r.id}'),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NewHomeItemReveal(
                    animate: _markAndCheckNewReceivable(r.id),
                    child: _ReceivableRow(receivable: r),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _markAndCheckNewReceivable(String id) {
    if (_seenReceivableIds.contains(id)) return false;
    _seenReceivableIds.add(id);
    return true;
  }
}

class _NewHomeItemReveal extends StatefulWidget {
  const _NewHomeItemReveal({required this.animate, required this.child});

  final bool animate;
  final Widget child;

  @override
  State<_NewHomeItemReveal> createState() => _NewHomeItemRevealState();
}

class _NewHomeItemRevealState extends State<_NewHomeItemReveal> {
  late bool _visible = !widget.animate;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _visible = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0.0, 0.1),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

void _showPixDialog(BuildContext context, DebtItem debt) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => _DebtPixDialog(debt: debt),
  );
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({required this.debt});
  final DebtItem debt;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPixDialog(context, debt),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: SpColors.danger.withValues(alpha: 0.1),
            border: Border.all(color: SpColors.danger.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SpAvatar(name: debt.toName, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pagar para ${debt.toName}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SpColors.cream,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      debt.tableName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 12,
                        color: SpColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                brlFromDecimal(debt.amount),
                style: const TextStyle(
                  fontFamily: SpTypography.numFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SpColors.dangerSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceivableRow extends StatefulWidget {
  const _ReceivableRow({required this.receivable});
  final ReceivableItem receivable;

  @override
  State<_ReceivableRow> createState() => _ReceivableRowState();
}

class _ReceivableRowState extends State<_ReceivableRow> {
  bool _confirming = false;

  Future<void> _confirmReceived() async {
    if (_confirming) return;
    setState(() => _confirming = true);
    try {
      await context.read<HomeStatsCubit>().confirmDebt(widget.receivable.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SpColors.success,
          content: Text('Recebimento confirmado.'),
          duration: Duration(seconds: 1),
        ),
      );
    } on Object catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SpColors.danger,
          content: Text('Não foi possível confirmar o recebimento.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _confirming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receivable = widget.receivable;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: SpColors.success.withValues(alpha: 0.1),
        border: Border.all(color: SpColors.success.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SpAvatar(name: receivable.fromName, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receber de ${receivable.fromName}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: SpColors.cream,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  receivable.tableName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 12,
                    color: SpColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                brlFromDecimal(receivable.amount),
                style: const TextStyle(
                  fontFamily: SpTypography.numFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SpColors.success,
                ),
              ),
              const SizedBox(width: 8),
              _confirming
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SpColors.success,
                      ),
                    )
                  : IconButton(
                      onPressed: _confirmReceived,
                      icon: const Icon(Icons.check_circle),
                      color: SpColors.success,
                      iconSize: 20,
                      splashRadius: 18,
                      tooltip: 'Confirmar recebimento',
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DebtPixDialog extends StatelessWidget {
  const _DebtPixDialog({required this.debt});
  final DebtItem debt;

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: SpColors.feltRail,
        content: Text('Copiado!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pixText = debt.pixCopiaECola ?? debt.toPixKey;
    final isFullPix = debt.pixCopiaECola != null;

    return Dialog(
      backgroundColor: SpColors.feltDeep,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: SpColors.danger.withValues(alpha: 0.4)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TRANSFERÊNCIA PENDENTE',
                    style: TextStyle(
                      fontFamily: SpTypography.uiFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: SpColors.dangerSoft,
                      letterSpacing: 1.5,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    color: SpColors.cream,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  SpAvatar(name: debt.toName, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pagar para ${debt.toName}',
                          style: const TextStyle(
                            fontFamily: SpTypography.uiFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: SpColors.cream,
                          ),
                        ),
                        Text(
                          debt.tableName,
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
                    brlFromDecimal(debt.amount),
                    style: const TextStyle(
                      fontFamily: SpTypography.numFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: SpColors.dangerSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                decoration: BoxDecoration(
                  color: SpColors.feltRail.withValues(alpha: 0.6),
                  border: Border.all(
                    color: SpColors.gold.withValues(alpha: 0.25),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isFullPix ? 'PIX COPIA E COLA' : 'CHAVE PIX',
                            style: const TextStyle(
                              fontFamily: SpTypography.uiFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: SpColors.gold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pixText,
                            maxLines: isFullPix ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: SpTypography.uiFamily,
                              fontSize: isFullPix ? 11 : 13,
                              color: SpColors.cream,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _copy(context, pixText),
                      icon: const Icon(Icons.copy, size: 18),
                      color: SpColors.gold,
                      tooltip: 'Copiar',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SpColors.muted,
                  side: BorderSide(
                    color: SpColors.cream.withValues(alpha: 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Fechar',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
