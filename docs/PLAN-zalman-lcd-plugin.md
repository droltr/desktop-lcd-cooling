# Zalman ALPHA2 DS LCD — reversible setup plan

Date: 2026-10-09. System: Bazzite 44 (rpm-ostree), coolercontrold 5.0.1 (rpm),
liquidctl 1.16.0 (rpm).

**Status: steps 0–4 done; step 5 moved to [TEST-PLAN.md](TEST-PLAN.md).** The
outcome is recorded in [WORKLOG-2026-10-09.md](WORKLOG-2026-10-09.md).

## Assessment

- Hardware and kernel are fine: `0483:5740` → `cdc_acm` → `/dev/ttyACM0`
  (`root:dialout 0660`; the user is not in `dialout`).
- CoolerControl does not see the LCD: `liquidctl devices found: []`. The old
  solution (a patched coolercontrold plus a liquidctl driver installed with pip
  under `/usr/local`) was lost in the reinstall. Upstream liquidctl and
  CoolerControl have no Zalman support.
- The panel protocol and the driver code are available in
  `zalman-Alpha2-DS-LCD-Linux/zalman_lcd`. `LcdClient` in `client.py`
  (`set_image`, `set_brightness`, `set_orientation`) writes static frames to the
  RLE overlay rather than to flash, so continuous updates carry a low freeze risk.

## Approach: a CoolerControl device-service plugin

The CoolerControl 5 plugin API (`cc-plugins`, gRPC) supports LCD channels:
- `ListDevices` reports the device with an `LcdInfo` (320×320, mode list, maximum image size).
- `Lcd(LcdRequest)` carries the mode, brightness, orientation and **the path of the
  image that CoolerControl has already processed** (`image_path`).

The plugin forwards these calls straight to `LcdClient`. The Zalman panel then
appears as a regular LCD device in CoolerControl, and CoolerDash draws to it
through the REST API.

Why this approach:
- No changes to rpm packages, `/usr` or rpm-ostree layers. Everything lives in one
  folder under `/var/lib/coolercontrol/plugins/<name>/`.
- CoolerControl updates do not break the plugin, as long as the plugin API stays stable.
- Rollback means deleting the folder and restarting `coolercontrold`.

## Everything that changes on the system

| What | Where | Rollback |
|---|---|---|
| Zalman plugin (Python code + venv) | `/var/lib/coolercontrol/plugins/zalman-lcd/` | `zalman-cc-plugin/uninstall.sh` |
| CoolerDash plugin (binary + config) | `/var/lib/coolercontrol/plugins/coolerdash/` | `scripts/uninstall-coolerdash.sh` |
| CoolerControl settings (LCD setting, access token) | `/etc/coolercontrol/*` | restore from `backups/coolercontrol-20261009-015634-full/` |
| Build container (CoolerDash only) | `~/.local/share/containers` (distrobox) | `distrobox rm coolerdash-build` |

**Not done:** `rpm-ostree install/override`, `sudo pip` into `/usr`, patching
coolercontrold, a permanent udev rule (to be discussed separately if needed).

## Steps

Each step is done and verified on its own. If a step fails, return to the previous one.

### 0. Backup — done
- [x] Readable files under `/etc/coolercontrol` plus UI data → `backups/coolercontrol-20261009-014359/`
- [x] Full backup including root-only files → `backups/coolercontrol-20261009-015634-full/` (`scripts/backup-coolercontrol.sh`)
- Restore: `sudo systemctl stop coolercontrold`, copy the files back, `start`.

### 1. Panel test, no permanent change — done
- [x] User venv in the workspace (`.venv/`; Pillow, numpy, psutil).
- [x] Temporary access to `/dev/ttyACM0`: `sudo setfacl -m u:drol:rw /dev/ttyACM0`
      (gone after a reboot or replug).
- [x] `scripts/lcd-smoke-test.py`: test card, brightness and orientation confirmed on the panel.
      Note: the driver rotates counter-clockwise.

### 2. Plugin development, still no system change — done
- [x] `zalman-cc-plugin/`: Python gRPC service with stubs generated from `cc-plugins/proto`.
- [x] `Health`, `ListDevices`, `InitializeDevice`, `Status`, `Lcd` → `LcdClient`,
      `Shutdown` → `close()`. Fan and RGB calls return `UNIMPLEMENTED`.
- [x] `manifest.toml`: `type = "device"`, `privileged = true`.
- [x] End-to-end test as a normal user with `test_client.py`: "PLUGIN OK" shown on the panel.

### 3. Install into CoolerControl, first system change — done
- [x] `sudo bash zalman-cc-plugin/install.sh && sudo systemctl restart coolercontrold`.
- [x] SELinux blocked `run.sh` (`init_t` → `var_lib_t` execute). Fixed with
      `chcon -t bin_t run.sh` in `install.sh`.
- [x] The device shows up in CoolerControl. An image applied through the REST API appears on the panel.
- [x] v0.1.1: orientation inverted to match CoolerControl's clockwise angles; `none` blanks the panel.
- [!] CoolerControl's UI cannot apply plugin LCD images (CoolerControl bug; plugin issue #1).

### 4. CoolerDash — done
- [x] 3.3.5 built in the `coolerdash-build` distrobox (Fedora 44).
- [x] Square-panel patch: entry added to `display_profiles[]` in
      `src/device/profile.c` (branch `zalman-alpha2-profile`, commit `70bc178`).
- [x] Installed with `scripts/install-coolerdash.sh` into the plugin folder only, with
      `device_detection.allowlist = "zalman"`, font `Lato Black`, and the token in `credentials.json`.
- [x] Temperatures shown on the panel and filling the square screen (confirmed by the user).

### 5. Robustness tests and records — moved
See [TEST-PLAN.md](TEST-PLAN.md).

## Risks / open questions

- **Python version:** the plugin venv is tied to the system Python (3.14). If Bazzite
  upgrades Python, re-run `install.sh` to rebuild it. An alternative is a
  `uv`-managed venv that carries its own Python.
- **Privileges:** `privileged = true` runs the plugin as root. A narrower alternative is
  to run it unprivileged with a udev rule for this one device.
- **CoolerDash source:** `coolerdash/` is a git worktree of an archived repository
  (see [TODO.md](../TODO.md)).
