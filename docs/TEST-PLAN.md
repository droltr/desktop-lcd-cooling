# Test plan — Zalman LCD stack

Status: **planned, not started.** Covers plugin issues
[#2 unit tests](https://github.com/droltr/cc-plugin-zalman-lcd/issues/2) and
[#4 robustness](https://github.com/droltr/cc-plugin-zalman-lcd/issues/4).

Tests run one at a time. Each test has an owner, the action needed from the
user, the checks Claude runs afterwards, and a pass criterion. Results are
recorded in the table at the end and copied to the GitHub issue.

## Track A — unit tests (no hardware, no user action)

Done in the plugin repository on `feature/unit-tests`, opened as a PR into `develop`.

| # | Test | Pass criterion |
|---|---|---|
| A1 | `ListDevices` with and without the panel (patched `find_tty`) | one 320×320 `lcd` device / empty list |
| A2 | `Health` OK / WARNING | status matches presence |
| A3 | `Lcd image`: brightness, orientation, image path forwarded to a fake `LcdClient` | calls recorded in order |
| A4 | Orientation mapping 0/90/180/270 → 0/270/180/90 | exact values |
| A5 | `none` → blank; unknown mode → `INVALID_ARGUMENT` | — |
| A6 | Unknown device or channel → `NOT_FOUND` | — |
| A7 | Driver `OSError`/`DeviceError` → `UNAVAILABLE`, error logged | — |
| A8 | `InitializeDevice` / `Shutdown` close the client; `Shutdown` sets the stop event | — |
| A9 | Fan, lighting and custom RPCs → `UNIMPLEMENTED` | — |
| A10 | CI: GitHub Actions runs `ruff format --check`, `ruff check`, `pytest --cov` | green; coverage ≥ 80 % excluding `gen/` |

## Track B — hardware robustness (user action required)

Before every B test Claude records a baseline: service states, the last 50 journal
lines of `coolercontrold`, `cc-plugin-zalman-lcd` and `cc-plugin-coolerdash`, and any
SELinux AVC denials since boot. After the user's action Claude collects the same
data and compares.

| # | Test | What the user does | What Claude checks | Pass criterion |
|---|---|---|---|---|
| B1 | Long run | Leave CoolerDash running ≥ 30 min. Glance at the panel at start, middle and end. Report any freeze. | Plugin errors, `UNAVAILABLE`, reconnects; `coolerdash.png` mtime keeps advancing | Panel updates throughout, no errors |
| B2 | Daemon restart | Nothing (Claude asks before running `sudo systemctl restart coolercontrold`, or the user runs it) | Plugin reconnects; saved LCD setting re-applied; CoolerDash resumes | Panel back within ~10 s |
| B3 | USB replug | Unplug the LCD's internal USB cable (or the AIO's USB header), wait 10 s, plug it back. Note the time. | `find_tty` fallback in the logs, new USB address in `dmesg`, panel updates resume | Panel resumes without restarting anything |
| B4 | Suspend / resume | Suspend the PC, wait 1 min, wake it. | `InitializeDevice` called after resume; plugin reconnects | Panel resumes within one refresh cycle |
| B5 | Reboot | Reboot normally. | Both plugins start at boot; no AVC denials; panel shows CoolerDash | Panel live after login without manual steps |
| B6 | CoolerControl UI "None" | In the CoolerControl UI select LCD mode **None** and save. | Plugin receives `none` (only if the UI sends it; see #1) | Panel goes black; selecting Image again via CoolerDash restores it |
| B7 | Reversibility | Run `zalman-cc-plugin/uninstall.sh` and `scripts/uninstall-coolerdash.sh`, then reinstall both. | Folders gone after uninstall; no leftover units or sockets; after reinstall everything works | Clean removal and clean reinstall |

### What Claude will ask from the user

- Run one physical action at a time (B1–B6) and report what the panel shows: a
  short description or a photo, plus the time.
- Run the sudo commands Claude provides (restart, uninstall/reinstall), because
  sudo needs the user's password.
- For B3: confirm which cable was unplugged.

### Order

B2 → B1 → B3 → B4 → B5 → B6 → B7. Least disruptive first. B7 last because it
removes the working setup.

## Results

| # | Date | Result | Notes |
|---|---|---|---|
| | | | |
