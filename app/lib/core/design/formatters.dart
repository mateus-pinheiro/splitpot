import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart' show NumberFormat;

/// Formatação BRL usada no app (ex.: `R$ 150,00`, `-R$ 9,50`).
///
/// Duas casas decimais por padrão. Money no SplitPot é `Decimal(12, 2)` no
/// backend, e os jogadores frequentemente declaram valores com centavos
/// (ex.: cash-out de R$ 145,25); arredondar para inteiros mascarava
/// reconciliações de poucos centavos. Passe `decimals: 0` quando quiser
/// explicitamente esconder os centavos (poucos casos legítimos).
String brl(num amount, {int decimals = 2}) {
  final abs = amount.abs();
  final pattern = decimals == 0 ? '#,##0' : '#,##0.${'0' * decimals}';
  final formatted = NumberFormat(pattern, 'pt_BR').format(abs);
  final sign = amount < 0 ? '-' : '';
  return '$sign' 'R\$ $formatted';
}

String brlFromDecimal(Decimal amount, {int decimals = 2}) {
  return brl(amount.toDouble(), decimals: decimals);
}

/// Versão com sinal explícito para preview de P&L (`+R$ 190,00`, `-R$ 120,00`).
String brlSigned(num amount, {int decimals = 2}) {
  if (amount >= 0) return '+${brl(amount, decimals: decimals)}';
  return brl(amount, decimals: decimals);
}
