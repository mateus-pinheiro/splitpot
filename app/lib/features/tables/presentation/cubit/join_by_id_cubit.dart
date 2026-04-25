import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/table_preview.dart';
import '../../domain/usecases/get_table_preview.dart';
import '../../domain/usecases/join_table.dart';

class JoinByIdCubit extends Cubit<JoinByIdState> {
  JoinByIdCubit({
    required GetTablePreview getTablePreview,
    required JoinTable joinTable,
  })  : _getTablePreview = getTablePreview,
        _joinTable = joinTable,
        super(const JoinByIdState.loading());

  final GetTablePreview _getTablePreview;
  final JoinTable _joinTable;

  Future<void> load(String tableId) async {
    emit(const JoinByIdState.loading());
    try {
      final preview = await _getTablePreview(tableId);
      emit(JoinByIdState.ready(preview));
    } on ApiException catch (e) {
      emit(JoinByIdState.error(e.failure));
    }
  }

  Future<void> confirm(String tableId, {Decimal? initialBuyIn}) async {
    final current = state;
    if (current is! JoinByIdStateReady) return;
    emit(JoinByIdState.joining(current.preview));
    try {
      await _joinTable(tableId, initialBuyIn: initialBuyIn);
      emit(JoinByIdState.joined(current.preview));
    } on ApiException catch (e) {
      // Backend retorna 400 "Usuário já participa dessa mesa" — pra essa
      // experiência é igual a sucesso (vai pra /live).
      final failure = e.failure;
      if (failure is ValidationFailure &&
          failure.message.toLowerCase().contains('já participa')) {
        emit(JoinByIdState.joined(current.preview));
        return;
      }
      emit(JoinByIdState.joinError(current.preview, failure));
    }
  }
}

sealed class JoinByIdState {
  const JoinByIdState();
  const factory JoinByIdState.loading() = JoinByIdStateLoading;
  const factory JoinByIdState.ready(TablePreview preview) = JoinByIdStateReady;
  const factory JoinByIdState.joining(TablePreview preview) =
      JoinByIdStateJoining;
  const factory JoinByIdState.joined(TablePreview preview) =
      JoinByIdStateJoined;
  const factory JoinByIdState.error(Failure failure) = JoinByIdStateError;
  const factory JoinByIdState.joinError(TablePreview preview, Failure failure) =
      JoinByIdStateJoinError;
}

class JoinByIdStateLoading extends JoinByIdState {
  const JoinByIdStateLoading();
}

class JoinByIdStateReady extends JoinByIdState {
  const JoinByIdStateReady(this.preview);
  final TablePreview preview;
}

class JoinByIdStateJoining extends JoinByIdState {
  const JoinByIdStateJoining(this.preview);
  final TablePreview preview;
}

class JoinByIdStateJoined extends JoinByIdState {
  const JoinByIdStateJoined(this.preview);
  final TablePreview preview;
}

class JoinByIdStateError extends JoinByIdState {
  const JoinByIdStateError(this.failure);
  final Failure failure;
}

class JoinByIdStateJoinError extends JoinByIdState {
  const JoinByIdStateJoinError(this.preview, this.failure);
  final TablePreview preview;
  final Failure failure;
}
