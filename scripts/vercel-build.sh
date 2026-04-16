#!/usr/bin/env bash
# Builds Flutter web into ./public for Vercel CDN + FastAPI same-origin API.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Prefer explicit dashboard env (e.g. custom domain); then Vercel preview/prod URL.
if [[ -n "${API_PUBLIC_URL:-}" ]]; then
  API_BASE_URL="$API_PUBLIC_URL"
elif [[ -n "${VERCEL:-}" ]] && [[ -n "${VERCEL_URL:-}" ]]; then
  if [[ "${VERCEL_URL}" =~ ^https?:// ]]; then
    API_BASE_URL="${VERCEL_URL}"
  else
    API_BASE_URL="https://${VERCEL_URL}"
  fi
else
  API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:8000}"
fi

if ! command -v flutter >/dev/null 2>&1; then
  export FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"
  if [[ ! -f "$FLUTTER_HOME/bin/flutter" ]]; then
    echo "Installing Flutter (stable) to $FLUTTER_HOME..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_HOME"
  fi
  export PATH="$FLUTTER_HOME/bin:$PATH"
fi

flutter --version
flutter config --no-analytics --enable-web
cd "$ROOT/trading_mobile"
flutter pub get
flutter build web --release --dart-define="API_BASE_URL=${API_BASE_URL}"

mkdir -p "$ROOT/public"
rm -rf "${ROOT:?}/public/"*
cp -r "$ROOT/trading_mobile/build/web/"* "$ROOT/public/"
echo "Copied Flutter build to $ROOT/public (API_BASE_URL=${API_BASE_URL})"
