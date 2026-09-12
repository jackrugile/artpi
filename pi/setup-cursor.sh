#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
if ! sudo apt-get install -y unclutter-xfixes wtype; then
  sudo apt-get install -y unclutter wtype
fi

mkdir -p "$HOME/.config/labwc"

if [[ ! -f "$HOME/.config/labwc/rc.xml" && -f /etc/xdg/labwc/rc.xml ]]; then
  cp /etc/xdg/labwc/rc.xml "$HOME/.config/labwc/rc.xml"
fi

python3 - <<'PY'
from pathlib import Path

bind = """    <keybind key="A-W-h">
      <action name="HideCursor" />
      <action name="WarpCursor" x="-1" y="-1" />
    </keybind>
"""
path = Path.home() / ".config" / "labwc" / "rc.xml"
if not path.exists():
    path.write_text(
        '<?xml version="1.0"?>\n<labwc_config>\n  <keyboard>\n'
        + bind
        + "  </keyboard>\n</labwc_config>\n"
    )
    raise SystemExit(0)

text = path.read_text()
if "HideCursor" in text:
    raise SystemExit(0)

if "<keyboard>" in text:
    text = text.replace("<keyboard>", "<keyboard>\n" + bind, 1)
else:
    closer = "</labwc_config>" if "</labwc_config>" in text else "</openbox_config>"
    section = "  <keyboard>\n" + bind + "  </keyboard>\n"
    if closer in text:
        text = text.replace(closer, section + closer, 1)
    else:
        text += "\n" + section
path.write_text(text)
PY

autostart="$HOME/.config/labwc/autostart"
touch "$autostart"
chmod +x "$autostart"
if ! grep -q "wtype -M alt -M logo" "$autostart"; then
  printf '%s\n' "sleep 2; wtype -M alt -M logo -P h -m logo -m alt" >>"$autostart"
fi

if [[ -f "$HOME/.config/wayfire.ini" ]] && ! grep -q "hide_cursor" "$HOME/.config/wayfire.ini"; then
  if grep -q "^\[core\]" "$HOME/.config/wayfire.ini"; then
    python3 - <<'PY'
from pathlib import Path
path = Path.home() / ".config" / "wayfire.ini"
text = path.read_text()
text = text.replace("[core]", "[core]\nhide_cursor = true", 1)
path.write_text(text)
PY
  else
    printf '\n[core]\nhide_cursor = true\n' >>"$HOME/.config/wayfire.ini"
  fi
fi

labwc --reconfigure >/dev/null 2>&1 || true
wtype -M alt -M logo -P h -m logo -m alt >/dev/null 2>&1 || true

echo "Cursor hide is configured. Restart the kiosk or reboot."
