import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/router/app_routes.dart';

class JoinView extends StatefulWidget {
  const JoinView({super.key});

  @override
  State<JoinView> createState() => _JoinViewState();
}

class _JoinViewState extends State<JoinView> {
  double _amount = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Column(
            children: [
              SpAppHeader(
                left: SpBackButton(onPressed: () => context.go(AppRoutes.home)),
                title: 'Entrar na mesa',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  children: [
                    const _TableInfoCard(),
                    const SizedBox(height: 24),
                    const SpFieldLabel('Seu aporte inicial'),
                    const SizedBox(height: 12),
                    _AmountCard(
                      amount: _amount,
                      onChanged: (v) => setState(() => _amount = v),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final v in [50, 100, 150, 200]) ...[
                          if (v != 50) const SizedBox(width: 8),
                          Expanded(
                            child: _PresetButton(
                              value: v,
                              selected: _amount.toInt() == v,
                              onTap: () => setState(() => _amount = v.toDouble()),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _PixNotice(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
                child: SpGoldButton(
                  label: 'Confirmar entrada · R\$ ${_amount.toInt()}',
                  onPressed: () => context.go(AppRoutes.live('demo')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableInfoCard extends StatelessWidget {
  const _TableInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.6),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              child: Opacity(
                opacity: 0.25,
                child: SuitGlyph(
                  suit: Suit.spade,
                  size: 40,
                  color: SpColors.gold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MESA K7N-2QX',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: SpColors.gold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sexta na casa do Léo',
                  style: TextStyle(
                    fontFamily: SpTypography.displayFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: SpColors.cream,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    SpAvatar(name: 'Léo Castro', size: 26),
                    SizedBox(width: 8),
                    Text(
                      'Léo Castro ',
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 13,
                        color: SpColors.cream,
                      ),
                    ),
                    Text(
                      'é o host',
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 13,
                        color: SpColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const GoldDivider(),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    _MetaColumn(label: 'Buy-in', value: 'R\$ 50 – 200'),
                    SizedBox(width: 18),
                    _MetaColumn(label: 'Rebuy', value: 'Livre'),
                    SizedBox(width: 18),
                    _MetaColumn(label: 'Na mesa', value: '4 jogadores'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaColumn extends StatelessWidget {
  const _MetaColumn({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: SpTypography.numFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: SpColors.cream,
          ),
        ),
      ],
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.amount, required this.onChanged});
  final double amount;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'R\$',
                  style: TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: SpColors.goldBright,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                amount.toInt().toString(),
                style: const TextStyle(
                  fontFamily: SpTypography.numFamily,
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  color: SpColors.goldBright,
                  height: 1.0,
                  letterSpacing: -1.12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: SpColors.gold,
              inactiveTrackColor: SpColors.cream.withValues(alpha: 0.12),
              thumbColor: SpColors.goldBright,
              overlayColor: SpColors.gold.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: amount,
              min: 50,
              max: 200,
              divisions: 15,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'R\$ 50 (min)',
                  style: TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 11,
                    color: SpColors.muted,
                  ),
                ),
                Text(
                  'R\$ 200 (max)',
                  style: TextStyle(
                    fontFamily: SpTypography.numFamily,
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

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.value,
    required this.selected,
    required this.onTap,
  });
  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? SpColors.gold.withValues(alpha: 0.18)
                : SpColors.feltRail.withValues(alpha: 0.5),
            border: Border.all(
              color: selected
                  ? SpColors.gold
                  : SpColors.cream.withValues(alpha: 0.1),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'R\$ $value',
            style: TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? SpColors.goldBright : SpColors.cream,
            ),
          ),
        ),
      ),
    );
  }
}

class _PixNotice extends StatelessWidget {
  const _PixNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SpColors.gold.withValues(alpha: 0.06),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline, color: SpColors.gold, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este valor é apenas seu registro de entrada. Nenhum PIX é enviado agora — acertos acontecem no fim da mesa.',
              style: TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 12,
                color: SpColors.cream,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
