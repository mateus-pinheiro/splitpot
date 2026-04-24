import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/async_state.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/tables_repository.dart';
import '../../domain/usecases/close_table.dart';

class CloseTableCubit extends Cubit<AsyncState<CloseTableResult>> {
  CloseTableCubit(this._closeTable) : super(const AsyncState.initial());

  final CloseTable _closeTable;

  Future<void> run(String tableId) async {
    emit(const AsyncState.loading());
    try {
      final result = await _closeTable(tableId);
      emit(AsyncState.success(result));
    } on Object catch (e) {
      emit(AsyncState.error(Failure.unexpected(message: e.toString())));
    }
  }
}
