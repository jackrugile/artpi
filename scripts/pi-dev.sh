#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-4173}"
HOST="${ARTPI_HOST:-jackrugile@artpi.local}"
started_serve=0
serve_pid=""

cleanup() {
  if [[ "$started_serve" -eq 1 && -n "$serve_pid" ]]; then
    kill "$serve_pid" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

if curl -sf "http://127.0.0.1:${PORT}" >/dev/null 2>&1; then
  echo "Using existing preview on http://127.0.0.1:${PORT}"
else
  npx --yes serve . -l "$PORT" &
  serve_pid=$!
  started_serve=1

  for _ in $(seq 1 40); do
    if curl -sf "http://127.0.0.1:${PORT}" >/dev/null 2>&1; then
      break
    fi
    if ! kill -0 "$serve_pid" >/dev/null 2>&1; then
      echo "preview server failed to start" >&2
      exit 1
    fi
    sleep 0.25
  done

  echo "Preview at http://127.0.0.1:${PORT}"
fi

echo "Tunneling to ${HOST} and starting kiosk. Leave this session open."
echo "Ctrl+C stops the tunnel. Run npm run pi:kiosk to point back at GitHub Pages."

# Expand ~ on the Pi, not this Mac.
ssh -t -R "${PORT}:127.0.0.1:${PORT}" "$HOST" \
  "KIOSK_URL=http://127.0.0.1:${PORT} nohup bash \$HOME/artpi-kiosk.sh > /tmp/artpi-kiosk.log 2>&1 & echo; echo 'Kiosk is using your Mac preview.'; echo 'Keep this SSH session open.'; exec bash -l"
