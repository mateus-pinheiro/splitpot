import 'package:decimal/decimal.dart';

import '../entities/poker_table.dart';
import '../repositories/tables_repository.dart';

class CreateTable {
  const CreateTable(this._repository);

  final TablesRepository _repository;

  Future<PokerTable> call({
    required String name,
    required Decimal minBuyIn,
    bool joinAsPlayer = false,
    Decimal? initialBuyIn,
  }) {
    return _repository.createTable(
      name: name,
      minBuyIn: minBuyIn,
      joinAsPlayer: joinAsPlayer,
      initialBuyIn: initialBuyIn,
    );
  }
}
