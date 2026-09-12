#!/usr/bin/env bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:0}"

KIOSK_URL="${KIOSK_URL:-https://jackrugile.github.io/artpi/}"

xset s off || true
xset -dpms || true
xset s noblank || true

if command -v unclutter-xfixes >/dev/null 2>&1; then
  pkill -x unclutter-xfixes >/dev/null 2>&1 || true
  unclutter-xfixes --idle 0 --root >/dev/null 2>&1 &
elif command -v unclutter >/dev/null 2>&1; then
  pkill -x unclutter >/dev/null 2>&1 || true
  unclutter -idle 0 -root >/dev/null 2>&1 &
fi

if command -v wtype >/dev/null 2>&1; then
  (
    sleep 2
    wtype -M alt -M logo -P h -m logo -m alt >/dev/null 2>&1 || true
  ) &
fi

if command -v chromium >/dev/null 2>&1; then
  BROWSER=chromium
elif command -v chromium-browser >/dev/null 2>&1; then
  BROWSER=chromium-browser
else
  echo "chromium is not installed" >&2
  exit 1
fi

pkill -f chromium >/dev/null 2>&1 || true
pkill -f chromium-browser >/dev/null 2>&1 || true
sleep 0.5

exec "$BROWSER" \
  --ozone-platform=x11 \
  --kiosk \
  --password-store=basic \
  --noerrdialogs \
  --disable-infobars \
  --disable-session-crashed-bubble \
  --incognito \
  --autoplay-policy=no-user-gesture-required \
  --check-for-update-interval=31536000 \
  "$KIOSK_URL"
