import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/action_type.dart';
import '../../domain/usecases/add_buy_in.dart';
import '../../domain/usecases/rejoin_table.dart';
import '../../domain/usecases/request_action.dart';

/// Lida tanto com **rebuy** (participante ainda na mesa adiciona aporte)
/// quanto com **rejoin** (participante que tinha cash-out volta).
/// Se [isHost] for true, executa a ação diretamente; caso contrário cria
/// uma [ActionRequest] pendente de aprovação.
class RebuyCubit extends Cubit<RebuyState> {
  RebuyCubit({
    required AddBuyIn addBuyIn,
    required RejoinTable rejoinTable,
    required RequestAction requestAction,
  })  : _addBuyIn = addBuyIn,
        _rejoinTable = rejoinTable,
        _requestAction = requestAction,
        super(const RebuyState.idle());

  final AddBuyIn _addBuyIn;
  final RejoinTable _rejoinTable;
  final RequestAction _requestAction;

  Future<void> submit({
    required String participationId,
    required Decimal amount,
    required bool isHost,
    RebuyMode mode = RebuyMode.rebuy,
  }) async {
    if (state is RebuySubmitting) return;
    emit(const RebuyState.submitting());
    try {
      if (isHost) {
        switch (mode) {
          case RebuyMode.rebuy:
            await _addBuyIn(participationId: participationId, amount: amount);
          case RebuyMode.rejoin:
            await _rejoinTable(participationId: participationId, amount: amount);
        }
        emit(const RebuyState.success());
      } else {
        final type = mode == RebuyMode.rebuy ? ActionType.rebuy : ActionType.rejoin;
        await _requestAction(
          participationId: participationId,
          type: type,
          amount: amount,
        );
        emit(const RebuyState.awaitingApproval());
      }
    } on ApiException catch (e) {
      emit(RebuyState.error(e.failure));
    } on Object catch (e) {
      emit(RebuyState.error(Failure.unexpected(message: e.toString())));
    }
  }

  void reset() => emit(const RebuyState.idle());
}

enum RebuyMode { rebuy, rejoin }

sealed class RebuyState {
  const RebuyState();
  const factory RebuyState.idle() = RebuyIdle;
  const factory RebuyState.submitting() = RebuySubmitting;
  const factory RebuyState.success() = RebuySuccess;
  const factory RebuyState.awaitingApproval() = RebuyAwaitingApproval;
  const factory RebuyState.error(Failure failure) = RebuyError;
}

class RebuyIdle extends RebuyState {
  const RebuyIdle();
}

class RebuySubmitting extends RebuyState {
  const RebuySubmitting();
}

class RebuySuccess extends RebuyState {
  const RebuySuccess();
}

class RebuyAwaitingApproval extends RebuyState {
  const RebuyAwaitingApproval();
}

class RebuyError extends RebuyState {
  const RebuyError(this.failure);
  final Failure failure;
}
