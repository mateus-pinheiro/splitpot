import 'package:decimal/decimal.dart';

import '../entities/entities.dart';

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

  /// Atualiza nome e buy-in mínimo de uma mesa existente.
  Future<PokerTable> updateTable({
    required String id,
    required String name,
    required Decimal minBuyIn,
    bool joinAsPlayer = false,
  });

  /// Fecha a mesa e retorna o plano de acertos P2P.
  ///
  /// Só o owner pode fechar. Depois de fechada a mesa é imutável
  /// (decidido em 2026-04-22 — pode mudar com demanda real).
  Future<CloseTableResult> closeTable(String id);

  /// Aplica uma estratégia de reconciliação e fecha a mesa numa única
  /// operação atômica. Usado na tela "Conferir saídas" quando as saídas
  /// não batem com o pote.
  Future<CloseTableResult> reconcileAndClose(
    String id,
    ReconcileStrategy strategy,
  );

  /// Stats agregadas pra home (P&L total, mesas, vitórias, recentes).
  Future<UserStats> getUserStats();
}

/// Como o host quer absorver a diferença entre buy-ins e cash-outs.
enum ReconcileStrategy {
  /// O host assume a diferença inteira ajustando o próprio cash-out.
  hostAbsorb,

  /// A diferença é dividida igualmente entre todos os participantes ativos.
  splitEvenly,
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
