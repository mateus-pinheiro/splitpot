import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/cubit/cubit.dart';
import '../../domain/entities/entities.dart';
import '../cubit/check_table_cubit.dart';

/// "Conferir saídas" — tela exclusiva do host quando as cash-outs da mesa
/// não batem com o pote. Reproduz fielmente o design-handoff (ver
/// `design_system/ScreenReconcile.jsx`).
class CheckTableView extends StatelessWidget {
  const CheckTableView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthCubit>().state;
    final currentUserId = auth is AuthAuthenticated ? auth.user.id : null;

    if (currentUserId == null) {
      return const _ChromeMessage(
        title: 'Você precisa estar logado',
        message: 'Faça login para conferir esta mesa.',
      );
    }

    return BlocProvider<CheckTableCubit>(
      create: (_) =>
          appDI.get<CheckTableCubit>()..load(tableId, currentUserId),
      child: _CheckScaffold(tableId: tableId),
    );
  }
}

class _CheckScaffold extends StatelessWidget {
  const _CheckScaffold({required this.tableId});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: BlocConsumer<CheckTableCubit, CheckTableState>(
            listener: (context, state) {
              if (state is CheckClosed) {
                context.go(AppRoutes.tableDetail(tableId));
              }
            },
            builder: (context, state) => switch (state) {
              CheckLoading() => _ChromeColumn(
                  tableId: tableId,
                  body: const Center(child: SpLoader()),
                ),
              CheckError(:final failure) => _ChromeColumn(
                  tableId: tableId,
                  body: _Errored(failure: failure),
                ),
              CheckForbidden() => _ChromeColumn(
                  tableId: tableId,
                  body: const _Forbidden(),
                ),
              CheckAlreadyClosed() => _ChromeColumn(
                  tableId: tableId,
                  body: const _AlreadyClosed(),
                ),
              CheckReady() => _ReadyBody(state: state, tableId: tableId),
              CheckClosed() => _ChromeColumn(
                  tableId: tableId,
                  body: const Center(child: SpLoader()),
                ),
            },
          ),
        ),
      ),
    );
  }
}

// ─── Chrome (header + body wrapper) ──────────────────────────────────────

