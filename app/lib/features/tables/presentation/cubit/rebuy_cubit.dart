import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/add_buy_in.dart';

class RebuyCubit extends Cubit<RebuyState> {
  RebuyCubit(this._addBuyIn) : super(const RebuyState.idle());

  final AddBuyIn _addBuyIn;

  Future<void> submit({
    required String participationId,
    required Decimal amount,
  }) async {
    if (state is RebuySubmitting) return;
    emit(const RebuyState.submitting());
    try {
      await _addBuyIn(participationId: participationId, amount: amount);
      emit(const RebuyState.success());
    } on ApiException catch (e) {
      emit(RebuyState.error(e.failure));
    } on Object catch (e) {
      emit(RebuyState.error(Failure.unexpected(message: e.toString())));
    }
  }

  void reset() => emit(const RebuyState.idle());
}

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
