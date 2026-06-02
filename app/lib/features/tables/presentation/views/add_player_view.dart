import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/user_summary.dart';
import '../cubit/add_player_cubit.dart';

/// Tela usada pelo host pra adicionar jogador na mesa. Dois modos exclusivos:
/// - **convidado** (sem conta): host digita nome + PIX
/// - **cadastrado**: host busca por nome/email e seleciona da lista
/// Em ambos os casos, o buy-in inicial é opcional.
class AddPlayerView extends StatelessWidget {
  const AddPlayerView({required this.tableId, super.key});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddPlayerCubit>(
      create: (_) => appDI.get<AddPlayerCubit>(),
      child: _AddPlayerScaffold(tableId: tableId),
    );
  }
}

enum _PlayerKind { guest, registered }

class _AddPlayerScaffold extends StatefulWidget {
  const _AddPlayerScaffold({required this.tableId});
  final String tableId;

  @override
  State<_AddPlayerScaffold> createState() => _AddPlayerScaffoldState();
}

class _AddPlayerScaffoldState extends State<_AddPlayerScaffold> {
  _PlayerKind _kind = _PlayerKind.guest;

  final _guestNameCtrl = TextEditingController();
  final _guestPixCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _buyInCtrl = TextEditingController();

  UserSummary? _selectedUser;

  @override
  void dispose() {
    _guestNameCtrl.dispose();
    _guestPixCtrl.dispose();
    _searchCtrl.dispose();
    _buyInCtrl.dispose();
    super.dispose();
  }

  Decimal? get _initialBuyIn {
    final raw = _buyInCtrl.text.replaceAll(',', '.').trim();
    if (raw.isEmpty) return null;
    return Decimal.tryParse(raw);
  }

  void _submit() {
    final cubit = context.read<AddPlayerCubit>();
    if (_kind == _PlayerKind.guest) {
      final name = _guestNameCtrl.text.trim();
      final pix = _guestPixCtrl.text.trim();
      if (name.isEmpty || pix.isEmpty) {
        _toast('Preencha nome e PIX do convidado.');
        return;
      }
      cubit.submitGuest(
        tableId: widget.tableId,
        name: name,
        pixKey: pix,
        initialBuyIn: _initialBuyIn,
      );
    } else {
      final user = _selectedUser;
      if (user == null) {
        _toast('Selecione um usuário cadastrado.');
        return;
      }
      cubit.submitRegistered(
        tableId: widget.tableId,
        userId: user.id,
        initialBuyIn: _initialBuyIn,
      );
    }
  }

  void _toast(String message) {
    showSpToast(context, message, type: SpToastType.error);
  }

