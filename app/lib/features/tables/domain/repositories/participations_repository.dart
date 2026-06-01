import 'package:decimal/decimal.dart';

/// Operações sobre participações da mesa.
abstract class ParticipationsRepository {
  /// Registra o usuário autenticado como participante da mesa. Retorna o
  /// participationId criado. Lança [ApiException] se a mesa estiver fechada
  /// ou o usuário já participar.
  Future<String> joinTable({
    required String tableId,
    Decimal? initialBuyIn,
  });

  /// Host adiciona um usuário cadastrado como participante. Backend valida
  /// que o caller é o host.
  Future<String> addRegisteredPlayer({
    required String tableId,
    required String userId,
    Decimal? initialBuyIn,
  });

  /// Host adiciona um convidado sem conta (nome + PIX) como participante.
  Future<String> addGuestPlayer({
    required String tableId,
    required String name,
    required String pixKey,
    Decimal? initialBuyIn,
  });

  /// Remove a participação (soft via `leftAt`). O caller precisa ser o
  /// próprio jogador ou o host.
  Future<void> leaveTable({required String participationId});

  /// Adiciona um buy-in (rebuy) a uma participação existente. O caller
  /// precisa ser dono da participação (ou owner da mesa).
  Future<void> addBuyIn({
    required String participationId,
    required Decimal amount,
  });

  /// Atualiza o valor de um buy-in existente (host edita uma entrada errada).
  Future<void> updateBuyIn({
    required String participationId,
    required String buyInId,
    required Decimal amount,
  });

  /// Remove um buy-in específico de uma participação.
  Future<void> removeBuyIn({
    required String participationId,
    required String buyInId,
  });

  /// Registra/atualiza o cash-out de uma participação (PUT semântico —
  /// upsert no backend). O participante declara com quanto saiu da mesa.
  ///
  /// [skipAutoClose] desliga o auto-close best-effort do backend (que dispara
  /// quando todos os ativos têm cash-out). Usado pelo fluxo de conferência,
  /// onde o host empurra vários ajustes antes de fechar explicitamente —
  /// sem isso, o penúltimo ajuste pode fechar a mesa antes do botão "Fechar".
  Future<void> setCashOut({
    required String participationId,
    required Decimal amount,
    bool skipAutoClose = false,
  });

  /// Volta um participante que já tinha saído: limpa o cash-out e grava
  /// o novo buy-in num único request — atômico no backend.
  Future<void> rejoin({
    required String participationId,
    required Decimal amount,
  });
}
