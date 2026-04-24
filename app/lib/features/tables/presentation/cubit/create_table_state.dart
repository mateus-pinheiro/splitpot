import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';

part 'create_table_state.freezed.dart';

@freezed
sealed class CreateTableState with _$CreateTableState {
  const factory CreateTableState.idle() = CreateTableIdle;
  const factory CreateTableState.creating() = CreateTableCreating;
  const factory CreateTableState.created(String tableId) = CreateTableCreated;
  const factory CreateTableState.error(Failure failure) = CreateTableError;
}