  String _messageFor(Failure failure) => switch (failure) {
        ValidationFailure(:final message) => message,
        UnauthorizedFailure(:final message) =>
          message ?? 'Sua sessão expirou. Entre novamente.',
        NotFoundFailure() => 'Mesa ou usuário não encontrado.',
        NetworkFailure() => 'Sem conexão com o servidor.',
        UnexpectedFailure(:final message) =>
          message ?? 'Não foi possível adicionar o jogador.',
        SignInCancelledFailure() => 'Ação cancelada.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: BlocConsumer<AddPlayerCubit, AddPlayerState>(
            listener: (context, state) {
              if (state is AddPlayerAdded) {
                showSpToast(context, 'Jogador adicionado!',
                    type: SpToastType.success);
                context.go(AppRoutes.live(widget.tableId));
              } else if (state is AddPlayerError) {
                _toast(_messageFor(state.failure));
              }
            },
            builder: (context, state) {
              final submitting = state is AddPlayerSubmitting;
              return Column(
                children: [
                  SpAppHeader(
                    left: SpBackButton(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go(AppRoutes.live(widget.tableId)),
                    ),
                    title: 'Adicionar jogador',
                  ),
                  Expanded(
                    child: ListView(
                      padding:
                          const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      children: [
                        _KindToggle(
                          kind: _kind,
                          onChanged: submitting
                              ? null
                              : (k) {
                                  setState(() {
                                    _kind = k;
                                    _selectedUser = null;
                                  });
                                  context.read<AddPlayerCubit>().reset();
                                },
                        ),
                        const SizedBox(height: 20),
                        if (_kind == _PlayerKind.guest)
                          _GuestForm(
                            nameCtrl: _guestNameCtrl,
                            pixCtrl: _guestPixCtrl,
                          )
                        else
                          _RegisteredForm(
                            searchCtrl: _searchCtrl,
                            selectedUser: _selectedUser,
                            state: state,
                            onSearch: (q) =>
                                context.read<AddPlayerCubit>().search(q),
                            onSelect: (u) {
                              setState(() => _selectedUser = u);
                              _searchCtrl.text = u.name;
                              context.read<AddPlayerCubit>().reset();
                            },
                            onClearSelection: () {
                              setState(() => _selectedUser = null);
                              _searchCtrl.clear();
                            },
                          ),
                        const SizedBox(height: 20),
                        const SpFieldLabel('Buy-in inicial (opcional)'),
                        const SizedBox(height: 6),
                        SpInput(
                          controller: _buyInCtrl,
                          hintText: 'Ex.: 100,00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d.,]'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: SpGoldButton(
                      label: 'Adicionar jogador',
                      loading: submitting,
                      onPressed: submitting ? null : _submit,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _KindToggle extends StatelessWidget {
  const _KindToggle({required this.kind, required this.onChanged});

  final _PlayerKind kind;
  final ValueChanged<_PlayerKind>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_PlayerKind>(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? SpColors.gold.withValues(alpha: 0.25)
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.all(SpColors.cream),
        side: WidgetStateProperty.all(
          BorderSide(color: SpColors.gold.withValues(alpha: 0.4)),
        ),
      ),
      segments: const [
        ButtonSegment(
          value: _PlayerKind.guest,
          label: Text('Convidado'),
          icon: Icon(Icons.person_add_alt_1),
        ),
        ButtonSegment(
          value: _PlayerKind.registered,
          label: Text('Cadastrado'),
          icon: Icon(Icons.search),
        ),
      ],
      selected: {kind},
      onSelectionChanged:
          onChanged == null ? null : (s) => onChanged!(s.first),
    );
  }
}

class _GuestForm extends StatelessWidget {
  const _GuestForm({required this.nameCtrl, required this.pixCtrl});

  final TextEditingController nameCtrl;
  final TextEditingController pixCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SpFieldLabel('Nome do convidado'),
        const SizedBox(height: 6),
        SpInput(controller: nameCtrl, hintText: 'Ex.: Bruno'),
        const SizedBox(height: 16),
        const SpFieldLabel('PIX do convidado'),
        const SizedBox(height: 6),
        SpInput(
          controller: pixCtrl,
          hintText: 'CPF, email, celular ou aleatória',
        ),
        const SizedBox(height: 6),
        const Text(
          'O PIX fica gravado nesta mesa. Após o fechamento, vai pros settlements.',
          style: TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 11,
            color: SpColors.muted,
          ),
        ),
      ],
    );
  }
}

class _RegisteredForm extends StatelessWidget {
  const _RegisteredForm({
    required this.searchCtrl,
    required this.selectedUser,
    required this.state,
    required this.onSearch,
    required this.onSelect,
    required this.onClearSelection,
  });

  final TextEditingController searchCtrl;
  final UserSummary? selectedUser;
  final AddPlayerState state;
  final ValueChanged<String> onSearch;
  final ValueChanged<UserSummary> onSelect;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SpFieldLabel('Buscar por nome ou email'),
        const SizedBox(height: 6),
        SpInput(
          controller: searchCtrl,
          hintText: 'Digite pelo menos 2 caracteres',
          onChanged: (q) {
            if (selectedUser != null) onClearSelection();
            onSearch(q);
          },
        ),
        if (selectedUser != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: SpColors.feltRail.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SpColors.gold.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: SpColors.goldBright, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedUser!.name,
                        style: const TextStyle(
                          fontFamily: SpTypography.uiFamily,
                          color: SpColors.cream,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        selectedUser!.email,
                        style: const TextStyle(
                          fontFamily: SpTypography.uiFamily,
                          color: SpColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClearSelection,
                  icon: const Icon(Icons.close, color: SpColors.muted),
                  tooltip: 'Trocar usuário',
                ),
              ],
            ),
          ),
        ] else
          _SearchResults(state: state, onSelect: onSelect),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.state, required this.onSelect});

  final AddPlayerState state;
  final ValueChanged<UserSummary> onSelect;

  @override
  Widget build(BuildContext context) {
    if (state is AddPlayerSearching) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: SpColors.goldBright,
            ),
          ),
        ),
      );
    }
    if (state is AddPlayerSearchResults) {
      final results = (state as AddPlayerSearchResults).results;
      if (results.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Nenhum usuário encontrado.',
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              color: SpColors.muted,
              fontSize: 13,
            ),
          ),
        );
      }
      return Column(
        children: [
          for (final u in results)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                u.name,
                style: const TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  color: SpColors.cream,
                ),
              ),
              subtitle: Text(
                u.email,
                style: const TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  color: SpColors.muted,
                  fontSize: 11,
                ),
              ),
              trailing: const Icon(Icons.add, color: SpColors.goldBright),
              onTap: () => onSelect(u),
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
