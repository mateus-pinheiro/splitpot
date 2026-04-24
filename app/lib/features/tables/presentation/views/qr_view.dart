import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/router/app_routes.dart';

class QrView extends StatelessWidget {
  const QrView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    const code = 'K7N-2QX';
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Column(
            children: [
              SpAppHeader(
                left: SpBackButton(onPressed: () => context.pop()),
                title: 'Convidar jogadores',
                right: TextButton(
                  onPressed: () => context.go(AppRoutes.live(tableId)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Pular',
                    style: TextStyle(
                      fontFamily: SpTypography.uiFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: SpColors.goldBright,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  children: const [
                    Text(
                      'Sexta na casa do Léo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: SpTypography.displayFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: SpColors.cream,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    _MetaRow(),
                    SizedBox(height: 20),
                    _QrCard(code: code, data: 'https://splitpot.app/join/$code'),
                    SizedBox(height: 18),
                    _ShareRow(),
                    SizedBox(height: 20),
                    _WaitingPanel(),
                  ],
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

class _MetaRow extends StatelessWidget {
  const _MetaRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Buy-in R\$ 50 – 200',
          style: TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 12,
            color: SpColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 14),
        Text('•', style: TextStyle(color: SpColors.goldDark)),
        SizedBox(width: 14),
        Text(
          'Blinds 0,25 / 0,50',
          style: TextStyle(
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
              embeddedImage: null,
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

class _ShareRow extends StatelessWidget {
  const _ShareRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'WhatsApp', icon: Icons.chat, color: const Color(0xFF25D366)),
      (label: 'Copiar link', icon: Icons.link, color: SpColors.gold),
      (label: 'Compartilhar', icon: Icons.ios_share, color: SpColors.cream),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _ShareButton(
              label: items[i].label,
              icon: items[i].icon,
              color: items[i].color,
            ),
          ),
        ],
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.label,
    required this.icon,
    required this.color,
  });
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: SpColors.feltRail.withValues(alpha: 0.5),
            border: Border.all(color: SpColors.cream.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 12,
                  color: SpColors.cream,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaitingPanel extends StatelessWidget {
  const _WaitingPanel();

  @override
  Widget build(BuildContext context) {
    const names = ['Rafael Monteiro', 'Léo Castro', 'Amanda S.'];
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
            children: const [
              LiveDot(),
              SizedBox(width: 10),
              Text(
                'AGUARDANDO · 2 ENTRARAM',
                style: TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: SpColors.gold,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < names.length; i++)
                Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 0),
                  child: Transform.translate(
                    offset: Offset(i * -8.0, 0),
                    child: SpAvatar(name: names[i], size: 32),
                  ),
                ),
              const SizedBox(width: 10),
              const Text(
                'Você + 2',
                style: TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 12,
                  color: SpColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
