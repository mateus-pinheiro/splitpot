import 'package:decimal/decimal.dart';

import '../repositories/participations_repository.dart';

class AddGuestPlayer {
  const AddGuestPlayer(this._repository);

  final ParticipationsRepository _repository;

  Future<String> call({
    required String tableId,
    required String name,
    required String pixKey,
    Decimal? initialBuyIn,
  }) =>
      _repository.addGuestPlayer(
        tableId: tableId,
        name: name,
        pixKey: pixKey,
        initialBuyIn: initialBuyIn,
      );
}
