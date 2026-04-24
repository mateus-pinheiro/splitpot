import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart' show NumberFormat;

/// Formatação BRL usada no design (ex.: `R$ 150`, `-R$ 50`).
/// Zero casas decimais por padrão (design só mostra inteiros em money).
String brl(num amount, {int decimals = 0}) {
  final abs = amount.abs();
  final pattern = decimals == 0 ? '#,##0' : '#,##0.${'0' * decimals}';
  final formatted = NumberFormat(pattern, 'pt_BR').format(abs);
  final sign = amount < 0 ? '-' : '';
  return '$sign' 'R\$ $formatted';
}

String brlFromDecimal(Decimal amount, {int decimals = 0}) {
  return brl(amount.toDouble(), decimals: decimals);
}

/// Versão com sinal explícito para preview de P&L (`+R$ 190`, `-R$ 120`).
String brlSigned(num amount, {int decimals = 0}) {
  if (amount >= 0) return '+${brl(amount, decimals: decimals)}';
  return brl(amount, decimals: decimals);
}
