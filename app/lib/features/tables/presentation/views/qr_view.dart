import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/poker_table.dart';
import '../../domain/entities/table_participation.dart';
import '../cubit/qr_cubit.dart';
import '../utils/join_link.dart';

class QrView extends StatelessWidget {
  const QrView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QrCubit>(
      create: (_) => appDI.get<QrCubit>()..start(tableId),
      child: _QrScaffold(tableId: tableId),
    );
  }
}

class _QrScaffold extends StatelessWidget {
  const _QrScaffold({required this.tableId});
  final String tableId;

  String _createTableRoute(PokerTable? table) {
    if (table == null) return AppRoutes.createTable;
    return Uri(
      path: AppRoutes.createTable,
      queryParameters: {
        'name': table.name,
        'minBuyIn': table.minBuyIn.toString(),
        'tableId': tableId,
      },
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    final joinUrl = buildJoinUrl(tableId);
    final shortCode = shortTableCode(tableId);

    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Column(
            children: [
              BlocBuilder<QrCubit, QrState>(
                buildWhen: (p, c) => c is QrStateLoaded || p is QrStateLoaded,
                builder: (context, state) {
                  final table = state is QrStateLoaded ? state.table : null;
                  return SpAppHeader(
                    left: SpBackButton(
                      onPressed: () => context.go(_createTableRoute(table)),
                    ),
                    title: 'Convidar jogadores',
                  );
                },
              ),
              Expanded(
                child: BlocBuilder<QrCubit, QrState>(
                  builder: (context, state) {
                    final table = state is QrStateLoaded ? state.table : null;
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      children: [
                        _TitleAndMeta(table: table),
                        const SizedBox(height: 20),
                        _QrCard(code: shortCode, data: joinUrl),
                        const SizedBox(height: 18),
                        _CopyLinkButton(url: joinUrl),
                        const SizedBox(height: 20),
                        _WaitingPanel(state: state),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
                child: SpGoldButton(
                  label: 'Iniciar jogo',
                  onPressed: () => context.go(AppRoutes.live(tableId)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleAndMeta extends StatelessWidget {
  const _TitleAndMeta({required this.table});
  final PokerTable? table;

  @override
  Widget build(BuildContext context) {
    final title = table?.name ?? 'Sua mesa';
    final minBuyIn = table?.minBuyIn.toString() ?? '—';
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: SpTypography.displayFamily,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: SpColors.cream,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Buy-in mínimo R\$ $minBuyIn',
          style: const TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 12,
            color: SpColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.code, required this.data});
  final String code;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SpColors.ivory,
        borderRadius: BorderRadius.circular(SpRadius.qr),
        border: Border.all(color: SpColors.gold, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 50,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 220,
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
          const SizedBox(height: 14),
          const Text(
            'CÓDIGO DA MESA',
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: SpColors.goldDark,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            code,
            style: const TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: SpColors.feltDeep,
              letterSpacing: 4.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyLinkButton extends StatelessWidget {
  const _CopyLinkButton({required this.url});
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
                  Icon(
                    Icons.check_circle_outline,
                    color: SpColors.goldBright,
                    size: 18,
                  ),
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: SpColors.feltRail.withValues(alpha: 0.5),
            border: Border.all(color: SpColors.gold.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.link, color: SpColors.gold, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Copiar link',
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 14,
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
                        fontSize: 11,
                        color: SpColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.content_copy,
                color: SpColors.goldBright,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaitingPanel extends StatelessWidget {
  const _WaitingPanel({required this.state});
  final QrState state;

  @override
  Widget build(BuildContext context) {
    final participations = state is QrStateLoaded
        ? (state as QrStateLoaded).table.participations
        : const <TableParticipation>[];
    final count = participations.length;

    final label = switch (state) {
      QrStateLoading() => 'SINCRONIZANDO...',
      QrStateError() => 'SEM CONEXÃO COM A MESA',
      _ => 'AGUARDANDO · $count ${count == 1 ? 'ENTROU' : 'ENTRARAM'}',
    };
    final labelColor = state is QrStateError
        ? SpColors.dangerSoft
        : SpColors.gold;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiveDot(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _WaitingAvatars(participations: participations),
        ],
      ),
    );
  }
}

class _WaitingAvatars extends StatelessWidget {
  const _WaitingAvatars({required this.participations});
  final List<TableParticipation> participations;

  @override
  Widget build(BuildContext context) {
    if (participations.isEmpty) {
      return const Text(
        'Compartilhe o link para os convidados entrarem.',
        style: TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 12,
          color: SpColors.muted,
        ),
      );
    }
    final visible = participations.take(5).toList();
    final extra = participations.length - visible.length;
    return Row(
      children: [
        for (var i = 0; i < visible.length; i++)
          Transform.translate(
            offset: Offset(i * -8.0, 0),
            child: SpAvatar(name: visible[i].userName, size: 32),
          ),
        const SizedBox(width: 10),
        Text(
          extra > 0 ? '+ $extra' : visible.last.userName.split(' ').first,
          style: const TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 12,
            color: SpColors.muted,
          ),
        ),
      ],
    );
  }
}
