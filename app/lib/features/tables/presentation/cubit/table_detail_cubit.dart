import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/async_state.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/poker_table.dart';
import '../../domain/usecases/get_table.dart';

class TableDetailCubit extends Cubit<AsyncState<PokerTable>> {
  TableDetailCubit(this._getTable) : super(const AsyncState.initial());

  final GetTable _getTable;

  Future<void> load(String tableId) async {
    emit(const AsyncState.loading());
    try {
      final table = await _getTable(tableId);
      emit(AsyncState.success(table));
    } on Object catch (e) {
      emit(AsyncState.error(Failure.unexpected(message: e.toString())));
    }
  }
}