class _ChromeColumn extends StatelessWidget {
  const _ChromeColumn({required this.tableId, required this.body});
  final String tableId;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SpAppHeader(
          left: SpBackButton(
            onPressed: () => context.go(AppRoutes.live(tableId)),
          ),
          title: 'Conferir saídas',
          subtitle: const Text(
            'ANTES DE FECHAR',
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 11,
              color: SpColors.muted,
              letterSpacing: 0.55,
            ),
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _ChromeMessage extends StatelessWidget {
  const _ChromeMessage({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: SpTypography.uiFamily,
                      fontSize: 16,
                      color: SpColors.cream,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: SpTypography.uiFamily,
                      fontSize: 13,
                      color: SpColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Errored extends StatelessWidget {
  const _Errored({required this.failure});
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

class _Forbidden extends StatelessWidget {
  const _Forbidden();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: SpColors.gold, size: 36),
            SizedBox(height: 12),
            Text(
              'Apenas o host pode conferir esta mesa.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 14,
                color: SpColors.cream,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Aguarde o anfitrião fechar a mesa.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 12,
                color: SpColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlreadyClosed extends StatelessWidget {
  const _AlreadyClosed();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Esta mesa já está fechada.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 14,
            color: SpColors.cream,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Loaded body ─────────────────────────────────────────────────────────

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({required this.state, required this.tableId});
  final CheckReady state;
  final String tableId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckTableCubit>();
    final table = state.table;
    final active =
        table.participations.where((p) => p.leftAt == null).toList();

    final pot = _pot(active);
    final declared = _declared(state.outs);
    // diff > 0  → "Falta declarar" (cashouts < pot).
    // diff < 0  → "Sobra nas saídas" (cashouts > pot).
    final diff = pot - declared;
    final absDiff = diff.abs();
    final balanced = diff == Decimal.zero;
    final canClose = state.method == ReconcileMethod.edit ? balanced : true;
    final last = _lastCashOutParticipation(table);

    return Stack(
      children: [
        Column(
          children: [
            SpAppHeader(
              left: SpBackButton(
                onPressed: () => context.go(AppRoutes.live(tableId)),
              ),
              title: 'Conferir saídas',
              subtitle: const Text(
                'ANTES DE FECHAR',
                style: TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 11,
                  color: SpColors.muted,
                  letterSpacing: 0.55,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
                children: [
                  _AlertBanner(lastPlayerName: last?.userName),
                  const SizedBox(height: 14),
                  _BalanceHero(
                    pot: pot,
                    declared: declared,
                    diff: diff,
                    balanced: balanced,
                  ),
                  const SizedBox(height: 22),
                  _MethodPicker(
                    selected: state.method,
                    n: active.length,
                    absDiff: absDiff,
                    onSelect: cubit.selectMethod,
                  ),
                  const SizedBox(height: 20),
                  if (state.method == ReconcileMethod.edit)
                    _EditPanel(
                      active: active,
                      outs: state.outs,
                      lastParticipationId: last?.id,
                      balanced: balanced,
                      lastPlayerName: last?.userName,
                      onChange: cubit.editOut,
                      onQuickFix: cubit.quickFixLastPlayer,
                    )
                  else if (state.method == ReconcileMethod.split)
                    _SplitPanel(
                      active: active,
                      outs: state.outs,
                      absDiff: absDiff,
                      diff: diff,
                      balanced: balanced,
                      n: active.length,
                    )
                  else
                    _HostPanel(
                      active: active,
                      outs: state.outs,
                      table: table,
                      absDiff: absDiff,
                      diff: diff,
                      balanced: balanced,
                    ),
                  if (state.submitError != null) ...[
                    const SizedBox(height: 16),
                    _SubmitErrorBox(failure: state.submitError!),
                  ],
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _StickyFooter(
            method: state.method,
            balanced: balanced,
            absDiff: absDiff,
            canClose: canClose,
            submitting: state.submitting,
            onClose: canClose && !state.submitting ? cubit.closeNow : null,
          ),
        ),
      ],
    );
  }

  static Decimal _pot(List<TableParticipation> active) {
    var sum = Decimal.zero;
    for (final p in active) {
      for (final b in p.buyIns) {
        sum += b.amount;
      }
    }
    return sum;
  }

  static Decimal _declared(Map<String, Decimal> outs) {
    return outs.values.fold<Decimal>(Decimal.zero, (a, b) => a + b);
  }

  static TableParticipation? _lastCashOutParticipation(PokerTable table) {
    TableParticipation? last;
    DateTime? lastAt;
    for (final p in table.participations.where((p) => p.leftAt == null)) {
      final co = p.cashOut;
      if (co == null) continue;
      if (lastAt == null || co.createdAt.isAfter(lastAt)) {
        last = p;
        lastAt = co.createdAt;
      }
    }
    return last;
  }
}

// ─── Alert banner ────────────────────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.lastPlayerName});
  final String? lastPlayerName;

  @override
  Widget build(BuildContext context) {
    final name = lastPlayerName ?? 'O último jogador';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SpColors.danger.withValues(alpha: 0.10),
        border: Border.all(color: SpColors.danger.withValues(alpha: 0.30)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.warning_amber_rounded,
                color: SpColors.dangerSoft, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 12.5,
                  color: SpColors.cream,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text:
                        ' foi a última a sair e fechou a mesa, mas as saídas '
                        'não batem com o pote. Escolha como resolver para '
                        'fechar.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Balance hero ────────────────────────────────────────────────────────

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({
    required this.pot,
    required this.declared,
    required this.diff,
    required this.balanced,
  });

  final Decimal pot;
  final Decimal declared;
  final Decimal diff;
  final bool balanced;

  @override
  Widget build(BuildContext context) {
    final diffColor =
        balanced ? SpColors.successSoft : SpColors.dangerSoft;
    final diffBg = balanced
        ? SpColors.success.withValues(alpha: 0.12)
        : SpColors.danger.withValues(alpha: 0.12);
    final diffBd = balanced
        ? SpColors.success.withValues(alpha: 0.4)
        : SpColors.danger.withValues(alpha: 0.4);

    final declaredColor =
        balanced ? SpColors.cream : const Color(0xFFE9B3B0);

    final progress = pot == Decimal.zero
        ? 0.0
        : (declared.toDouble() / pot.toDouble()).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.55),
        border: Border.all(color: diffBd),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _MoneyColumn(
                    eyebrow: 'TOTAL EM JOGO',
                    value: brlFromDecimal(pot),
                    caption: 'pote (aportes + rebuys)',
                    valueColor: SpColors.cream,
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: SpColors.cream.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: _MoneyColumn(
                    eyebrow: 'SAÍDAS DECLARADAS',
                    value: brlFromDecimal(declared),
                    caption: 'soma dos valores',
                    valueColor: declaredColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 6,
              color: SpColors.feltRail.withValues(alpha: 0.8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  heightFactor: 1.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: balanced
                            ? const [Color(0xFF2E8F5A), Color(0xFF6BC997)]
                            : const [Color(0xFFA3322A), Color(0xFFE57373)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: diffBg,
              border: Border.all(color: diffBd),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  balanced
                      ? '✓ As contas batem'
                      : diff > Decimal.zero
                          ? 'Falta declarar'
                          : 'Sobra nas saídas',
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 12.5,
                    color: SpColors.cream,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  balanced
                      ? brlFromDecimal(Decimal.zero)
                      : (diff > Decimal.zero ? '−' : '+') +
                          brlFromDecimal(diff.abs()),
                  style: TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: diffColor,
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

class _MoneyColumn extends StatelessWidget {
  const _MoneyColumn({
    required this.eyebrow,
    required this.value,
    required this.caption,
    required this.valueColor,
  });

  final String eyebrow;
  final String value;
  final String caption;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: SpColors.gold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: SpTypography.numFamily,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          caption,
          style: const TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 10.5,
            color: SpColors.muted,
          ),
        ),
      ],
    );
  }
}

// ─── Method picker ───────────────────────────────────────────────────────

class _MethodPicker extends StatelessWidget {
  const _MethodPicker({
    required this.selected,
    required this.n,
    required this.absDiff,
    required this.onSelect,
  });

  final ReconcileMethod selected;
  final int n;
  final Decimal absDiff;
  final ValueChanged<ReconcileMethod> onSelect;

  @override
  Widget build(BuildContext context) {
    final perHead = n == 0
        ? Decimal.zero
        : (absDiff / Decimal.fromInt(n)).toDecimal(scaleOnInfinitePrecision: 2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMO RESOLVER A DIFERENÇA?',
          style: TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: SpColors.gold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        _MethodOption(
          selected: selected == ReconcileMethod.edit,
          icon: Icons.edit_outlined,
          title: 'Editar saídas',
          subtitle: 'Corrigir um valor digitado errado',
          onTap: () => onSelect(ReconcileMethod.edit),
        ),
        const SizedBox(height: 8),
        _MethodOption(
          selected: selected == ReconcileMethod.split,
          icon: Icons.group_outlined,
          title: 'Dividir entre todos',
          subtitle: 'Cada jogador absorve ${brlFromDecimal(perHead)}',
          onTap: () => onSelect(ReconcileMethod.split),
        ),
        const SizedBox(height: 8),
        _MethodOption(
          selected: selected == ReconcileMethod.host,
          icon: Icons.shield_outlined,
          title: 'Assumir como host',
          subtitle: 'Você cobre ${brlFromDecimal(absDiff)} via PIX',
          onTap: () => onSelect(ReconcileMethod.host),
        ),
      ],
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: selected
                ? SpColors.gold.withValues(alpha: 0.12)
                : SpColors.feltRail.withValues(alpha: 0.45),
            border: Border.all(
              color: selected
                  ? SpColors.gold
                  : SpColors.cream.withValues(alpha: 0.08),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? SpColors.gold.withValues(alpha: 0.2)
                      : SpColors.cream.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected ? SpColors.goldBright : SpColors.muted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SpColors.cream,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
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
              _Radio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? SpColors.gold : Colors.transparent,
        border: selected
            ? null
            : Border.all(
                color: SpColors.cream.withValues(alpha: 0.25),
                width: 1.5,
              ),
      ),
      child: selected
          ? const Icon(Icons.check, color: Color(0xFF2A1D08), size: 13)
          : null,
    );
  }
}

// ─── Edit panel ──────────────────────────────────────────────────────────

class _EditPanel extends StatelessWidget {
  const _EditPanel({
    required this.active,
    required this.outs,
    required this.lastParticipationId,
    required this.balanced,
    required this.lastPlayerName,
    required this.onChange,
    required this.onQuickFix,
  });

  final List<TableParticipation> active;
  final Map<String, Decimal> outs;
  final String? lastParticipationId;
  final bool balanced;
  final String? lastPlayerName;
  final void Function(String participationId, Decimal amount) onChange;
  final VoidCallback onQuickFix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SAÍDAS DOS JOGADORES',
          style: TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: SpColors.gold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Toque em um valor para corrigir.',
          style: TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 12,
            color: SpColors.muted,
          ),
        ),
        const SizedBox(height: 10),
        for (final p in active) ...[
          _EditableRow(
            participation: p,
            currentOut: outs[p.id] ?? Decimal.zero,
            isLast: p.id == lastParticipationId,
            onChange: (v) => onChange(p.id, v),
          ),
          const SizedBox(height: 8),
        ],
        if (!balanced)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _QuickFixButton(
              label: lastPlayerName == null
                  ? 'Corrigir último jogador para fechar a conta'
                  : 'Corrigir ${_firstName(lastPlayerName!)} para fechar a conta',
              onPressed: onQuickFix,
            ),
          ),
      ],
    );
  }

  static String _firstName(String full) => full.split(' ').first;
}

class _EditableRow extends StatefulWidget {
  const _EditableRow({
    required this.participation,
    required this.currentOut,
    required this.isLast,
    required this.onChange,
  });

  final TableParticipation participation;
  final Decimal currentOut;
  final bool isLast;
  final ValueChanged<Decimal> onChange;

  @override
  State<_EditableRow> createState() => _EditableRowState();
}

class _EditableRowState extends State<_EditableRow> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _format(widget.currentOut));
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _EditableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync external changes (e.g. quick-fix button) without nuking the
    // caret while the user is actively typing.
    if (!_focus.hasFocus && widget.currentOut != oldWidget.currentOut) {
      _ctrl.text = _format(widget.currentOut);
    }
  }

  void _onFocusChange() {
    setState(() => _editing = _focus.hasFocus);
    if (!_focus.hasFocus) {
      // Snap field text to the parsed value so "12." normalizes to "12".
      _ctrl.text = _format(widget.currentOut);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.participation;
    final invested = p.buyIns.fold<Decimal>(
      Decimal.zero,
      (acc, b) => acc + b.amount,
    );
    final pl = widget.currentOut - invested;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isLast
            ? SpColors.gold.withValues(alpha: 0.08)
            : SpColors.feltRail.withValues(alpha: 0.45),
        border: Border.all(
          color: widget.isLast
              ? SpColors.gold.withValues(alpha: 0.4)
              : SpColors.cream.withValues(alpha: 0.07),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SpAvatar(name: p.userName, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        p.userName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: SpTypography.uiFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: SpColors.cream,
                        ),
                      ),
                    ),
                    if (widget.isLast) ...[
                      const SizedBox(width: 6),
                      const _Tag(label: 'FECHOU A MESA'),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'entrou ${brlFromDecimal(invested)} · '
                  '${pl >= Decimal.zero ? '+' : ''}${brlFromDecimal(pl)}',
                  style: const TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 11,
                    color: SpColors.muted,
                  ),
                ),
              ],
            ),
          ),
          _OutInput(
            controller: _ctrl,
            focusNode: _focus,
            editing: _editing,
            onChanged: (v) {
              final parsed = _parse(v);
              if (parsed != null) widget.onChange(parsed);
            },
          ),
        ],
      ),
    );
  }

  static String _format(Decimal d) {
    if (d == Decimal.zero) return '0';
    return d.toString();
  }

  static Decimal? _parse(String raw) {
    if (raw.isEmpty) return Decimal.zero;
    return Decimal.tryParse(raw);
  }
}

