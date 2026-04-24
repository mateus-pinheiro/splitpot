import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/create_table_cubit.dart';
import '../cubit/create_table_state.dart';

class CreateTableView extends StatelessWidget {
  const CreateTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateTableCubit>(
      create: (_) => appDI.get<CreateTableCubit>(),
      child: const _CreateTableScaffold(),
    );
  }
}

class _CreateTableScaffold extends StatelessWidget {
  const _CreateTableScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: BlocListener<CreateTableCubit, CreateTableState>(
            listener: _onStateChange,
            child: Column(
              children: [
                SpAppHeader(
                  left: SpBackButton(onPressed: () => context.go(AppRoutes.home)),
                  title: 'Nova mesa',
                ),
                const Expanded(child: _CreateTableForm()),
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
        context.go(AppRoutes.qr(tableId));
      case CreateTableError():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: SpColors.danger,
            content: Text('Não foi possível criar a mesa. Tente novamente.'),
          ),
        );
      case CreateTableIdle():
      case CreateTableCreating():
        break;
    }
  }
}

class _CreateTableForm extends StatefulWidget {
  const _CreateTableForm();

  @override
  State<_CreateTableForm> createState() => _CreateTableFormState();
}

class _CreateTableFormState extends State<_CreateTableForm> {
  final _nameController = TextEditingController(text: 'Sexta na casa do Léo');
  final _minController = TextEditingController(text: '50');
  final _maxController = TextEditingController(text: '200');

  static const _blinds = ['0,25', '0,50', '1,00', '2,00', '5,00'];
  int _blindIndex = 1;
  bool _willPlay = true;

  @override
  void dispose() {
    _nameController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final min = Decimal.tryParse(_minController.text.replaceAll(',', '.'));
    if (min == null || min <= Decimal.zero) return;
    context.read<CreateTableCubit>().submit(name: name, minBuyIn: min);
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
                  SpInput(controller: _nameController),
                  const SizedBox(height: 22),
                  const SpFieldLabel('Buy-in (R\$)'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InsetNumberField(
                          label: 'Mínimo',
                          controller: _minController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InsetNumberField(
                          label: 'Máximo',
                          controller: _maxController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _BuyInHelper(
                    min: _minController.text,
                    max: _maxController.text,
                  ),
                  const SizedBox(height: 22),
                  const SpFieldLabel('Valor da ficha (small blind)'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < _blinds.length; i++)
                        _BlindPill(
                          label: 'R\$ ${_blinds[i]}',
                          selected: i == _blindIndex,
                          onTap: () => setState(() => _blindIndex = i),
                        ),
                    ],
                  ),
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
  const _InsetNumberField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SpInput(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

class _BuyInHelper extends StatelessWidget {
  const _BuyInHelper({required this.min, required this.max});
  final String min;
  final String max;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 12,
          color: SpColors.muted,
          height: 1.4,
        ),
        children: [
          const TextSpan(text: 'Jogadores podem aportar qualquer valor entre '),
          TextSpan(
            text: 'R\$ $min',
            style: const TextStyle(color: SpColors.cream),
          ),
          const TextSpan(text: ' e '),
          TextSpan(
            text: 'R\$ $max',
            style: const TextStyle(color: SpColors.cream),
          ),
          const TextSpan(text: '. Rebuys são permitidos.'),
        ],
      ),
    );
  }
}

class _BlindPill extends StatelessWidget {
  const _BlindPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SpRadius.input),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? SpColors.gold.withValues(alpha: 0.18)
                : SpColors.feltRail.withValues(alpha: 0.5),
            border: Border.all(
              color: selected
                  ? SpColors.gold
                  : SpColors.cream.withValues(alpha: 0.12),
            ),
            borderRadius: BorderRadius.circular(SpRadius.input),
          ),
          child: Text(
            label,
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
