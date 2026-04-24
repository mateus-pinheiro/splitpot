import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/router/app_routes.dart';

class CashoutView extends StatefulWidget {
  const CashoutView({required this.tableId, super.key});
  final String tableId;

  @override
  State<CashoutView> createState() => _CashoutViewState();
}

class _CashoutViewState extends State<CashoutView> {
  final _controller = TextEditingController(text: '238');
  final _invested = 150;

  int get _stack => int.tryParse(_controller.text) ?? 0;
  int get _pl => _stack - _invested;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pl = _pl;
    final positive = pl >= 0;
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Column(
            children: [
              SpAppHeader(
                left: SpBackButton(
                  onPressed: () => context.go(AppRoutes.live(widget.tableId)),
                ),
                title: 'Sair da mesa',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  children: [
                    const Text(
                      'Com quanto você\nestá saindo?',
                      style: TextStyle(
                        fontFamily: SpTypography.displayFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: SpColors.cream,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Conte suas fichas e informe o valor final. Se estiver zerado, informe R\$ 0.',
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 13,
                        color: SpColors.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _InvestedSummary(invested: _invested),
                    const SizedBox(height: 20),
                    const SpFieldLabel('Valor em fichas ao sair'),
                    const SizedBox(height: 10),
                    _StackInput(controller: _controller),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickPill(
                            label: 'Zerado',
                            dangerous: true,
                            onTap: () => _controller.text = '0',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickPill(
                            label: 'Empate',
                            dangerous: false,
                            onTap: () =>
                                _controller.text = _invested.toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _PnlPreview(pl: pl, positive: positive),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
                child: SpGoldButton(
                  label: 'Confirmar saída',
                  onPressed: () => context.go(AppRoutes.live(widget.tableId)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvestedSummary extends StatelessWidget {
  const _InvestedSummary({required this.invested});
  final int invested;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _Row(label: 'Aporte inicial', value: brl(invested), subtle: true),
          const SizedBox(height: 8),
          const _Row(label: 'Rebuys (0)', value: 'R\$ 0', subtle: true),
          const SizedBox(height: 12),
          const GoldDivider(),
          const SizedBox(height: 12),
          _Row(
            label: 'Total investido',
            value: brl(invested),
            valueStyle: const TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SpColors.goldBright,
            ),
            labelStyle: const TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: SpColors.cream,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.subtle = false,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final bool subtle;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ??
              TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 12,
                color: subtle ? SpColors.muted : SpColors.cream,
              ),
        ),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
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

class _StackInput extends StatelessWidget {
  const _StackInput({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.6),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Text(
            'R\$',
            style: TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: SpColors.muted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              cursorColor: SpColors.goldBright,
              style: const TextStyle(
                fontFamily: SpTypography.numFamily,
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: SpColors.cream,
                height: 1.0,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPill extends StatelessWidget {
  const _QuickPill({
    required this.label,
    required this.dangerous,
    required this.onTap,
  });
  final String label;
  final bool dangerous;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = dangerous ? SpColors.dangerSoft : SpColors.cream;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dangerous
                ? SpColors.danger.withValues(alpha: 0.12)
                : SpColors.cream.withValues(alpha: 0.08),
            border: Border.all(
              color: dangerous
                  ? SpColors.danger.withValues(alpha: 0.3)
                  : SpColors.cream.withValues(alpha: 0.15),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _PnlPreview extends StatelessWidget {
  const _PnlPreview({required this.pl, required this.positive});
  final int pl;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final bg = positive
        ? SpColors.success.withValues(alpha: 0.1)
        : SpColors.danger.withValues(alpha: 0.1);
    final border = positive
        ? SpColors.success.withValues(alpha: 0.3)
        : SpColors.danger.withValues(alpha: 0.3);
    final label = pl == 0
        ? 'Empate zero'
        : positive
            ? 'Você vai receber'
            : 'Você vai pagar';
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RESULTADO',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: SpColors.goldDark,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 13,
                    color: SpColors.cream,
                  ),
                ),
              ],
            ),
          ),
          Text(
            (pl >= 0 ? '+' : '') + brl(pl),
            style: TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color:
                  positive ? SpColors.successSoft : SpColors.dangerSoft,
            ),
          ),
        ],
      ),
    );
  }
}
