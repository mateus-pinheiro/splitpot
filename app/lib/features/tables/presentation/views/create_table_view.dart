import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/cubit.dart';

class CreateTableView extends StatelessWidget {
  const CreateTableView({
    this.initialName,
    this.initialMinBuyIn,
    super.key,
  });

  final String? initialName;
  final String? initialMinBuyIn;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateTableCubit>(
      create: (_) => appDI.get<CreateTableCubit>(),
      child: _CreateTableScaffold(
        initialName: initialName,
        initialMinBuyIn: initialMinBuyIn,
      ),
    );
  }
}

class _CreateTableScaffold extends StatelessWidget {
  const _CreateTableScaffold({
    this.initialName,
    this.initialMinBuyIn,
  });

  final String? initialName;
  final String? initialMinBuyIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: BlocListener<CreateTableCubit, CreateTableState>(
            listener: _onStateChange,
            child: Stack(
              children: [
                Column(
                  children: [
                    SpAppHeader(
                      left: SpBackButton(
                          onPressed: () => context.go(AppRoutes.home)),
                      title: 'Nova mesa',
                    ),
                    Expanded(
                      child: _CreateTableForm(
                        initialName: initialName,
                        initialMinBuyIn: initialMinBuyIn,
                      ),
                    ),
                  ],
                ),
                const _CreateTableLoadingOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onStateChange(BuildContext context, CreateTableState state) {
    switch (state) {
      case CreateTableCreated(:final tableId):
        // Buy-in (when host plays) is already wired into the create call,
        // so we always land on the QR sharing screen next.
        context.go(AppRoutes.qr(tableId));
      case CreateTableError(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SpColors.danger,
            content: Text(_messageFor(failure)),
          ),
        );
        context.read<CreateTableCubit>().reset();
      case CreateTableIdle():
      case CreateTableCreating():
        break;
    }
  }

  String _messageFor(Failure failure) {
    return switch (failure) {
      ValidationFailure(:final message) => message,
      UnauthorizedFailure(:final message) =>
        message ?? 'Sua sessão expirou. Entre novamente.',
      NotFoundFailure(:final message) =>
        message ?? 'Recurso não encontrado.',
      NetworkFailure() =>
        'Sem conexão com o servidor. Verifique sua internet e tente de novo.',
      UnexpectedFailure(:final message) =>
        message ?? 'Não foi possível criar a mesa. Tente novamente.',
      SignInCancelledFailure() => 'Ação cancelada.',
    };
  }
}

/// Camada translúcida sobre a tela inteira enquanto `creating` —
/// bloqueia interação com o form e sinaliza que a criação está em curso.
class _CreateTableLoadingOverlay extends StatelessWidget {
  const _CreateTableLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateTableCubit, CreateTableState>(
      buildWhen: (p, c) => (p is CreateTableCreating) != (c is CreateTableCreating),
      builder: (context, state) {
        if (state is! CreateTableCreating) return const SizedBox.shrink();
        return Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: ColoredBox(
              color: SpColors.feltDeep.withValues(alpha: 0.55),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: SpColors.goldBright,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Criando mesa...',
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: SpColors.cream,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CreateTableForm extends StatefulWidget {
  const _CreateTableForm({
    this.initialName,
    this.initialMinBuyIn,
  });

  final String? initialName;
  final String? initialMinBuyIn;

  @override
  State<_CreateTableForm> createState() => _CreateTableFormState();
}

class _CreateTableFormState extends State<_CreateTableForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _minController;
  late final TextEditingController _initialController;

  bool _willPlay = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _minController = TextEditingController(text: widget.initialMinBuyIn ?? '');
    _initialController = TextEditingController();
    // Rebuild on every keystroke so the CTA can flip enabled/disabled live.
    _nameController.addListener(_onFieldChanged);
    _minController.addListener(_onFieldChanged);
    _initialController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant _CreateTableForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextName = widget.initialName ?? '';
    if (oldWidget.initialName != widget.initialName &&
        _nameController.text != nextName) {
      _nameController.text = nextName;
    }

    final nextMin = widget.initialMinBuyIn ?? '';
    if (oldWidget.initialMinBuyIn != widget.initialMinBuyIn &&
        _minController.text != nextMin) {
      _minController.text = nextMin;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minController.dispose();
    _initialController.dispose();
    super.dispose();
  }

  Decimal? _parseAmount(String raw) {
    final trimmed = raw.trim().replaceAll(',', '.');
    if (trimmed.isEmpty) return null;
    return Decimal.tryParse(trimmed);
  }

  /// Validated input snapshot, or `null` if any required field is invalid.
  /// Drives both the CTA's enabled state and the submit payload — single
  /// source of truth keeps the button label and the API call in sync.
  _CreateTableInput? get _validInput {
    final name = _nameController.text.trim();
    if (name.isEmpty) return null;
    final min = _parseAmount(_minController.text);
    if (min == null || min <= Decimal.zero) return null;
    if (!_willPlay) {
      return _CreateTableInput(name: name, minBuyIn: min, initialBuyIn: null);
    }
    final initial = _parseAmount(_initialController.text);
    if (initial == null || initial <= Decimal.zero) return null;
    if (initial < min) return null;
    return _CreateTableInput(
      name: name,
      minBuyIn: min,
      initialBuyIn: initial,
    );
  }

  void _submit() {
    final input = _validInput;
    if (input == null) return;
    context.read<CreateTableCubit>().submit(
          name: input.name,
          minBuyIn: input.minBuyIn,
          joinAsPlayer: _willPlay,
          initialBuyIn: input.initialBuyIn,
        );
  }

  /// True when the user typed a buy-in that's below the table minimum —
  /// so we can show a hint nudging them to bump it up. Only relevant when
  /// both fields have been touched.
  bool _initialNeedsMinHint() {
    final min = _parseAmount(_minController.text);
    final initial = _parseAmount(_initialController.text);
    if (min == null || initial == null) return false;
    return initial < min;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateTableCubit, CreateTableState>(
      builder: (context, state) {
        final submitting = state is CreateTableCreating;
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                children: [
                  const SpFieldLabel('Nome da mesa'),
                  const SizedBox(height: 8),
                  SpInput(
                    controller: _nameController,
                    hintText: 'Sexta na casa do Léo',
                  ),
                  const SizedBox(height: 22),
                  const SpFieldLabel('Buy-in (R\$)'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InsetNumberField(
                          label: 'Mínimo',
                          controller: _minController,
                          hintText: '50',
                        ),
                      ),
                      // const SizedBox(width: 10),
                      // Expanded(
                      //   child: _InsetNumberField(
                      //     label: 'Máximo',
                      //     controller: _maxController,
                      //   ),
                      // ),
                    ],
                  ),
                  // const SizedBox(height: 8),
                  // _BuyInHelper(
                  //   min: _minController.text,
                  //   max: _maxController.text,
                  // ),
                  // const SizedBox(height: 22),
                  // const SpFieldLabel('Valor da ficha (small blind)'),
                  // const SizedBox(height: 10),
                  // Wrap(
                  //   spacing: 8,
                  //   runSpacing: 8,
                  //   children: [
                  //     for (var i = 0; i < _blinds.length; i++)
                  //       _BlindPill(
                  //         label: 'R\$ ${_blinds[i]}',
                  //         selected: i == _blindIndex,
                  //         onTap: () => setState(() => _blindIndex = i),
                  //       ),
                  //   ],
                  // ),
                  const SizedBox(height: 22),
                  _WillPlayToggle(
                    value: _willPlay,
                    onChanged: (v) => setState(() {
                      _willPlay = v;
                      if (!v) _initialController.clear();
                    }),
                  ),
                  if (_willPlay) ...[
                    const SizedBox(height: 14),
                    _InsetNumberField(
                      label: 'Seu buy-in',
                      controller: _initialController,
                      hintText: _minController.text.isEmpty
                          ? 'mínimo da mesa'
                          : _minController.text,
                    ),
                    if (_initialNeedsMinHint())
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Mínimo R\$ ${_minController.text}.',
                          style: const TextStyle(
                            fontFamily: SpTypography.uiFamily,
                            fontSize: 12,
                            color: SpColors.dangerSoft,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: SpGoldButton(
                label: 'Abrir mesa',
                loading: submitting,
                onPressed: (submitting || _validInput == null) ? null : _submit,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CreateTableInput {
  const _CreateTableInput({
    required this.name,
    required this.minBuyIn,
    required this.initialBuyIn,
  });
  final String name;
  final Decimal minBuyIn;
  final Decimal? initialBuyIn;
}

class _InsetNumberField extends StatelessWidget {
  const _InsetNumberField({
    required this.label,
    required this.controller,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SpInput(
          controller: controller,
          hintText: hintText,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          contentPadding: const EdgeInsets.fromLTRB(14, 22, 14, 10),
          style: const TextStyle(
            fontFamily: SpTypography.numFamily,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: SpColors.cream,
          ),
        ),
        Positioned(
          left: 14,
          top: 6,
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 10,
              color: SpColors.muted,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}

class _WillPlayToggle extends StatelessWidget {
  const _WillPlayToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.5),
        border: Border.all(color: SpColors.cream.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você também vai jogar',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: SpColors.cream,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Entra na mesa como jogador',
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 12,
                    color: SpColors.muted,
                  ),
                ),
              ],
            ),
          ),
          _GoldSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _GoldSwitch extends StatelessWidget {
  const _GoldSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: value
              ? SpColors.gold
              : SpColors.cream.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(3),
        alignment:
            value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
        ),
      ),
    );
  }
}
