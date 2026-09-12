# Art Pi

Always-on web art display for a Raspberry Pi. Chromium stays in kiosk mode on one GitHub Pages URL; that page cycles a playlist of art every five minutes.

## Playlist

Edit `playlist.json` and push to `main`. The kiosk refetches the playlist on each cycle, so new URLs show up without restarting the Pi.

```json
{
  "intervalSeconds": 300,
  "items": [
    {
      "url": "https://cdpn.io/pen/debug/bNqEPxE/4c80cfa9cede88965f45f7d5cd0a17f6",
      "title": "example"
    }
  ]
}
```

Set `durationSeconds` on an item to override the default interval for that piece.

**Iframe caveat:** the cycler loads each URL in a fullscreen iframe. Sites that send `X-Frame-Options` or a strict `frame-ancestors` CSP will not display. CodePen debug URLs usually work.

## Preview locally

```bash
npm run preview
```

## GitHub Pages

The site deploys from `main` via `.github/workflows/deploy.yml`.

One-time repo setup: **Settings → Pages → Source → GitHub Actions**. After the first successful run the display URL is:

`https://jackrugile.github.io/artpi/`

## Raspberry Pi setup (once)

On the Pi:

```bash
sudo apt update
sudo apt install -y unclutter-xfixes
```

(`unclutter` is fine if `unclutter-xfixes` is not available.)

From this repo on your Mac:

```bash
scp pi/kiosk.sh jackrugile@artpi.local:~/artpi-kiosk.sh
ssh jackrugile@artpi.local 'chmod +x ~/artpi-kiosk.sh'
```

Optional autostart after login (Raspberry Pi OS desktop). Create `~/.config/autostart/artpi-kiosk.desktop` on the Pi:

```ini
[Desktop Entry]
Type=Application
Name=Art Pi Kiosk
Exec=/home/jackrugile/artpi-kiosk.sh
X-GNOME-Autostart-enabled=true
```

Then start it:

```bash
npm run pi:kiosk
```

## Pi commands

Run from your Mac. All SSH to `jackrugile@artpi.local`.

| Command | What it does |
| --- | --- |
| `npm run pi:ssh` | Interactive shell |
| `npm run pi:kiosk` | Kill existing Chromium, start kiosk |
| `npm run pi:stop` | Stop Chromium |
| `npm run pi:status` | Hostname, uptime, Chromium process |
| `npm run pi:reboot` | Reboot the Pi |

`pi:reboot` prompts for a sudo password unless the Pi user can reboot without one.
