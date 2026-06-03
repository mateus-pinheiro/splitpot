/// Constrói a URL pública que um convidado vai abrir.
///
/// Usa path routing (sem `#`) para funcionar tanto no web app (o Firebase
/// Hosting tem rewrite catch-all para index.html) quanto no app nativo via
/// universal links / deep links.
///
/// No web, prefere `Uri.base.origin` para refletir o domínio atual da página
/// (ex.: preview do Vercel). No mobile (`file:///`), `.origin` lança
/// StateError, então caímos no origin do [webBaseUrl] vindo do `AppConfig`.
///
/// O PWA é servido sob um sub-path (ex.: `/app`) em produção. Esse prefixo vem
/// do path de [webBaseUrl] e é mantido na URL pública para que o link caia na
/// rota de join do app, e não na home do site de marketing na raiz.
String buildJoinUrl(String tableId, String webBaseUrl) {
  final cfg = Uri.parse(webBaseUrl);
  final base = Uri.base;
  final isWeb = base.scheme == 'http' || base.scheme == 'https';
  final origin = isWeb ? base.origin : cfg.origin;
  final appPath = cfg.path.replaceFirst(RegExp(r'/+$'), ''); // ex.: "/app"
  return '$origin$appPath/table/$tableId/join';
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
