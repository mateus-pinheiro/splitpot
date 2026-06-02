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
import '../../domain/entities/table_preview.dart';
import '../cubit/join_by_id_cubit.dart';

/// Tela que o convidado abre ao clicar no link compartilhado pelo host.
/// Carrega a mesa real pelo id e confirma entrada via `POST /participations`.
class JoinByIdView extends StatelessWidget {
  const JoinByIdView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoinByIdCubit>(
      create: (_) => appDI.get<JoinByIdCubit>()..load(tableId),
      child: _JoinByIdScaffold(tableId: tableId),
    );
  }
}

class _JoinByIdScaffold extends StatelessWidget {
  const _JoinByIdScaffold({required this.tableId});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: BlocListener<JoinByIdCubit, JoinByIdState>(
            listener: (context, state) {
              if (state is JoinByIdStateJoined) {
                context.go(AppRoutes.live(tableId));
              } else if (state is JoinByIdStateJoinError) {
                showSpToast(context, _messageFor(state.failure),
                    type: SpToastType.error);
              }
            },
            child: Column(
              children: [
                SpAppHeader(
                  left: SpBackButton(
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                  title: 'Entrar na mesa',
                ),
                Expanded(
                  child: BlocBuilder<JoinByIdCubit, JoinByIdState>(
                    builder: (context, state) => switch (state) {
                      JoinByIdStateLoading() => const _Loading(),
                      JoinByIdStateError(:final failure) =>
                        _LoadError(message: _messageFor(failure)),
                      JoinByIdStateReady(:final preview) =>
                        _ReadyBody(preview: preview, tableId: tableId),
                      JoinByIdStateJoining(:final preview) => _ReadyBody(
                          preview: preview,
                          tableId: tableId,
                          joining: true,
                        ),
                      JoinByIdStateJoinError(:final preview) =>
                        _ReadyBody(preview: preview, tableId: tableId),
                      JoinByIdStateJoined(:final preview) => _ReadyBody(
                          preview: preview,
                          tableId: tableId,
                          joining: true,
                        ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _messageFor(Failure failure) => switch (failure) {
        ValidationFailure(:final message) => message,
        UnauthorizedFailure(:final message) =>
          message ?? 'Sua sessão expirou. Entre novamente.',
        NotFoundFailure() => 'Mesa não encontrada.',
        NetworkFailure() => 'Sem conexão com o servidor.',
        UnexpectedFailure(:final message) =>
          message ?? 'Não foi possível entrar na mesa.',
        SignInCancelledFailure() => 'Ação cancelada.',
      };
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

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
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

class _ReadyBody extends StatefulWidget {
  const _ReadyBody({
    required this.preview,
    required this.tableId,
    this.joining = false,
  });
  final TablePreview preview;
  final String tableId;
  final bool joining;

  @override
  State<_ReadyBody> createState() => _ReadyBodyState();
}

class _ReadyBodyState extends State<_ReadyBody> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.preview.minBuyIn.toString(),
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Decimal? get _parsedAmount {
    final raw = _controller.text.replaceAll(',', '.').trim();
    if (raw.isEmpty) return null;
    return Decimal.tryParse(raw);
  }

  String? _validate() {
    final amount = _parsedAmount;
    if (amount == null) return 'Informe um valor válido.';
    if (amount < widget.preview.minBuyIn) {
      return 'Buy-in mínimo é R\$ ${widget.preview.minBuyIn}.';
    }
    return null;
  }

  void _submit() {
    final error = _validate();
    if (error != null) {
      showSpToast(context, error, type: SpToastType.error);
      return;
    }
    final authState = context.read<AuthCubit>().state;
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : '';
    context.read<JoinByIdCubit>().confirm(
          widget.tableId,
          buyInAmount: _parsedAmount!,
          currentUserId: currentUserId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final amount = _parsedAmount;
    final buttonLabel = amount != null
        ? 'Confirmar entrada · ${brlFromDecimal(amount)}'
        : 'Confirmar entrada';
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            children: [
              _TableInfoCard(preview: widget.preview),
              const SizedBox(height: 22),
              const SpFieldLabel('Seu aporte inicial'),
              const SizedBox(height: 10),
              _BuyInInput(controller: _controller),
              const SizedBox(height: 6),
              Text(
                'Mínimo R\$ ${widget.preview.minBuyIn}.',
                style: const TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: 12,
                  color: SpColors.muted,
                ),
              ),
              const SizedBox(height: 18),
              const _PixNotice(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
          child: SpGoldButton(
            label: buttonLabel,
            loading: widget.joining,
            onPressed: widget.joining ? null : _submit,
          ),
        ),
      ],
    );
  }
}

class _BuyInInput extends StatelessWidget {
  const _BuyInInput({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              cursorColor: SpColors.goldBright,
              style: const TextStyle(
                fontFamily: SpTypography.numFamily,
                fontSize: 38,
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

class _TableInfoCard extends StatelessWidget {
  const _TableInfoCard({required this.preview});
  final TablePreview preview;

  @override
  Widget build(BuildContext context) {
    final playersCount = preview.participantsCount;
    final shortCode =
        preview.id.substring(0, preview.id.length.clamp(0, 6)).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SpColors.feltRail.withValues(alpha: 0.6),
        border: Border.all(color: SpColors.gold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MESA $shortCode',
            style: const TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: SpColors.gold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            preview.name,
            style: const TextStyle(
              fontFamily: SpTypography.displayFamily,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: SpColors.cream,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Host · ${preview.ownerName}',
            style: const TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 12,
              color: SpColors.muted,
            ),
          ),
          const SizedBox(height: 14),
          const GoldDivider(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetaColumn(
                  label: 'Buy-in mín.',
                  value: 'R\$ ${preview.minBuyIn}',
                ),
              ),
              Expanded(
                child: _MetaColumn(
                  label: 'Na mesa',
                  value:
                      '$playersCount ${playersCount == 1 ? 'jogador' : 'jogadores'}',
                ),
              ),
            ],
          ),
        ],
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
              'Nenhum PIX é enviado agora — acertos só acontecem no fim da mesa.',
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
