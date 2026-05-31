import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/tables_repository.dart';
import '../../domain/usecases/close_table.dart';
import '../../domain/usecases/get_table.dart';
import '../../domain/usecases/reconcile_and_close.dart';
import '../../domain/usecases/set_cash_out.dart';

/// Como o host vai resolver a diferença entre buy-ins e cash-outs:
/// editar valores manualmente, dividir entre todos, ou assumir como host.
enum ReconcileMethod { edit, split, host }

/// Estado da tela "Conferir saídas". Edits dos cash-outs ficam locais até
/// o host bater "Fechar"; só então persistimos as alterações no servidor
/// e, dependendo do `method`, chamamos `close` ou `reconcile-and-close`.
sealed class CheckTableState {
  const CheckTableState();
}

class CheckLoading extends CheckTableState {
  const CheckLoading();
}

class CheckError extends CheckTableState {
  const CheckError(this.failure);
  final Failure failure;
}

class CheckForbidden extends CheckTableState {
  const CheckForbidden();
}

class CheckAlreadyClosed extends CheckTableState {
  const CheckAlreadyClosed();
}

class CheckReady extends CheckTableState {
  const CheckReady({
    required this.table,
    required this.outs,
    required this.method,
    this.submitting = false,
    this.submitError,
  });

  final PokerTable table;

  /// `participationId → cash-out editado`. Inicializado com o valor do
  /// servidor; o usuário pode editar localmente sem persistir.
  final Map<String, Decimal> outs;
  final ReconcileMethod method;
  final bool submitting;
  final Failure? submitError;

  CheckReady copyWith({
    PokerTable? table,
    Map<String, Decimal>? outs,
    ReconcileMethod? method,
    bool? submitting,
    Failure? submitError,
    bool clearError = false,
  }) {
    return CheckReady(
      table: table ?? this.table,
      outs: outs ?? this.outs,
      method: method ?? this.method,
      submitting: submitting ?? this.submitting,
      submitError: clearError ? null : submitError ?? this.submitError,
    );
  }
}

class CheckClosed extends CheckTableState {
  const CheckClosed(this.result);
  final CloseTableResult result;
}

class CheckTableCubit extends Cubit<CheckTableState> {
  CheckTableCubit({
    required GetTable getTable,
    required SetCashOut setCashOut,
    required CloseTable closeTable,
    required ReconcileAndClose reconcileAndClose,
  })  : _getTable = getTable,
        _setCashOut = setCashOut,
        _closeTable = closeTable,
        _reconcileAndClose = reconcileAndClose,
        super(const CheckLoading());

  final GetTable _getTable;
  final SetCashOut _setCashOut;
  final CloseTable _closeTable;
  final ReconcileAndClose _reconcileAndClose;

  Future<void> load(String tableId, String currentUserId) async {
    emit(const CheckLoading());
    try {
      final table = await _getTable(tableId);
      if (table.ownerId != currentUserId) {
        emit(const CheckForbidden());
        return;
      }
      if (table.status != TableStatus.open) {
        emit(const CheckAlreadyClosed());
        return;
      }
      emit(CheckReady(
        table: table,
        outs: _initialOuts(table),
        method: ReconcileMethod.edit,
      ));
    } on ApiException catch (e) {
      emit(CheckError(e.failure));
    }
  }

  void selectMethod(ReconcileMethod method) {
    final s = state;
    if (s is! CheckReady) return;
    emit(s.copyWith(method: method, clearError: true));
  }

  void editOut(String participationId, Decimal amount) {
    final s = state;
    if (s is! CheckReady) return;
    final next = Map<String, Decimal>.from(s.outs);
    next[participationId] = amount;
    emit(s.copyWith(outs: next, clearError: true));
  }

  /// Atalho do botão "Corrigir [último jogador] para fechar a conta": joga
  /// a diferença inteira no cash-out do jogador que fechou a mesa, então
  /// as contas batem em um toque.
  void quickFixLastPlayer() {
    final s = state;
    if (s is! CheckReady) return;
    final last = _lastCashOutParticipation(s.table);
    if (last == null) return;
    final pot = _activePot(s.table);
    final othersDeclared = s.outs.entries
        .where((e) => e.key != last.id)
        .fold<Decimal>(Decimal.zero, (acc, e) => acc + e.value);
    editOut(last.id, pot - othersDeclared);
  }

  /// Persiste as edições locais e fecha. Se `method === edit` chama
  /// `close`; caso contrário, chama `reconcile-and-close` com a estratégia
  /// correspondente. Edits são empurrados antes em qualquer caso — eles
  /// reduzem a diferença que o split/host vai absorver.
  Future<void> closeNow() async {
    final s = state;
    if (s is! CheckReady) return;

    emit(s.copyWith(submitting: true, clearError: true));
    try {
      await _pushPendingEdits(s);

      final CloseTableResult result;
      switch (s.method) {
        case ReconcileMethod.edit:
          result = await _closeTable(s.table.id);
        case ReconcileMethod.split:
          result = await _reconcileAndClose(
            s.table.id,
            ReconcileStrategy.splitEvenly,
          );
        case ReconcileMethod.host:
          result = await _reconcileAndClose(
            s.table.id,
            ReconcileStrategy.hostAbsorb,
          );
      }
      emit(CheckClosed(result));
    } on ApiException catch (e) {
      emit(s.copyWith(submitting: false, submitError: e.failure));
    }
  }

  Future<void> _pushPendingEdits(CheckReady s) async {
    for (final p in s.table.participations.where((p) => p.leftAt == null)) {
      final newAmount = s.outs[p.id];
      if (newAmount == null) continue;
      final current = p.cashOut?.amount;
      if (current == null || current != newAmount) {
        await _setCashOut(participationId: p.id, amount: newAmount);
      }
    }
  }

  static Map<String, Decimal> _initialOuts(PokerTable table) {
    final out = <String, Decimal>{};
    for (final p in table.participations.where((p) => p.leftAt == null)) {
      out[p.id] = p.cashOut?.amount ?? Decimal.zero;
    }
    return out;
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

  static Decimal _activePot(PokerTable table) {
    var sum = Decimal.zero;
    for (final p in table.participations.where((p) => p.leftAt == null)) {
      for (final b in p.buyIns) {
        sum += b.amount;
      }
    }
    return sum;
  }
}
