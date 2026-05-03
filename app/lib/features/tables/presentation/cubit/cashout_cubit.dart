import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/action_type.dart';
import '../../domain/entities/poker_table.dart';
import '../../domain/entities/table_participation.dart';
import '../../domain/usecases/get_table.dart';
import '../../domain/usecases/request_action.dart';
import '../../domain/usecases/set_cash_out.dart';

/// Carrega a mesa + participation do usuário e dispara cash-out.
/// Se o usuário for o host, executa diretamente; caso contrário cria
/// uma ActionRequest pendente de aprovação do host.
class CashoutCubit extends Cubit<CashoutState> {
  CashoutCubit({
    required GetTable getTable,
    required SetCashOut setCashOut,
    required RequestAction requestAction,
  })  : _getTable = getTable,
        _setCashOut = setCashOut,
        _requestAction = requestAction,
        super(const CashoutState.loading());

  final GetTable _getTable;
  final SetCashOut _setCashOut;
  final RequestAction _requestAction;

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
      final isHost = table.ownerId == currentUserId;
      emit(CashoutState.ready(
        table: table,
        participation: mine,
        isHost: isHost,
      ));
    } on ApiException catch (e) {
      emit(CashoutState.error(e.failure));
    }
  }

  Future<void> submit(Decimal amount) async {
    final cur = state;
    final PokerTable table;
    final TableParticipation participation;
    final bool isHost;
    if (cur is CashoutReady) {
      table = cur.table;
      participation = cur.participation;
      isHost = cur.isHost;
    } else if (cur is CashoutSubmitError) {
      table = cur.table;
      participation = cur.participation;
      isHost = cur.isHost;
    } else {
      return;
    }
    emit(CashoutState.submitting(
      table: table,
      participation: participation,
      isHost: isHost,
    ));
    try {
      if (isHost) {
        await _setCashOut(
          participationId: participation.id,
          amount: amount,
        );
        emit(CashoutState.submitted(table: table));
      } else {
        await _requestAction(
          participationId: participation.id,
          type: ActionType.leave,
          amount: amount,
        );
        emit(const CashoutState.awaitingApproval());
      }
    } on ApiException catch (e) {
      emit(CashoutState.submitError(
        table: table,
        participation: participation,
        isHost: isHost,
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
    required bool isHost,
  }) = CashoutReady;

  const factory CashoutState.submitting({
    required PokerTable table,
    required TableParticipation participation,
    required bool isHost,
  }) = CashoutSubmitting;

  const factory CashoutState.submitted({required PokerTable table}) =
      CashoutSubmitted;

  const factory CashoutState.awaitingApproval() = CashoutAwaitingApproval;

  const factory CashoutState.submitError({
    required PokerTable table,
    required TableParticipation participation,
    required bool isHost,
    required Failure failure,
  }) = CashoutSubmitError;

  const factory CashoutState.error(Failure failure) = CashoutError;
}

class CashoutLoading extends CashoutState {
  const CashoutLoading();
}

class CashoutReady extends CashoutState {
  const CashoutReady({
    required this.table,
    required this.participation,
    required this.isHost,
  });
  final PokerTable table;
  final TableParticipation participation;
  final bool isHost;
}

class CashoutSubmitting extends CashoutState {
  const CashoutSubmitting({
    required this.table,
    required this.participation,
    required this.isHost,
  });
  final PokerTable table;
  final TableParticipation participation;
  final bool isHost;
}

class CashoutSubmitted extends CashoutState {
  const CashoutSubmitted({required this.table});
  final PokerTable table;
}

class CashoutAwaitingApproval extends CashoutState {
  const CashoutAwaitingApproval();
}

class CashoutSubmitError extends CashoutState {
  const CashoutSubmitError({
    required this.table,
    required this.participation,
    required this.isHost,
    required this.failure,
  });
  final PokerTable table;
  final TableParticipation participation;
  final bool isHost;
  final Failure failure;
}

class CashoutError extends CashoutState {
  const CashoutError(this.failure);
  final Failure failure;
}
