import '../../../../core/errors/failure.dart';

sealed class CreateTableState {
  const CreateTableState();
  const factory CreateTableState.idle() = CreateTableIdle;
  const factory CreateTableState.creating() = CreateTableCreating;
  const factory CreateTableState.created({
    required String tableId,
    required bool joinedAsPlayer,
  }) = CreateTableCreated;
  const factory CreateTableState.error(Failure failure) = CreateTableError;
}

class CreateTableIdle extends CreateTableState {
  const CreateTableIdle();
}

class CreateTableCreating extends CreateTableState {
  const CreateTableCreating();
}

class CreateTableCreated extends CreateTableState {
  const CreateTableCreated({
    required this.tableId,
    required this.joinedAsPlayer,
  });
  final String tableId;
  final bool joinedAsPlayer;
}

class CreateTableError extends CreateTableState {
  const CreateTableError(this.failure);
  final Failure failure;
}
