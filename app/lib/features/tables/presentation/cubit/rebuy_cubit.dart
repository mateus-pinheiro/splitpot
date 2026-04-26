import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/add_buy_in.dart';
import '../../domain/usecases/rejoin_table.dart';

/// Lida tanto com **rebuy** (participante ainda na mesa adiciona aporte)
/// quanto com **rejoin** (participante que tinha cash-out volta).
/// O backend trata os dois — endpoints diferentes; o cubit despacha
/// conforme [RebuyMode].
class RebuyCubit extends Cubit<RebuyState> {
  RebuyCubit({
    required AddBuyIn addBuyIn,
    required RejoinTable rejoinTable,
  })  : _addBuyIn = addBuyIn,
        _rejoinTable = rejoinTable,
        super(const RebuyState.idle());

  final AddBuyIn _addBuyIn;
  final RejoinTable _rejoinTable;

  Future<void> submit({
    required String participationId,
    required Decimal amount,
    RebuyMode mode = RebuyMode.rebuy,
  }) async {
    if (state is RebuySubmitting) return;
    emit(const RebuyState.submitting());
    try {
      switch (mode) {
        case RebuyMode.rebuy:
          await _addBuyIn(participationId: participationId, amount: amount);
        case RebuyMode.rejoin:
          await _rejoinTable(participationId: participationId, amount: amount);
      }
      emit(const RebuyState.success());
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

class RebuyError extends RebuyState {
  const RebuyError(this.failure);
  final Failure failure;
}
