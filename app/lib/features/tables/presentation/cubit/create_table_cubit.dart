import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/usecases.dart';
import 'create_table_state.dart';

class CreateTableCubit extends Cubit<CreateTableState> {
  CreateTableCubit(this._createTable) : super(const CreateTableState.idle());

  final CreateTable _createTable;

  Future<void> submit({
    required String name,
    required Decimal minBuyIn,
    bool joinAsPlayer = false,
    Decimal? initialBuyIn,
  }) async {
    if (state is CreateTableCreating) return;
    emit(const CreateTableState.creating());
    try {
      final table = await _createTable(
        name: name,
        minBuyIn: minBuyIn,
        joinAsPlayer: joinAsPlayer,
        initialBuyIn: initialBuyIn,
      );
      emit(CreateTableState.created(
        tableId: table.id,
        joinedAsPlayer: joinAsPlayer,
      ));
    } on ApiException catch (e) {
      emit(CreateTableState.error(e.failure));
    } on Object catch (e) {
      emit(CreateTableState.error(Failure.unexpected(message: e.toString())));
    }
  }

  void reset() => emit(const CreateTableState.idle());
}