class _OutInput extends StatelessWidget {
  const _OutInput({
    required this.controller,
    required this.focusNode,
    required this.editing,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool editing;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: editing
            ? SpColors.feltRail.withValues(alpha: 0.75)
            : SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(
          color: editing
              ? SpColors.gold
              : SpColors.gold.withValues(alpha: 0.25),
        ),
        borderRadius: BorderRadius.circular(9),
        boxShadow: editing
            ? [
                BoxShadow(
                  color: SpColors.gold.withValues(alpha: 0.15),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Text(
            'R\$',
            style: TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 12,
              color: SpColors.muted,
            ),
          ),
          const SizedBox(width: 3),
          SizedBox(
            width: 56,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: SpTypography.numFamily,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: SpColors.cream,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: SpColors.gold.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          color: SpColors.goldBright,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _QuickFixButton extends StatelessWidget {
  const _QuickFixButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: SpColors.gold.withValues(alpha: 0.1),
            border: Border.all(
              color: SpColors.gold.withValues(alpha: 0.45),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh,
                  color: SpColors.goldBright, size: 15),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: SpColors.goldBright,
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

// ─── Split panel ─────────────────────────────────────────────────────────

class _SplitPanel extends StatelessWidget {
  const _SplitPanel({
    required this.active,
    required this.outs,
    required this.absDiff,
    required this.diff,
    required this.balanced,
    required this.n,
  });

  final List<TableParticipation> active;
  final Map<String, Decimal> outs;
  final Decimal absDiff;
  final Decimal diff;
  final bool balanced;
  final int n;

  @override
  Widget build(BuildContext context) {
    // `diff = pot - declared`. Surplus → diff < 0 → each cash-out drops by
    // |diff|/n so players collectively absorb the missing chips. Shortfall
    // → diff > 0 → each cash-out gains diff/n. Either way the per-player
    // cash-out adjustment equals `diff/n` (same sign as the diff).
    final adjustment = n == 0
        ? Decimal.zero
        : (diff / Decimal.fromInt(n)).toDecimal(scaleOnInfinitePrecision: 2);
    final perHead = n == 0
        ? Decimal.zero
        : (absDiff / Decimal.fromInt(n))
            .toDecimal(scaleOnInfinitePrecision: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExplainerText.rich(
          balanced
              ? const TextSpan(
                  text: 'As contas já batem — nenhum ajuste necessário.',
                )
              : TextSpan(children: [
                  const TextSpan(text: 'O excedente de '),
                  TextSpan(
                    text: brlFromDecimal(absDiff),
                    style: const TextStyle(
                      color: SpColors.goldBright,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' é dividido igualmente. Cada um dos jogadores absorve ',
                  ),
                  TextSpan(
                    text: brlFromDecimal(perHead),
                    style: const TextStyle(
                      color: SpColors.goldBright,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' no resultado.'),
                ]),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: SpColors.feltRail.withValues(alpha: 0.5),
            border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (var i = 0; i < active.length; i++) ...[
                _BeforeAfterRow(
                  name: active[i].userName,
                  before: (outs[active[i].id] ?? Decimal.zero) -
                      _invested(active[i]),
                  after: (outs[active[i].id] ?? Decimal.zero) +
                      adjustment -
                      _invested(active[i]),
                ),
                if (i < active.length - 1)
                  Divider(
                    height: 1,
                    color: SpColors.cream.withValues(alpha: 0.06),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: SpColors.success.withValues(alpha: 0.12),
            border: Border.all(
              color: SpColors.success.withValues(alpha: 0.35),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.check,
                  color: SpColors.successSoft, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Contas zeradas após o rateio. Todos pagam/recebem o '
                  'valor ajustado.',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 12,
                    color: SpColors.successSoft.withValues(alpha: 0.95),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Decimal _invested(TableParticipation p) {
    return p.buyIns.fold<Decimal>(Decimal.zero, (acc, b) => acc + b.amount);
  }
}

class _BeforeAfterRow extends StatelessWidget {
  const _BeforeAfterRow({
    required this.name,
    required this.before,
    required this.after,
  });

  final String name;
  final Decimal before;
  final Decimal after;

  @override
  Widget build(BuildContext context) {
    final firstName = name.split(' ').first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          SpAvatar(name: name, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              firstName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: SpColors.cream,
              ),
            ),
          ),
          Text(
            '${before >= Decimal.zero ? '+' : ''}${brlFromDecimal(before)}',
            style: const TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 12,
              color: SpColors.muted,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: SpColors.goldDark, size: 16),
          const SizedBox(width: 8),
          Text(
            '${after >= Decimal.zero ? '+' : ''}${brlFromDecimal(after)}',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: SpTypography.numFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: after >= Decimal.zero
                  ? SpColors.successSoft
                  : SpColors.dangerSoft,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Host panel ──────────────────────────────────────────────────────────

class _HostPanel extends StatelessWidget {
  const _HostPanel({
    required this.active,
    required this.outs,
    required this.table,
    required this.absDiff,
    required this.diff,
    required this.balanced,
  });

  final List<TableParticipation> active;
  final Map<String, Decimal> outs;
  final PokerTable table;
  final Decimal absDiff;
  final Decimal diff;
  final bool balanced;

  @override
  Widget build(BuildContext context) {
    final hostParticipation =
        active.where((p) => p.userId == table.ownerId).firstOrNull;
    final hostName = hostParticipation?.userName ?? 'Host';

    Decimal? hostBefore;
    Decimal? hostAfter;
    if (hostParticipation != null) {
      final invested = hostParticipation.buyIns.fold<Decimal>(
        Decimal.zero,
        (acc, b) => acc + b.amount,
      );
      final out = outs[hostParticipation.id] ?? Decimal.zero;
      hostBefore = out - invested;
      // `diff = pot - declared`. Host adjusts their cash-out by `diff` so
      // the books balance — surplus (diff < 0) shrinks the host's cash-out,
      // shortfall (diff > 0) grows it. Their net result moves the same way.
      hostAfter = hostBefore + diff;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExplainerText.rich(
          balanced
              ? const TextSpan(text: 'As contas já batem — nada a cobrir.')
              : TextSpan(children: [
                  const TextSpan(text: 'Você assume o excedente de '),
                  TextSpan(
                    text: brlFromDecimal(absDiff),
                    style: const TextStyle(
                      color: SpColors.goldBright,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text:
                        '. Os demais recebem o valor cheio; a diferença sai '
                        'de uma transferência PIX sua.',
                  ),
                ]),
        ),
        const SizedBox(height: 12),
        if (hostParticipation == null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: SpColors.danger.withValues(alpha: 0.1),
              border: Border.all(
                color: SpColors.danger.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Você não está jogando nesta mesa — só "Dividir entre todos" '
              'funciona para fechar.',
              style: TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 12.5,
                color: SpColors.cream,
              ),
            ),
          )
        else ...[
          _HostTransferCard(hostName: hostName, absDiff: absDiff),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: SpColors.feltRail.withValues(alpha: 0.5),
              border: Border.all(
                color: SpColors.cream.withValues(alpha: 0.08),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text(
                  'Seu resultado',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: SpColors.cream,
                  ),
                ),
                const Spacer(),
                Text(
                  '${hostBefore! >= Decimal.zero ? '+' : ''}${brlFromDecimal(hostBefore)}',
                  style: const TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 13,
                    color: SpColors.muted,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward,
                    color: SpColors.goldDark, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${hostAfter! >= Decimal.zero ? '+' : ''}${brlFromDecimal(hostAfter)}',
                  style: TextStyle(
                    fontFamily: SpTypography.numFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: hostAfter >= Decimal.zero
                        ? SpColors.successSoft
                        : SpColors.dangerSoft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Os demais jogadores não são afetados.',
              style: TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 11.5,
                color: SpColors.muted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HostTransferCard extends StatelessWidget {
  const _HostTransferCard({required this.hostName, required this.absDiff});
  final String hostName;
  final Decimal absDiff;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SpColors.gold.withValues(alpha: 0.08),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SpAvatar(name: hostName, size: 34),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              SpColors.gold.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: SpColors.gold.withValues(alpha: 0.2),
                        border: Border.all(
                          color: SpColors.gold.withValues(alpha: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        brlFromDecimal(absDiff),
                        style: const TextStyle(
                          fontFamily: SpTypography.numFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: SpColors.goldBright,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              SpColors.gold.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SpColors.gold.withValues(alpha: 0.18),
                  border: Border.all(
                    color: SpColors.gold.withValues(alpha: 0.4),
                  ),
                ),
                child: const Center(
                  child: PokerChipStack(
                    count: 1,
                    color: SpColors.gold,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Você ',
                        style: TextStyle(
                          fontFamily: SpTypography.uiFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: SpColors.cream,
                        ),
                      ),
                      TextSpan(
                        text: '(host)',
                        style: TextStyle(
                          fontFamily: SpTypography.uiFamily,
                          fontSize: 12,
                          color: SpColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Text(
                'ajuste do caixa',
                style: TextStyle(
                  fontFamily: SpTypography.numFamily,
                  fontSize: 11,
                  color: SpColors.muted,
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Caixa da mesa',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SpColors.cream,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Sticky footer + helpers ─────────────────────────────────────────────

class _StickyFooter extends StatelessWidget {
  const _StickyFooter({
    required this.method,
    required this.balanced,
    required this.absDiff,
    required this.canClose,
    required this.submitting,
    required this.onClose,
  });

  final ReconcileMethod method;
  final bool balanced;
  final Decimal absDiff;
  final bool canClose;
  final bool submitting;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final label = switch (method) {
      ReconcileMethod.edit =>
        balanced ? 'Fechar mesa' : 'Contas precisam bater',
      ReconcileMethod.split => 'Dividir e fechar mesa',
      ReconcileMethod.host => 'Assumir e fechar mesa',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SpColors.feltDeep.withValues(alpha: 0),
            SpColors.feltDeep.withValues(alpha: 0.92),
          ],
          stops: const [0.0, 0.35],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (method == ReconcileMethod.edit && !balanced)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Ajuste as saídas — diferença de ${brlFromDecimal(absDiff)} '
                'para fechar.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 11.5,
                  color: Color(0xFFE9B3B0),
                ),
              ),
            ),
          if (canClose)
            SpGoldButton(
              label: label,
              onPressed: onClose,
              loading: submitting,
            )
          else
            _DisabledCtaButton(label: label),
        ],
      ),
    );
  }
}

class _DisabledCtaButton extends StatelessWidget {
  const _DisabledCtaButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: SpColors.muted,
        ),
      ),
    );
  }
}

class _ExplainerText extends StatelessWidget {
  const _ExplainerText.rich(this.span);
  final InlineSpan span;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      span,
      style: const TextStyle(
        fontFamily: SpTypography.uiFamily,
        fontSize: 12.5,
        color: SpColors.cream,
        height: 1.5,
      ),
    );
  }
}

class _SubmitErrorBox extends StatelessWidget {
  const _SubmitErrorBox({required this.failure});
  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final message = switch (failure) {
      UnauthorizedFailure(:final message) =>
        message ?? 'Sem permissão para fechar a mesa.',
      NotFoundFailure() => 'Mesa não encontrada.',
      NetworkFailure() => 'Sem conexão com o servidor.',
      ValidationFailure(:final message) => message,
      _ => 'Não foi possível fechar a mesa.',
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SpColors.danger.withValues(alpha: 0.10),
        border: Border.all(color: SpColors.danger.withValues(alpha: 0.30)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: SpColors.dangerSoft, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 12.5,
                color: SpColors.cream,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
