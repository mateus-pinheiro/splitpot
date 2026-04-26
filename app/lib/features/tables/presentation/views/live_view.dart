import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/buy_in.dart';
import '../../domain/entities/poker_table.dart';
import '../../domain/entities/table_participation.dart';
import '../cubit/live_cubit.dart';
import '../cubit/rebuy_cubit.dart';
import '../utils/join_link.dart';
import '../widgets/rebuy_dialog.dart';

class LiveView extends StatelessWidget {
  const LiveView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LiveCubit>(
      create: (_) => appDI.get<LiveCubit>()..start(tableId),
      child: _LiveScaffold(tableId: tableId),
    );
  }
}

class _LiveScaffold extends StatelessWidget {
  const _LiveScaffold({required this.tableId});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: BlocBuilder<LiveCubit, LiveState>(
            builder: (context, state) => switch (state) {
              LiveStateLoading() => const _Loading(),
              LiveStateError(:final failure) => _ErrorView(failure: failure),
              LiveStateLoaded(:final table) =>
                _LoadedBody(table: table, tableId: tableId),
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

    return Stack(
      children: [
        Column(
          children: [
            SpAppHeader(
              left: SpBackButton(
                onPressed: () => context.go(AppRoutes.home),
              ),
              title: table.name,
              subtitle: SpLiveLabel(text: 'ao vivo · $duration'),
              right: IconButton(
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
            onCashout: () => context.go(AppRoutes.cashout(tableId)),
            onClose: () => context.go(AppRoutes.closeTable(tableId)),
            onRebuy: myParticipation == null
                ? null
                : () => _handleRebuy(
                      context,
                      participationId: myParticipation.id,
                      minBuyIn: table.minBuyIn,
                      mode: RebuyMode.rebuy,
                    ),
            onRejoin: myParticipation == null
                ? null
                : () => _handleRebuy(
                      context,
                      participationId: myParticipation.id,
                      minBuyIn: table.minBuyIn,
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
    required RebuyMode mode,
  }) async {
    final liveCubit = context.read<LiveCubit>();
    final ok = await showRebuyDialog(
      context,
      participationId: participationId,
      minBuyIn: minBuyIn,
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
  });
  final TableParticipation participation;
  final bool isOwner;
  final bool isCurrentUser;

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
  const _ActionBar({
    required this.isHost,
    required this.hasLeftTable,
    required this.onCashout,
    required this.onClose,
    required this.onRebuy,
    required this.onRejoin,
  });
  final bool isHost;

  /// `true` se o participante atual já registrou cash-out — barra muda
  /// pra um único CTA "Entrar novamente".
  final bool hasLeftTable;

  final VoidCallback onCashout;
  final VoidCallback onClose;

  /// `null` se o usuário atual não é participant — desabilita o botão.
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
              label: 'Entrar novamente',
              onPressed: onRejoin,
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
                    onPressed: onCashout,
                    color: SpColors.dangerSoft,
                    borderColor: SpColors.dangerSoft.withValues(alpha: 0.4),
                  ),
                ),
                if (isHost) ...[
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
    final url = buildJoinUrl(table.id);

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
