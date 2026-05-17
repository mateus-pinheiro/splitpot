import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/poker_table.dart';
import '../../domain/usecases/usecases.dart';

/// Carrega a mesa recém-criada para o owner declarar seu aporte inicial.
/// Identifica a `participation` do owner pelo userId e dispara o
/// `POST /participations/:id/buy-ins` no submit.
class InitialBuyInCubit extends Cubit<InitialBuyInState> {
  InitialBuyInCubit({
    required GetTable getTable,
    required AddBuyIn addBuyIn,
  })  : _getTable = getTable,
        _addBuyIn = addBuyIn,
        super(const InitialBuyInState.loading());

  final GetTable _getTable;
  final AddBuyIn _addBuyIn;

  Future<void> load({
    required String tableId,
    required String currentUserId,
  }) async {
    emit(const InitialBuyInState.loading());
    try {
      final table = await _getTable(tableId);
      final mine = _firstWhereOrNull<dynamic>(
        table.participations,
        (p) => p.userId == currentUserId,
      );
      if (mine == null) {
        emit(const InitialBuyInState.error(
          Failure.notFound(
            message: 'Você não está marcado como jogador nesta mesa.',
          ),
        ));
        return;
      }
      emit(InitialBuyInState.ready(
        table: table,
        participationId: mine.id as String,
      ));
    } on ApiException catch (e) {
      emit(InitialBuyInState.error(e.failure));
    }
  }

  Future<void> submit(Decimal amount) async {
    final cur = state;
    if (cur is! InitialBuyInReady) return;
    emit(InitialBuyInState.submitting(
      table: cur.table,
      participationId: cur.participationId,
    ));
    try {
      await _addBuyIn(participationId: cur.participationId, amount: amount);
      emit(InitialBuyInState.submitted(table: cur.table));
    } on ApiException catch (e) {
      emit(InitialBuyInState.submitError(
        table: cur.table,
        participationId: cur.participationId,
        failure: e.failure,
      ));
    }
  }

  static T? _firstWhereOrNull<T>(Iterable it, bool Function(dynamic) pred) {
    for (final e in it) {
      if (pred(e)) return e as T;
    }
    return null;
  }
}

sealed class InitialBuyInState {
  const InitialBuyInState();

  const factory InitialBuyInState.loading() = InitialBuyInLoading;

  const factory InitialBuyInState.ready({
    required PokerTable table,
    required String participationId,
  }) = InitialBuyInReady;

  const factory InitialBuyInState.submitting({
    required PokerTable table,
    required String participationId,
  }) = InitialBuyInSubmitting;

  const factory InitialBuyInState.submitted({required PokerTable table}) =
      InitialBuyInSubmitted;

  const factory InitialBuyInState.submitError({
    required PokerTable table,
    required String participationId,
    required Failure failure,
  }) = InitialBuyInSubmitError;

  const factory InitialBuyInState.error(Failure failure) = InitialBuyInError;
}

class InitialBuyInLoading extends InitialBuyInState {
  const InitialBuyInLoading();
}

class InitialBuyInReady extends InitialBuyInState {
  const InitialBuyInReady({
    required this.table,
    required this.participationId,
  });
  final PokerTable table;
  final String participationId;
}

class InitialBuyInSubmitting extends InitialBuyInState {
  const InitialBuyInSubmitting({
    required this.table,
    required this.participationId,
  });
  final PokerTable table;
  final String participationId;
}

class InitialBuyInSubmitted extends InitialBuyInState {
  const InitialBuyInSubmitted({required this.table});
  final PokerTable table;
}

class InitialBuyInSubmitError extends InitialBuyInState {
  const InitialBuyInSubmitError({
    required this.table,
    required this.participationId,
    required this.failure,
  });
  final PokerTable table;
  final String participationId;
  final Failure failure;
}

class InitialBuyInError extends InitialBuyInState {
  const InitialBuyInError(this.failure);
  final Failure failure;
}
