import '../entities/settlement.dart';

abstract class SettlementsRepository {
  /// Lista os settlements de uma mesa que envolvam o usuário (como
  /// pagador, recebedor ou owner). Backend filtra por permissão.
  Future<List<Settlement>> listByTable(String tableId);

  /// Marca o settlement como pago. Apenas o `toUser` (recebedor)
  /// pode confirmar.
  Future<void> confirm(String settlementId);

  /// Host marca como pago um settlement envolvendo convidado (que não tem
  /// app pra confirmar sozinho). Backend valida que pelo menos uma ponta
  /// é guest.
  Future<void> confirmOnBehalf(String settlementId);
}
