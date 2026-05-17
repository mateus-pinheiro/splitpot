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
    this.initialTableId,
    this.returnTo,
    super.key,
  });

  final String? initialName;
  final String? initialMinBuyIn;
  final String? initialTableId;
  final String? returnTo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateTableCubit>(
      create: (_) => appDI.get<CreateTableCubit>(),
      child: _CreateTableScaffold(
        initialName: initialName,
        initialMinBuyIn: initialMinBuyIn,
        initialTableId: initialTableId,
        returnTo: returnTo,
      ),
    );
  }
}

class _CreateTableScaffold extends StatelessWidget {
  const _CreateTableScaffold({
    this.initialName,
    this.initialMinBuyIn,
    this.initialTableId,
    this.returnTo,
  });

  final String? initialName;
  final String? initialMinBuyIn;
  final String? initialTableId;
  final String? returnTo;

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
                        initialTableId: initialTableId,
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
      case CreateTableCreated(:final tableId, :final joinedAsPlayer):
        if (joinedAsPlayer) {
          context.go(AppRoutes.initialBuyIn(tableId));
        } else if (returnTo == 'initialBuyIn') {
          context.go(AppRoutes.qr(tableId));
        } else {
          context.go(AppRoutes.qr(tableId));
        }
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
    this.initialTableId,
  });

  final String? initialName;
  final String? initialMinBuyIn;
  final String? initialTableId;

  @override
  State<_CreateTableForm> createState() => _CreateTableFormState();
}

class _CreateTableFormState extends State<_CreateTableForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _minController;

  bool _willPlay = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _minController = TextEditingController(text: widget.initialMinBuyIn ?? '');
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
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showValidationError('Dê um nome para a mesa.');
      return;
    }
    final minText = _minController.text.trim();
    if (minText.isEmpty) {
      _showValidationError('Informe o buy-in mínimo.');
      return;
    }
    final min = Decimal.tryParse(minText.replaceAll(',', '.'));
    if (min == null || min <= Decimal.zero) {
      _showValidationError('Informe um buy-in mínimo maior que zero.');
      return;
    }
    context.read<CreateTableCubit>().submit(
          name: name,
          minBuyIn: min,
          joinAsPlayer: _willPlay,
          tableId: widget.initialTableId,
        );
  }

  void _showValidationError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SpColors.danger,
        content: Text(msg),
      ),
    );
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
                    onChanged: (v) => setState(() => _willPlay = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: SpGoldButton(
                label: 'Abrir mesa',
                loading: submitting,
                onPressed: submitting ? null : _submit,
              ),
            ),
          ],
        );
      },
    );
  }
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
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
