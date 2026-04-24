import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state is AuthAuthenticated ? state.user : null;
              return _HomeScaffold(user: user);
            },
          ),
        ),
      ),
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
          titleWidget: const SpLogo(size: 18),
          right: const _BellIcon(),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        const _HeroCreateCard(),
        const SizedBox(height: 14),
        const _JoinByCodeRow(),
        const SizedBox(height: 28),
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
                onPressed: () => context.go(AppRoutes.history),
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
        const Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'P&L total',
                value: '+R\$ 842',
                sub: 'em 12 mesas',
                valueColor: SpColors.success,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Taxa de vitória',
                value: '58%',
                sub: '7 de 12 mesas',
                valueColor: Color(0xFF222222),
              ),
            ),
          ],
        ),
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
        for (final t in _recents)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _RecentTableRow(table: t),
          ),
      ],
    );
  }

  static const _recents = <_RecentTable>[
    _RecentTable(date: 'Ontem', name: 'Sexta na casa do Léo', players: 7, pl: 340),
    _RecentTable(date: '12 abr', name: 'Mesa do escritório', players: 5, pl: -120),
    _RecentTable(
        date: '05 abr', name: 'Aniversário do Caio', players: 6, pl: 622, host: true),
  ];
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
                child: PokerChipStack(
                  size: 90,
                  color: SpColors.gold,
                  count: 3,
                ),
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
                  trailing: const Icon(Icons.arrow_forward,
                      size: 14, color: Color(0xFF2A1D08)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinByCodeRow extends StatelessWidget {
  const _JoinByCodeRow();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go(AppRoutes.joinTable),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: SpColors.feltRail.withValues(alpha: 0.55),
            border:
                Border.all(color: SpColors.cream.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: SpColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.qr_code_2,
                  color: SpColors.goldBright,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entrar com código',
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: SpColors.cream,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Escaneie o QR ou digite o ID',
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 12,
                        color: SpColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: SpColors.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String sub;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5).withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(SpRadius.hero),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4)),
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
          Text(
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

class _RecentTable {
  const _RecentTable({
    required this.date,
    required this.name,
    required this.players,
    required this.pl,
    this.host = false,
  });
  final String date;
  final String name;
  final int players;
  final int pl;
  final bool host;
}

class _RecentTableRow extends StatelessWidget {
  const _RecentTableRow({required this.table});
  final _RecentTable table;

  @override
  Widget build(BuildContext context) {
    final parts = table.date.split(' ');
    final top = parts.length == 2 ? parts[1].toUpperCase() : parts[0].substring(0, 3).toUpperCase();
    final bottom = parts.length == 2 ? parts[0] : null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: SpColors.feltRail.withValues(alpha: 0.45),
            border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: SpColors.gold.withValues(alpha: 0.12),
                  border: Border.all(
                      color: SpColors.gold.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      top,
                      style: const TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: SpColors.gold,
                        letterSpacing: 1.0,
                        height: 1.0,
                      ),
                    ),
                    if (bottom != null)
                      Text(
                        bottom,
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
              ),
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
                        if (table.host)
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
                      '${table.players} jogadores',
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
                (table.pl >= 0 ? '+' : '') + brl(table.pl),
                style: TextStyle(
                  fontFamily: SpTypography.numFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color:
                      table.pl >= 0 ? SpColors.success : SpColors.dangerSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BellIcon extends StatelessWidget {
  const _BellIcon();
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: const Icon(Icons.notifications_none),
      color: SpColors.goldBright,
      splashRadius: 20,
    );
  }
}
