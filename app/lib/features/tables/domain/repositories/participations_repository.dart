import 'package:decimal/decimal.dart';

/// Operações sobre participações da mesa.
abstract class ParticipationsRepository {
  /// Registra o usuário autenticado como participante da mesa. Retorna o
  /// participationId criado. Lança [ApiException] se a mesa estiver fechada
  /// ou o usuário já participar.
  Future<String> joinTable({required String tableId});

  /// Adiciona um buy-in (rebuy) a uma participação existente. O caller
  /// precisa ser dono da participação (ou owner da mesa).
  Future<void> addBuyIn({
    required String participationId,
    required Decimal amount,
  });

  /// Registra/atualiza o cash-out de uma participação (PUT semântico —
  /// upsert no backend). O participante declara com quanto saiu da mesa.
  Future<void> setCashOut({
    required String participationId,
    required Decimal amount,
  });

  /// Volta um participante que já tinha saído: limpa o cash-out e grava
  /// o novo buy-in num único request — atômico no backend.
  Future<void> rejoin({
    required String participationId,
    required Decimal amount,
  });
}
