/// Constrói a URL pública que um convidado vai abrir.
///
/// Usa path routing (sem `#`) para funcionar tanto no web app (o Firebase
/// Hosting tem rewrite catch-all para index.html) quanto no app nativo via
/// universal links / deep links.
///
/// No iOS/Android, `Uri.base` é `file:///` e `.origin` lança StateError —
/// por isso verificamos o scheme antes de acessar `.origin`.
String buildJoinUrl(String tableId) {
  final base = Uri.base;
  final isWeb = base.scheme == 'http' || base.scheme == 'https';
  final origin = isWeb ? base.origin : 'https://splitpot.app';
  return '$origin/table/$tableId/join';
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
