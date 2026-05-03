import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/action_type.dart';
import '../../domain/entities/table_preview.dart';
import '../../domain/usecases/get_table_preview.dart';
import '../../domain/usecases/join_table.dart';
import '../../domain/usecases/request_action.dart';

class JoinByIdCubit extends Cubit<JoinByIdState> {
  JoinByIdCubit({
    required GetTablePreview getTablePreview,
    required JoinTable joinTable,
    required RequestAction requestAction,
  })  : _getTablePreview = getTablePreview,
        _joinTable = joinTable,
        _requestAction = requestAction,
        super(const JoinByIdState.loading());

  final GetTablePreview _getTablePreview;
  final JoinTable _joinTable;
  final RequestAction _requestAction;

  Future<void> load(String tableId) async {
    emit(const JoinByIdState.loading());
    try {
      final preview = await _getTablePreview(tableId);
      emit(JoinByIdState.ready(preview));
    } on ApiException catch (e) {
      emit(JoinByIdState.error(e.failure));
    }
  }

  Future<void> confirm(
    String tableId, {
    required Decimal buyInAmount,
    required String currentUserId,
  }) async {
    final current = state;
    if (current is! JoinByIdStateReady) return;
    emit(JoinByIdState.joining(current.preview));

    final isOwner = current.preview.ownerId == currentUserId;

    try {
      String? participationId;
      try {
        participationId = await _joinTable(tableId);
      } on ApiException catch (e) {
        final failure = e.failure;
        if (failure is ValidationFailure &&
            failure.message.toLowerCase().contains('já participa')) {
          // Já é participante — vai direto pra mesa ao vivo.
          emit(JoinByIdState.joined(current.preview));
          return;
        }
        rethrow;
      }

      if (isOwner) {
        // Host está entrando na própria mesa; buy-in direto (sem aprovação).
        // Usa a rota interna de buy-in via participationsRepository.
        // Na prática o owner já tem participação criada no create, então o
        // fluxo acima captura o "já participa" antes de chegar aqui.
        emit(JoinByIdState.joined(current.preview));
      } else {
        await _requestAction(
          participationId: participationId,
          type: ActionType.buyin,
          amount: buyInAmount,
        );
        emit(JoinByIdState.joined(current.preview));
      }
    } on ApiException catch (e) {
      emit(JoinByIdState.joinError(current.preview, e.failure));
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
