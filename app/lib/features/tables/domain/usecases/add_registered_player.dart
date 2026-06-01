import 'package:decimal/decimal.dart';

import '../repositories/participations_repository.dart';

class AddRegisteredPlayer {
  const AddRegisteredPlayer(this._repository);

  final ParticipationsRepository _repository;

  Future<String> call({
    required String tableId,
    required String userId,
    Decimal? initialBuyIn,
  }) =>
      _repository.addRegisteredPlayer(
        tableId: tableId,
        userId: userId,
        initialBuyIn: initialBuyIn,
      );
}
