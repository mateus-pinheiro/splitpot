#!/usr/bin/env bash
#
# Monta o diretório que o Firebase Hosting publica:
#   public/            -> site de marketing (raiz, www.splitpot.com.br)
#   public/app/        -> PWA Flutter (www.splitpot.com.br/app)
#
# Os --dart-define abaixo têm defaults de produção embutidos em
# app/lib/core/config/app_config.dart, então rodar sem variáveis de ambiente
# ainda gera um build válido. No CI eles vêm de secrets.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$ROOT/public"

echo "▸ Limpando $DIST"
rm -rf "$DIST"
mkdir -p "$DIST"

echo "▸ Copiando site de marketing para a raiz"
cp -R "$ROOT/site/." "$DIST/"

echo "▸ Buildando o PWA Flutter (base-href=/app/)"
(
  cd "$ROOT/app"
  flutter build web \
    --release \
    --base-href=/app/ \
    ${API_BASE_URL:+--dart-define=API_BASE_URL="$API_BASE_URL"} \
    ${WEB_BASE_URL:+--dart-define=WEB_BASE_URL="$WEB_BASE_URL"} \
    ${FIREBASE_WEB_API_KEY:+--dart-define=FIREBASE_WEB_API_KEY="$FIREBASE_WEB_API_KEY"} \
    ${GOOGLE_CLIENT_ID:+--dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID"}
)

echo "▸ Copiando build do PWA para public/app"
cp -R "$ROOT/app/build/web" "$DIST/app"

echo "✓ Pronto. Publique com: firebase deploy --only hosting"
