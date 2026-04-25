import 'package:decimal/decimal.dart';

import '../repositories/participations_repository.dart';

class JoinTable {
  const JoinTable(this._repository);

  final ParticipationsRepository _repository;

  Future<void> call(String tableId, {Decimal? initialBuyIn}) =>
      _repository.joinTable(tableId: tableId, initialBuyIn: initialBuyIn);
}
