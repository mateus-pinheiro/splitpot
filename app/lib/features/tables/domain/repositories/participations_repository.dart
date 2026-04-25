import 'package:decimal/decimal.dart';

/// Join/leave de participações da mesa.
///
/// Só entra como "join" por ora — leave/rebuys/cash-out virão quando a
/// UI correspondente for integrada.
abstract class ParticipationsRepository {
  /// Registra o usuário autenticado como participante da mesa, opcional-
  /// mente já gravando o aporte inicial. Lança [ApiException] se a mesa
  /// estiver fechada, o usuário já participar ou o buy-in for inferior
  /// ao mínimo da mesa.
  Future<void> joinTable({required String tableId, Decimal? initialBuyIn});
}
