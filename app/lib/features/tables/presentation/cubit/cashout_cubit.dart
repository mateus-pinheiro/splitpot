import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/poker_table.dart';
import '../../domain/entities/table_participation.dart';
import '../../domain/usecases/get_table.dart';
import '../../domain/usecases/set_cash_out.dart';

/// Carrega a mesa + participation do usuário e dispara o
/// `PUT /participations/:id/cash-out` no submit.
class CashoutCubit extends Cubit<CashoutState> {
  CashoutCubit({
    required GetTable getTable,
    required SetCashOut setCashOut,
  })  : _getTable = getTable,
        _setCashOut = setCashOut,
        super(const CashoutState.loading());

  final GetTable _getTable;
  final SetCashOut _setCashOut;

  Future<void> load({
    required String tableId,
    required String currentUserId,
  }) async {
    emit(const CashoutState.loading());
    try {
      final table = await _getTable(tableId);
      final mine = _firstWhereOrNull<TableParticipation>(
        table.participations,
        (p) => p.userId == currentUserId,
      );
      if (mine == null) {
        emit(const CashoutState.error(
          Failure.notFound(
            message: 'Você não está como participante desta mesa.',
          ),
        ));
        return;
      }
      emit(CashoutState.ready(table: table, participation: mine));
    } on ApiException catch (e) {
      emit(CashoutState.error(e.failure));
    }
  }

  Future<void> submit(Decimal amount) async {
    final cur = state;
    if (cur is! CashoutReady) return;
    emit(CashoutState.submitting(
      table: cur.table,
      participation: cur.participation,
    ));
    try {
      await _setCashOut(
        participationId: cur.participation.id,
        amount: amount,
      );
      emit(CashoutState.submitted(table: cur.table));
    } on ApiException catch (e) {
      emit(CashoutState.submitError(
        table: cur.table,
        participation: cur.participation,
        failure: e.failure,
      ));
    }
  }

  static T? _firstWhereOrNull<T>(Iterable<T> it, bool Function(T) pred) {
    for (final e in it) {
      if (pred(e)) return e;
    }
    return null;
  }
}

sealed class CashoutState {
  const CashoutState();

  const factory CashoutState.loading() = CashoutLoading;

  const factory CashoutState.ready({
    required PokerTable table,
    required TableParticipation participation,
  }) = CashoutReady;

  const factory CashoutState.submitting({
    required PokerTable table,
    required TableParticipation participation,
  }) = CashoutSubmitting;

  const factory CashoutState.submitted({required PokerTable table}) =
      CashoutSubmitted;

  const factory CashoutState.submitError({
    required PokerTable table,
    required TableParticipation participation,
    required Failure failure,
  }) = CashoutSubmitError;

  const factory CashoutState.error(Failure failure) = CashoutError;
}

class CashoutLoading extends CashoutState {
  const CashoutLoading();
}

class CashoutReady extends CashoutState {
  const CashoutReady({required this.table, required this.participation});
  final PokerTable table;
  final TableParticipation participation;
}

class CashoutSubmitting extends CashoutState {
  const CashoutSubmitting({required this.table, required this.participation});
  final PokerTable table;
  final TableParticipation participation;
}

class CashoutSubmitted extends CashoutState {
  const CashoutSubmitted({required this.table});
  final PokerTable table;
}

class CashoutSubmitError extends CashoutState {
  const CashoutSubmitError({
    required this.table,
    required this.participation,
    required this.failure,
  });
  final PokerTable table;
  final TableParticipation participation;
  final Failure failure;
}

class CashoutError extends CashoutState {
  const CashoutError(this.failure);
  final Failure failure;
}
