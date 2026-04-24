import 'package:decimal/decimal.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/buy_in.dart';
import '../../domain/entities/cash_out.dart';
import '../../domain/entities/poker_table.dart';
import '../../domain/entities/table_participation.dart';
import '../../domain/entities/table_status.dart';
import '../../domain/repositories/tables_repository.dart';
import '../../domain/usecases/calculate_settlements.dart';

/// Implementação em memória para desenvolvimento sem backend.
///
/// O `ownerId` é resolvido a partir do [AuthRepository] para simular o que
/// o backend fará (extrair do token). O store é efêmero — some em cada
/// hot restart. Cada mesa criada já vem populada com jogadores demo para
/// exercitar o fluxo de fechamento sem precisar construir antes o fluxo
/// de entrada por QR Code.
class MockTablesRepository implements TablesRepository {
  MockTablesRepository(this._authRepository);

  final AuthRepository _authRepository;
  final Map<String, PokerTable> _store = {};
  final Map<String, String> _pixKeysByUserId = {};
  final _calculator = const CalculateSettlements();
  int _seq = 0;

  @override
  Future<PokerTable> createTable({
    required String name,
    required Decimal minBuyIn,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      throw StateError('Não há usuário autenticado para abrir uma mesa');
    }
    final id = 'mock-table-${++_seq}';
    final now = DateTime.now();

    _pixKeysByUserId[user.id] = user.pixKey;

    final ownerParticipation = TableParticipation(
      id: '$id-p-1',
      tableId: id,
      userId: user.id,
      userName: user.name,
      joinedAt: now,
      leftAt: now,
      buyIns: [
        BuyIn(
          id: '$id-b-1',
          participationId: '$id-p-1',
          amount: Decimal.fromInt(100),
          createdAt: now,
        ),
      ],
      cashOut: CashOut(
        id: '$id-c-1',
        participationId: '$id-p-1',
        amount: Decimal.fromInt(180),
        createdAt: now,
      ),
    );

    final demoParticipations = [
      ownerParticipation,
      ..._buildDemoParticipations(tableId: id, baseTime: now),
    ];

    final table = PokerTable(
      id: id,
      ownerId: user.id,
      name: name,
      minBuyIn: minBuyIn,
      status: TableStatus.open,
      createdAt: now,
      participations: demoParticipations,
    );
    _store[id] = table;
    return table;
  }

  @override
  Future<PokerTable> getTable(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final table = _store[id];
    if (table == null) {
      throw StateError('Mesa $id não encontrada');
    }
    return table;
  }

  @override
  Future<CloseTableResult> closeTable(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final table = _store[id];
    if (table == null) {
      throw StateError('Mesa $id não encontrada');
    }
    if (table.status == TableStatus.closed) {
      throw StateError('Mesa $id já está fechada');
    }

    final closed = table.copyWith(
      status: TableStatus.closed,
      closedAt: DateTime.now(),
    );
    _store[id] = closed;

    final settlements = _calculator(
      table: closed,
      userPixByUserId: _pixKeysByUserId,
    );

    return CloseTableResult(
      table: closed,
      settlements: settlements,
      divergence: tableDivergence(closed),
    );
  }

  List<TableParticipation> _buildDemoParticipations({
    required String tableId,
    required DateTime baseTime,
  }) {
    // Três jogadores fictícios com pontos de virada clássicos: um grande
    // vencedor, dois perdedores e alguém que empatou. A conta fecha
    // exatamente para validar visualmente o algoritmo.
    final demos = [
      _DemoPlayer(
        userId: 'demo-ana',
        name: 'Ana',
        pix: 'ana@exemplo.com',
        buyIns: [Decimal.fromInt(100), Decimal.fromInt(50)],
        cashOut: Decimal.fromInt(0),
      ),
      _DemoPlayer(
        userId: 'demo-bruno',
        name: 'Bruno',
        pix: '11999990000',
        buyIns: [Decimal.fromInt(100)],
        cashOut: Decimal.fromInt(100),
      ),
      _DemoPlayer(
        userId: 'demo-carol',
        name: 'Carol',
        pix: 'carol-pix-aleatoria',
        buyIns: [Decimal.fromInt(100)],
        cashOut: Decimal.fromInt(170),
      ),
    ];

    final result = <TableParticipation>[];
    for (var i = 0; i < demos.length; i++) {
      final d = demos[i];
      _pixKeysByUserId[d.userId] = d.pix;
      final participationId = '$tableId-p-${i + 2}';
      final buyIns = <BuyIn>[];
      for (var j = 0; j < d.buyIns.length; j++) {
        buyIns.add(
          BuyIn(
            id: '$participationId-b-${j + 1}',
            participationId: participationId,
            amount: d.buyIns[j],
            createdAt: baseTime,
          ),
        );
      }
      result.add(
        TableParticipation(
          id: participationId,
          tableId: tableId,
          userId: d.userId,
          userName: d.name,
          joinedAt: baseTime,
          leftAt: baseTime,
          buyIns: buyIns,
          cashOut: CashOut(
            id: '$participationId-c-1',
            participationId: participationId,
            amount: d.cashOut,
            createdAt: baseTime,
          ),
        ),
      );
    }
    return result;
  }
}

class _DemoPlayer {
  const _DemoPlayer({
    required this.userId,
    required this.name,
    required this.pix,
    required this.buyIns,
    required this.cashOut,
  });

  final String userId;
  final String name;
  final String pix;
  final List<Decimal> buyIns;
  final Decimal cashOut;
}
