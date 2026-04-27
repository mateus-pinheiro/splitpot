import '../entities/settlement.dart';

abstract class SettlementsRepository {
  /// Lista os settlements de uma mesa que envolvam o usuário (como
  /// pagador, recebedor ou owner). Backend filtra por permissão.
  Future<List<Settlement>> listByTable(String tableId);

  /// Marca o settlement como pago. Apenas o `toUser` (recebedor)
  /// pode confirmar.
  Future<void> confirm(String settlementId);
}
