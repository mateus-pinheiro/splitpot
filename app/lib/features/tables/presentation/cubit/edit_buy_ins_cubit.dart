import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';

/// Cubit pra `EditBuyInsView`. Carrega a participação alvo a partir de
/// `GetTable` e permite edit/remove de buy-ins individuais. Após cada
/// mutação, recarrega o estado.
class EditBuyInsCubit extends Cubit<EditBuyInsState> {
  EditBuyInsCubit({
    required GetTable getTable,
    required UpdateBuyIn updateBuyIn,
    required RemoveBuyIn removeBuyIn,
  })  : _getTable = getTable,
        _updateBuyIn = updateBuyIn,
        _removeBuyIn = removeBuyIn,
        super(const EditBuyInsState.loading());

  final GetTable _getTable;
  final UpdateBuyIn _updateBuyIn;
  final RemoveBuyIn _removeBuyIn;

  String? _tableId;
  String? _participationId;

  Future<void> load(String tableId, String participationId) async {
    _tableId = tableId;
    _participationId = participationId;
    emit(const EditBuyInsState.loading());
    await _refresh();
  }

  Future<void> updateAmount(String buyInId, Decimal amount) async {
    if (_participationId == null) return;
    final current = state;
    emit(const EditBuyInsState.loading());
    try {
      await _updateBuyIn(
        participationId: _participationId!,
        buyInId: buyInId,
        amount: amount,
      );
      await _refresh();
    } on ApiException catch (e) {
      emit(EditBuyInsState.error(e.failure));
      _restoreLoadedIfPossible(current);
    } on Object catch (e) {
      emit(EditBuyInsState.error(Failure.unexpected(message: e.toString())));
      _restoreLoadedIfPossible(current);
    }
  }

  Future<void> remove(String buyInId) async {
    if (_participationId == null) return;
    final current = state;
    emit(const EditBuyInsState.loading());
    try {
      await _removeBuyIn(
        participationId: _participationId!,
        buyInId: buyInId,
      );
      await _refresh();
    } on ApiException catch (e) {
      emit(EditBuyInsState.error(e.failure));
      _restoreLoadedIfPossible(current);
    } on Object catch (e) {
      emit(EditBuyInsState.error(Failure.unexpected(message: e.toString())));
      _restoreLoadedIfPossible(current);
    }
  }

  Future<void> _refresh() async {
    if (_tableId == null || _participationId == null) return;
    try {
      final table = await _getTable(_tableId!);
      final p = table.participations
          .where((p) => p.id == _participationId!)
          .firstOrNull;
      if (p == null) {
        emit(const EditBuyInsState.error(
          NotFoundFailure(message: 'Participação não encontrada'),
        ));
      } else {
        emit(EditBuyInsState.loaded(p));
      }
    } on ApiException catch (e) {
      emit(EditBuyInsState.error(e.failure));
    } on Object catch (e) {
      emit(EditBuyInsState.error(Failure.unexpected(message: e.toString())));
    }
  }

  void _restoreLoadedIfPossible(EditBuyInsState previous) {
    if (previous is EditBuyInsLoaded) emit(previous);
  }
}

sealed class EditBuyInsState {
  const EditBuyInsState();
  const factory EditBuyInsState.loading() = EditBuyInsLoading;
  const factory EditBuyInsState.loaded(TableParticipation participation) =
      EditBuyInsLoaded;
  const factory EditBuyInsState.error(Failure failure) = EditBuyInsError;
}

class EditBuyInsLoading extends EditBuyInsState {
  const EditBuyInsLoading();
}

class EditBuyInsLoaded extends EditBuyInsState {
  const EditBuyInsLoaded(this.participation);
  final TableParticipation participation;
}

class EditBuyInsError extends EditBuyInsState {
  const EditBuyInsError(this.failure);
  final Failure failure;
}
