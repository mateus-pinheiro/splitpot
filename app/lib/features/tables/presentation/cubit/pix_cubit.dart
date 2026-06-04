import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/settlement.dart';
import '../../domain/usecases/usecases.dart';

class PixCubit extends Cubit<PixState> {
  PixCubit({
    required ListSettlements listSettlements,
    required ConfirmSettlement confirmSettlement,
    required ConfirmSettlementOnBehalf confirmOnBehalf,
    required GetTable getTable,
  })  : _list = listSettlements,
        _confirm = confirmSettlement,
        _confirmOnBehalf = confirmOnBehalf,
        _getTable = getTable,
        super(const PixState.loading());

  final ListSettlements _list;
  final ConfirmSettlement _confirm;
  final ConfirmSettlementOnBehalf _confirmOnBehalf;
  final GetTable _getTable;

  String? _tableId;

  Future<void> load(String tableId) async {
    _tableId = tableId;
    emit(const PixState.loading());
    try {
      final settlements = await _list(tableId);
      // Nome da mesa é best-effort: usado só no texto do compartilhamento.
      String? tableName;
      try {
        tableName = (await _getTable(tableId)).name;
      } catch (_) {}
      emit(PixState.loaded(settlements: settlements, tableName: tableName));
    } on ApiException catch (e) {
      emit(PixState.error(e.failure));
    }
  }

  Future<void> confirm(String settlementId) async {
    final cur = state;
    if (cur is! PixLoaded) return;
    emit(PixState.loaded(
      settlements: cur.settlements,
      tableName: cur.tableName,
      submittingId: settlementId,
    ));
    try {
      await _confirm(settlementId);
      if (_tableId != null) await load(_tableId!);
    } on ApiException catch (e) {
      emit(PixState.loaded(
        settlements: cur.settlements,
        tableName: cur.tableName,
        errorFor: settlementId,
        errorFailure: e.failure,
      ));
    }
  }

  Future<void> confirmOnBehalf(String settlementId) async {
    final cur = state;
    if (cur is! PixLoaded) return;
    emit(PixState.loaded(
      settlements: cur.settlements,
      tableName: cur.tableName,
      submittingId: settlementId,
    ));
    try {
      await _confirmOnBehalf(settlementId);
      if (_tableId != null) await load(_tableId!);
    } on ApiException catch (e) {
      emit(PixState.loaded(
        settlements: cur.settlements,
        tableName: cur.tableName,
        errorFor: settlementId,
        errorFailure: e.failure,
      ));
    }
  }
}

sealed class PixState {
  const PixState();
  const factory PixState.loading() = PixLoading;
  const factory PixState.loaded({
    required List<Settlement> settlements,
    String? tableName,
    String? submittingId,
    String? errorFor,
    Failure? errorFailure,
  }) = PixLoaded;
  const factory PixState.error(Failure failure) = PixError;
}

class PixLoading extends PixState {
  const PixLoading();
}

class PixLoaded extends PixState {
  const PixLoaded({
    required this.settlements,
    this.tableName,
    this.submittingId,
    this.errorFor,
    this.errorFailure,
  });
  final List<Settlement> settlements;
  final String? tableName;
  final String? submittingId;
  final String? errorFor;
  final Failure? errorFailure;
}

class PixError extends PixState {
  const PixError(this.failure);
  final Failure failure;
}
