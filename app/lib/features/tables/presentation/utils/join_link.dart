/// Constrói a URL pública que um convidado vai abrir.
///
/// Usa path routing (sem `#`) para funcionar tanto no web app (o Firebase
/// Hosting tem rewrite catch-all para index.html) quanto no app nativo via
/// universal links / deep links.
///
/// No web, prefere `Uri.base.origin` para refletir o domínio atual da página
/// (ex.: preview do Vercel). No mobile (`file:///`), `.origin` lança
/// StateError, então caímos no [webBaseUrl] vindo do `AppConfig`.
String buildJoinUrl(String tableId, String webBaseUrl) {
  final base = Uri.base;
  final isWeb = base.scheme == 'http' || base.scheme == 'https';
  final origin = isWeb ? base.origin : webBaseUrl;
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
