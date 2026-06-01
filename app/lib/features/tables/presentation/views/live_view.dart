import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/cubit/cubit.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';
import '../cubit/cubit.dart';
import '../utils/join_link.dart';
import '../widgets/rebuy_dialog.dart';

class LiveView extends StatelessWidget {
  const LiveView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LiveCubit>(
          create: (_) => appDI.get<LiveCubit>()..start(tableId),
        ),
        BlocProvider<PendingApprovalsCubit>(
          create: (_) => appDI.get<PendingApprovalsCubit>(),
        ),
      ],
      child: _LiveScaffold(tableId: tableId),
    );
  }
}

class _LiveScaffold extends StatefulWidget {
  const _LiveScaffold({required this.tableId});
  final String tableId;

  @override
  State<_LiveScaffold> createState() => _LiveScaffoldState();
}

class _LiveScaffoldState extends State<_LiveScaffold> {
  bool _hadPendingLeave = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: BlocConsumer<LiveCubit, LiveState>(
            listener: (context, state) {
              if (state is! LiveStateLoaded) return;
              final auth = context.read<AuthCubit>().state;
              final currentUserId =
                  auth is AuthAuthenticated ? auth.user.id : null;
              if (currentUserId == null) return;

              final myParticipation = state.table.participations
                  .where((p) => p.userId == currentUserId)
                  .firstOrNull;

              final hasPendingLeave = state.table.pendingRequests.any(
                (r) =>
                    r.requestedById == currentUserId &&
                    r.type == ActionType.leave,
              );

              if (_hadPendingLeave &&
                  !hasPendingLeave &&
                  myParticipation?.cashOut != null) {
                context.go(AppRoutes.home);
                return;
              }

              _hadPendingLeave = hasPendingLeave;
            },
            builder: (context, state) => switch (state) {
              LiveStateLoading() => const _Loading(),
              LiveStateError(:final failure) => _ErrorView(failure: failure),
              LiveStateLoaded(:final table) =>
                _LoadedBody(table: table, tableId: widget.tableId),
            },
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
          ],
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.table, required this.tableId});
  final PokerTable table;
  final String tableId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final currentUserId = auth is AuthAuthenticated ? auth.user.id : null;

    final participations = table.participations;
    final total = _sumAllBuyIns(participations);
    final rebuyCount = _rebuyCount(participations);
    final duration =
        _formatElapsed(DateTime.now().difference(table.createdAt));

    final myParticipation = currentUserId == null
        ? null
        : _firstWhereOrNull(
            participations,
            (p) => p.userId == currentUserId,
          );

    final isHost = currentUserId != null && currentUserId == table.ownerId;

    final myPendingRequests = currentUserId == null
        ? <ActionRequest>[]
        : table.pendingRequests
            .where((r) => r.requestedById == currentUserId)
            .toList();

    return Stack(
      children: [
        Column(
          children: [
            SpAppHeader(
              left: SpBackButton(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.home),
              ),
              title: table.name,
              subtitle: SpLiveLabel(text: 'ao vivo · $duration'),
              right: isHost
                  ? _HostActionsMenu(
                      table: table,
                      onShowInfo: () => _showTableInfoDialog(context, table),
                      onTransferred: () =>
                          context.read<LiveCubit>().refresh(),
                    )
                  : IconButton(
                      onPressed: () => _showTableInfoDialog(context, table),
                      color: SpColors.goldBright,
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'Informações da mesa',
                    ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                children: [
                  _PotCard(
                    total: total,
                    playerCount: participations.length,
                    rebuys: rebuyCount,
                  ),
                  if (isHost && table.needsReconciliation) ...[
                    const SizedBox(height: 18),
                    _ReconcileBanner(tableId: tableId, table: table),
                  ],
                  if (isHost && table.pendingRequests.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _PendingApprovalsSection(
                      requests: table.pendingRequests,
                      tableId: tableId,
                      onRefresh: () => context.read<LiveCubit>().refresh(),
                    ),
                  ],
                  if (!isHost && myPendingRequests.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _PlayerPendingBanner(requests: myPendingRequests),
                  ],
                  const SizedBox(height: 18),
                  if (participations.isEmpty)
                    const _EmptyParticipations()
                  else
                    for (final p in participations)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PlayerRow(
                          participation: p,
                          isOwner: p.userId == table.ownerId,
                          isCurrentUser: currentUserId != null &&
                              p.userId == currentUserId,
                          pendingRequest: table.pendingRequests
                              .where((r) => r.participationId == p.id)
                              .firstOrNull,
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _ActionBar(
            isHost: isHost,
            hasLeftTable:
                myParticipation != null && myParticipation.cashOut != null,
            hasPendingLeave: myPendingRequests.any(
              (r) => r.type.name == 'leave' || r.type.name == 'rejoin',
            ),
            onCashout: () => context.go(AppRoutes.cashout(tableId)),
            onClose: () => context.go(AppRoutes.closeTable(tableId)),
            onRebuy: myParticipation == null
                ? null
                : () => _handleRebuy(
                      context,
                      participationId: myParticipation.id,
                      minBuyIn: table.minBuyIn,
                      isHost: isHost,
                      mode: RebuyMode.rebuy,
                    ),
            onRejoin: myParticipation == null
                ? null
                : () => _handleRebuy(
                      context,
                      participationId: myParticipation.id,
                      minBuyIn: table.minBuyIn,
                      isHost: isHost,
                      mode: RebuyMode.rejoin,
                    ),
          ),
        ),
      ],
    );
  }

  static Decimal _sumAllBuyIns(List<TableParticipation> ps) {
    var total = Decimal.zero;
    for (final p in ps) {
      for (final b in p.buyIns) {
        total += b.amount;
      }
    }
    return total;
  }

  /// Rebuy = qualquer aporte além do primeiro de cada participação.
  static int _rebuyCount(List<TableParticipation> ps) {
    var count = 0;
    for (final p in ps) {
      if (p.buyIns.length > 1) count += p.buyIns.length - 1;
    }
    return count;
  }

  static String _formatElapsed(Duration d) {
    if (d.isNegative || d.inSeconds < 60) {
      final s = d.inSeconds.clamp(0, 59);
      return '${s}s';
    }
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}min';
    return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
  }

  static T? _firstWhereOrNull<T>(Iterable<T> it, bool Function(T) pred) {
    for (final e in it) {
      if (pred(e)) return e;
    }
    return null;
  }

  Future<void> _handleRebuy(
    BuildContext context, {
    required String participationId,
    required Decimal minBuyIn,
    required bool isHost,
    required RebuyMode mode,
  }) async {
    final liveCubit = context.read<LiveCubit>();
    final ok = await showRebuyDialog(
      context,
      participationId: participationId,
      minBuyIn: minBuyIn,
      isHost: isHost,
      mode: mode,
    );
    if (!ok) return;
    await liveCubit.refresh();
  }
}

class _EmptyParticipations extends StatelessWidget {
  const _EmptyParticipations();

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
        'Ainda ninguém entrou na mesa. Compartilhe o link.',
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

class _PotCard extends StatelessWidget {
  const _PotCard({
    required this.total,
    required this.playerCount,
    required this.rebuys,
  });
  final Decimal total;
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
                  brlFromDecimal(total),
                  style: const TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$playerCount ${playerCount == 1 ? 'jogador' : 'jogadores'} · '
                  '$rebuys ${rebuys == 1 ? 'rebuy' : 'rebuys'}',
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

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.participation,
    required this.isOwner,
    required this.isCurrentUser,
    this.pendingRequest,
  });
  final TableParticipation participation;
  final bool isOwner;
  final bool isCurrentUser;
  final ActionRequest? pendingRequest;

  @override
  Widget build(BuildContext context) {
    final firstBuyIn = _firstBuyIn(participation.buyIns);
    final rebuys = _rebuysOf(participation.buyIns);
    final rebuysSum = rebuys.fold<Decimal>(
      Decimal.zero,
      (acc, b) => acc + b.amount,
    );
    final total = (firstBuyIn?.amount ?? Decimal.zero) + rebuysSum;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? SpColors.gold.withValues(alpha: 0.1)
            : SpColors.feltRail.withValues(alpha: 0.45),
        border: Border.all(
          color: isCurrentUser
              ? SpColors.gold.withValues(alpha: 0.35)
              : SpColors.cream.withValues(alpha: 0.06),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SpAvatar(name: participation.userName, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        participation.userName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: SpTypography.uiFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: SpColors.cream,
                        ),
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 6),
                      const _RoleBadge(role: 'HOST'),
                    ],
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      const _RoleBadge(role: 'VOCÊ'),
                    ],
                    if (pendingRequest != null) ...[
                      const SizedBox(width: 6),
                      const _RoleBadge(role: 'PENDENTE', pending: true),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _secondary(firstBuyIn, rebuys, rebuysSum),
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
                brlFromDecimal(total),
                style: const TextStyle(
                  fontFamily: SpTypography.numFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SpColors.cream,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                participation.cashOut == null ? 'EM JOGO' : 'SAIU',
                style: TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: participation.cashOut == null
                      ? SpColors.goldDark
                      : SpColors.muted,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Buy-in inicial = o mais antigo (primeiro registrado).
  /// Backend não distingue inicial vs rebuy — só ordem cronológica.
  static BuyIn? _firstBuyIn(List<BuyIn> buyIns) {
    if (buyIns.isEmpty) return null;
    final sorted = [...buyIns]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted.first;
  }

  static List<BuyIn> _rebuysOf(List<BuyIn> all) {
    if (all.length <= 1) return const [];
    final sorted = [...all]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted.sublist(1);
  }

  static String _secondary(BuyIn? first, List<BuyIn> rebuys, Decimal sum) {
    if (first == null) return 'Sem aporte ainda';
    if (rebuys.isEmpty) return 'Entrou ${brlFromDecimal(first.amount)}';
    final label = rebuys.length == 1 ? 'rebuy' : 'rebuys';
    return 'Entrou ${brlFromDecimal(first.amount)} · '
        '${rebuys.length} $label (${brlFromDecimal(sum)})';
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, this.pending = false});
  final String role;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final isHost = role == 'HOST';
    final Color bg;
    final Color fg;
    if (pending) {
      bg = SpColors.goldDark.withValues(alpha: 0.25);
      fg = SpColors.goldDark;
    } else if (isHost) {
      bg = SpColors.gold.withValues(alpha: 0.25);
      fg = SpColors.goldBright;
    } else {
      bg = SpColors.success.withValues(alpha: 0.25);
      fg = SpColors.successSoft;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isHost,
    required this.hasLeftTable,
    required this.hasPendingLeave,
    required this.onCashout,
    required this.onClose,
    required this.onRebuy,
    required this.onRejoin,
  });
  final bool isHost;
  final bool hasLeftTable;

  /// `true` se há uma solicitação de saída/rejoin pendente de aprovação.
  final bool hasPendingLeave;

  final VoidCallback onCashout;
  final VoidCallback onClose;
  final VoidCallback? onRebuy;
  final VoidCallback? onRejoin;

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
      child: hasLeftTable
          ? SpGoldButton(
              label: hasPendingLeave
                  ? 'Aguardando aprovação...'
                  : 'Entrar novamente',
              onPressed: hasPendingLeave ? null : onRejoin,
              height: 52,
            )
          : Row(
              children: [
                Expanded(
                  child: SpGhostButton(label: '+ Rebuy', onPressed: onRebuy),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SpGhostButton(
                    label: 'Sair da mesa',
                    onPressed: hasPendingLeave ? null : onCashout,
                    color: SpColors.dangerSoft,
                    borderColor: SpColors.dangerSoft.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PendingApprovalsSection extends StatelessWidget {
  const _PendingApprovalsSection({
    required this.requests,
    required this.tableId,
    required this.onRefresh,
  });
  final List<ActionRequest> requests;
  final String tableId;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PendingApprovalsCubit, PendingApprovalsState>(
      listener: (context, state) {
        if (state is PendingApprovalsDone) {
          onRefresh();
          context.read<PendingApprovalsCubit>().reset();
        } else if (state is PendingApprovalsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: SpColors.danger,
              content: Text(_messageFor(state.failure)),
            ),
          );
          context.read<PendingApprovalsCubit>().reset();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SpColors.goldDark.withValues(alpha: 0.1),
          border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'APROVAÇÕES PENDENTES',
              style: TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: SpColors.gold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            BlocBuilder<PendingApprovalsCubit, PendingApprovalsState>(
              builder: (context, state) {
                return Column(
                  children: [
                    for (int i = 0; i < requests.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _ApprovalItem(
                        request: requests[i],
                        loading: state is PendingApprovalsLoading &&
                            state.requestId == requests[i].id,
                        disabled: state is PendingApprovalsLoading,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _messageFor(Failure failure) => switch (failure) {
        UnauthorizedFailure(:final message) =>
          message ?? 'Sem permissão para aprovar.',
        NotFoundFailure() => 'Solicitação não encontrada.',
        NetworkFailure() => 'Sem conexão com o servidor.',
        _ => 'Não foi possível processar a solicitação.',
      };
}

class _ApprovalItem extends StatelessWidget {
  const _ApprovalItem({
    required this.request,
    required this.loading,
    required this.disabled,
  });
  final ActionRequest request;
  final bool loading;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SpAvatar(name: request.requestedByName, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.requestedByName,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SpColors.cream,
                  ),
                ),
                Text(
                  request.amount != null
                      ? '${request.typeLabel} · ${brlFromDecimal(request.amount!)}'
                      : request.typeLabel,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 11,
                    color: SpColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: SpColors.goldBright,
              ),
            )
          else ...[
            _IconBtn(
              icon: Icons.close,
              color: SpColors.dangerSoft,
              onPressed: disabled
                  ? null
                  : () =>
                      context.read<PendingApprovalsCubit>().reject(request.id),
            ),
            const SizedBox(width: 6),
            _IconBtn(
              icon: Icons.check,
              color: SpColors.successSoft,
              onPressed: disabled
                  ? null
                  : () => context
                      .read<PendingApprovalsCubit>()
                      .approve(request.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: onPressed == null ? 0.1 : 0.15),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

class _ReconcileBanner extends StatelessWidget {
  const _ReconcileBanner({required this.tableId, required this.table});
  final String tableId;
  final PokerTable table;

  @override
  Widget build(BuildContext context) {
    final pot = table.totalBuyIn ?? Decimal.zero;
    final declared = table.totalCashOut ?? Decimal.zero;
    final diff = (declared - pot).abs();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(AppRoutes.checkTable(tableId)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SpColors.danger.withValues(alpha: 0.10),
            border: Border.all(color: SpColors.danger.withValues(alpha: 0.30)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: SpColors.dangerSoft, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saídas não batem com o pote',
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: SpColors.cream,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Diferença de ${brlFromDecimal(diff, decimals: 2)} — toque para conferir.',
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
              const Icon(Icons.chevron_right,
                  color: SpColors.dangerSoft, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerPendingBanner extends StatelessWidget {
  const _PlayerPendingBanner({required this.requests});
  final List<ActionRequest> requests;

  @override
  Widget build(BuildContext context) {
    final labels = requests.map((r) => r.typeLabel).join(', ');
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: SpColors.goldDark.withValues(alpha: 0.1),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: SpColors.goldBright,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aguardando aprovação do host',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SpColors.cream,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  labels,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 11,
                    color: SpColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showTableInfoDialog(BuildContext context, PokerTable table) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => _TableInfoDialog(table: table),
  );
}

class _TableInfoDialog extends StatelessWidget {
  const _TableInfoDialog({required this.table});
  final PokerTable table;

  @override
  Widget build(BuildContext context) {
    final code = shortTableCode(table.id);
    final url = buildJoinUrl(table.id, appDI.get<AppConfig>().webBaseUrl);

    return Dialog(
      backgroundColor: SpColors.feltDeep,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: SpColors.gold.withValues(alpha: 0.3)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DialogHeader(onClose: () => Navigator.of(context).pop()),
              const SizedBox(height: 6),
              Text(
                table.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: SpTypography.displayFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: SpColors.cream,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Buy-in mínimo R\$ ${table.minBuyIn}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 12,
                  color: SpColors.muted,
                ),
              ),
              const SizedBox(height: 18),
              _CompactQrCard(code: code, data: url),
              const SizedBox(height: 16),
              _InlineCopyLink(url: url),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'INFORMAÇÕES DA MESA',
          style: TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: SpColors.gold,
            letterSpacing: 1.5,
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close, size: 20),
          color: SpColors.cream,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

class _CompactQrCard extends StatelessWidget {
  const _CompactQrCard({required this.code, required this.data});
  final String code;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpColors.ivory,
        borderRadius: BorderRadius.circular(SpRadius.qr),
        border: Border.all(color: SpColors.gold, width: 3),
      ),
      child: Column(
        children: [
          Center(
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: SpColors.ivory,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: SpColors.feltDeep,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: SpColors.feltDeep,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'CÓDIGO DA MESA',
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: SpColors.goldDark,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            code,
            style: const TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: SpColors.feltDeep,
              letterSpacing: 3.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineCopyLink extends StatelessWidget {
  const _InlineCopyLink({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: url));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: SpColors.feltRail,
              behavior: SnackBarBehavior.floating,
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: SpColors.goldBright, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Link copiado',
                    style: TextStyle(
                      fontFamily: SpTypography.uiFamily,
                      color: SpColors.cream,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: SpColors.feltRail.withValues(alpha: 0.5),
            border: Border.all(color: SpColors.gold.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.link, color: SpColors.gold, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Copiar link',
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: SpColors.cream,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: SpTypography.numFamily,
                        fontSize: 10,
                        color: SpColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.content_copy,
                  color: SpColors.goldBright, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _HostActionsMenu extends StatelessWidget {
  const _HostActionsMenu({
    required this.table,
    required this.onShowInfo,
    required this.onTransferred,
  });

  final PokerTable table;
  final VoidCallback onShowInfo;
  final VoidCallback onTransferred;

  bool _isEligible(TableParticipation p) {
    return p.userId != table.ownerId &&
        p.cashOut == null &&
        p.leftAt == null;
  }

  @override
  Widget build(BuildContext context) {
    final eligible = table.participations.where(_isEligible).toList();
    return PopupMenuButton<String>(
      tooltip: 'Ações do host',
      color: SpColors.feltDeep,
      icon: const Icon(Icons.more_vert, color: SpColors.goldBright),
      onSelected: (value) async {
        if (value == 'info') {
          onShowInfo();
          return;
        }
        if (value != 'transfer_host') return;
        final selected = await showDialog<TableParticipation>(
          context: context,
          builder: (_) => _TransferHostDialog(eligible: eligible),
        );
        if (selected == null || !context.mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        try {
          await appDI.get<TransferHost>().call(
                tableId: table.id,
                newOwnerId: selected.userId,
              );
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Host transferido para ${selected.userName}',
              ),
            ),
          );
          onTransferred();
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text('Erro ao transferir host: $e')),
          );
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem<String>(
          value: 'info',
          child: Text(
            'Informações da mesa',
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              color: SpColors.cream,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'transfer_host',
          enabled: eligible.isNotEmpty,
          child: Text(
            'Transferir host',
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              color: eligible.isEmpty ? SpColors.muted : SpColors.cream,
            ),
          ),
        ),
      ],
    );
  }
}

class _TransferHostDialog extends StatelessWidget {
  const _TransferHostDialog({required this.eligible});

  final List<TableParticipation> eligible;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SpColors.feltDeep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: SpColors.gold.withValues(alpha: 0.3)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Transferir host',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: SpTypography.displayFamily,
                  fontSize: 20,
                  color: SpColors.goldBright,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Escolha o novo host. Só participantes ativos (sem cash-out) aparecem aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 12,
                  color: SpColors.muted,
                ),
              ),
              const SizedBox(height: 16),
              if (eligible.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Ninguém elegível no momento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: SpTypography.uiFamily,
                      fontSize: 13,
                      color: SpColors.cream,
                    ),
                  ),
                )
              else
                for (final p in eligible)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      p.userName,
                      style: const TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        color: SpColors.cream,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: SpColors.goldBright),
                    onTap: () => Navigator.of(context).pop(p),
                  ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    color: SpColors.muted,
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
