/// Constrói a URL pública que um convidado vai abrir.
///
/// Flutter web usa hash routing por default, então o link fica com `/#/…`.
/// Em mobile `Uri.base.origin` é vazio — caímos num placeholder até termos
/// deep-link real. Quando tivermos domínio de prod, trocar o fallback.
String buildJoinUrl(String tableId) {
  final origin =
      Uri.base.origin.isEmpty ? 'https://splitpot.app' : Uri.base.origin;
  return '$origin/#/table/$tableId/join';
}

/// Código curto exibido pro usuário (6 chars, uppercase). É só os primeiros
/// caracteres do cuid — não é único globalmente, mas o suficiente como
/// identificador rápido pra falar/digitar.
String shortTableCode(String tableId) {
  if (tableId.isEmpty) return '';
  return tableId
      .substring(0, tableId.length.clamp(0, 6))
      .toUpperCase();
}
