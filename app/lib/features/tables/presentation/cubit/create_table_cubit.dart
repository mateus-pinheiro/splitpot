import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/usecases.dart';
import 'create_table_state.dart';

class CreateTableCubit extends Cubit<CreateTableState> {
  CreateTableCubit(this._createTable, this._updateTable)
      : super(const CreateTableState.idle());

  final CreateTable _createTable;
  final UpdateTable _updateTable;

  Future<void> submit({
    required String name,
    required Decimal minBuyIn,
    bool joinAsPlayer = false,
    String? tableId,
  }) async {
    if (state is CreateTableCreating) return;
    emit(const CreateTableState.creating());
    try {
      if (tableId != null) {
        final table = await _updateTable(
          id: tableId,
          name: name,
          minBuyIn: minBuyIn,
          joinAsPlayer: joinAsPlayer,
        );
        emit(CreateTableState.created(
          tableId: table.id,
          joinedAsPlayer: joinAsPlayer,
        ));
      } else {
        final table = await _createTable(
          name: name,
          minBuyIn: minBuyIn,
          joinAsPlayer: joinAsPlayer,
        );
        emit(CreateTableState.created(
          tableId: table.id,
          joinedAsPlayer: joinAsPlayer,
        ));
      }
    } on ApiException catch (e) {
      emit(CreateTableState.error(e.failure));
    } on Object catch (e) {
      emit(CreateTableState.error(Failure.unexpected(message: e.toString())));
    }
  }

  void reset() => emit(const CreateTableState.idle());
}
