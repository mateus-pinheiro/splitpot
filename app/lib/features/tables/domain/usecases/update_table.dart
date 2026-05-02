import 'package:decimal/decimal.dart';

import '../entities/poker_table.dart';
import '../repositories/tables_repository.dart';

class UpdateTable {
  const UpdateTable(this._repository);

  final TablesRepository _repository;

  Future<PokerTable> call({
    required String id,
    required String name,
    required Decimal minBuyIn,
    bool joinAsPlayer = false,
  }) {
    return _repository.updateTable(
      id: id,
      name: name,
      minBuyIn: minBuyIn,
      joinAsPlayer: joinAsPlayer,
    );
  }
}
