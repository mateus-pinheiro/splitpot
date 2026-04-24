import 'package:decimal/decimal.dart';

import '../entities/poker_table.dart';
import '../entities/settlement_draft.dart';

/// Contrato do repositório de mesas.
abstract class TablesRepository {
  /// Cria uma nova mesa aberta com o usuário logado como owner.
  Future<PokerTable> createTable({
    required String name,
    required Decimal minBuyIn,
  });

  /// Busca uma mesa pelo id. Lança [StateError] se não encontrar.
  Future<PokerTable> getTable(String id);

  /// Fecha a mesa e retorna o plano de acertos P2P.
  ///
  /// Só o owner pode fechar. Depois de fechada a mesa é imutável
  /// (decidido em 2026-04-22 — pode mudar com demanda real).
  Future<CloseTableResult> closeTable(String id);
}

class CloseTableResult {
  const CloseTableResult({
    required this.table,
    required this.settlements,
    required this.divergence,
  });

  final PokerTable table;
  final List<SettlementDraft> settlements;

  /// Diferença `cashOuts - buyIns`. Zero é o esperado; valores diferentes
  /// de zero indicam chips sumiram ou saídas foram mal declaradas.
  final Decimal divergence;
}
