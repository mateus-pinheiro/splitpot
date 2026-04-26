import 'package:decimal/decimal.dart';

import '../entities/poker_table.dart';
import '../entities/settlement_draft.dart';
import '../entities/table_preview.dart';
import '../entities/user_stats.dart';

/// Contrato do repositório de mesas.
abstract class TablesRepository {
  /// Cria uma nova mesa aberta com o usuário logado como owner. Quando
  /// `joinAsPlayer` é `true`, o owner também já entra como participante
  /// (sem aporte inicial — declara depois).
  Future<PokerTable> createTable({
    required String name,
    required Decimal minBuyIn,
    bool joinAsPlayer = false,
  });

  /// Busca uma mesa pelo id. Lança [StateError] se não encontrar.
  Future<PokerTable> getTable(String id);

  /// Visão pública mínima da mesa — usada na tela de pre-join, antes do
  /// usuário virar participant. Não exige acesso owner/participant.
  Future<TablePreview> getTablePreview(String id);

  /// Fecha a mesa e retorna o plano de acertos P2P.
  ///
  /// Só o owner pode fechar. Depois de fechada a mesa é imutável
  /// (decidido em 2026-04-22 — pode mudar com demanda real).
  Future<CloseTableResult> closeTable(String id);

  /// Stats agregadas pra home (P&L total, mesas, vitórias, recentes).
  Future<UserStats> getUserStats();
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
