# Desktop LCD Cooling

Workspace for driving the **Zalman ALPHA2 DS** AIO LCD on Linux through
CoolerControl and CoolerDash. It holds the sources, local patches, install
scripts and records for this machine. It is a workspace, not a single
repository: each component keeps its own git history.

## Current state (2026-10-09)

Working on Bazzite 44 (rpm-ostree, SELinux enforcing):

```
CoolerDash 3.3.5 ──REST──▶ CoolerControl 5.0.1 (rpm) ──gRPC──▶ cc-plugin-zalman-lcd ──▶ zalman_lcd driver ──▶ LCD
```

- Hardware: HWCX-TECH USB Display `0483:5740`, `cdc_acm`, `/dev/ttyACM0`, 320×320, square.
- CoolerControl and liquidctl are the stock rpm packages. Nothing is patched in `/usr`.
- Everything we install lives in two folders, each removable with one script:
  - `/var/lib/coolercontrol/plugins/zalman-lcd/` (our plugin)
  - `/var/lib/coolercontrol/plugins/coolerdash/` (CoolerDash with a Zalman profile)
- Full CoolerControl backup taken before any change: `backups/coolercontrol-20261009-015634-full/` (contains secrets, never publish).

See [docs/WORKLOG-2026-10-09.md](docs/WORKLOG-2026-10-09.md) for what was done and
why, and [docs/TEST-PLAN.md](docs/TEST-PLAN.md) for the open verification work.

## Layout

| Path | What it is | Git |
|---|---|---|
| `zalman-cc-plugin/` | CoolerControl device-service plugin (ours) | [droltr/cc-plugin-zalman-lcd](https://github.com/droltr/cc-plugin-zalman-lcd) |
| `zalman-Alpha2-DS-LCD-Linux/` | LCD driver (fork of bl3xand's, MIT) | [droltr/zalman-Alpha2-DS-LCD-Linux](https://github.com/droltr/zalman-Alpha2-DS-LCD-Linux) |
| `coolerdash/` | CoolerDash 3.3.5 + Zalman display profile, branch `zalman-alpha2-profile` | git worktree of `_archive/CoolingAndLcd/coolerdash-master-3.3.3-2026-10-09` |
| `coolercontrol/` | Upstream CoolerControl source (reference only) | upstream clone |
| `scripts/` | Backup, install, uninstall and smoke-test scripts | — |
| `docs/` | Plan, work log, test plan, incident records | — |
| `backups/` | CoolerControl backups (secrets) | ignored |

## Common tasks

```bash
# Full CoolerControl backup (config, tokens, plugins)
sudo bash scripts/backup-coolercontrol.sh

# Plugin install / remove
sudo bash zalman-cc-plugin/install.sh && sudo systemctl restart coolercontrold
sudo bash zalman-cc-plugin/uninstall.sh

# CoolerDash build (distrobox "coolerdash-build", Fedora 44) and install / remove
(cd coolerdash && distrobox enter coolerdash-build -- make)
sudo bash scripts/install-coolerdash.sh && sudo systemctl restart coolercontrold
sudo bash scripts/uninstall-coolerdash.sh

# Drive the panel directly, without CoolerControl (needs access to /dev/ttyACM0)
.venv/bin/python scripts/lcd-smoke-test.py
```

## Obsolete

`scripts/install-zalman-fix.sh` and `scripts/verify.sh` belong to the pre-reinstall
setup (patched coolercontrold and a liquidctl driver in `/usr/local`). That setup
no longer exists, and the scripts are kept for reference only. See
[docs/INCIDENT-2026-09-13.md](docs/INCIDENT-2026-09-13.md).
