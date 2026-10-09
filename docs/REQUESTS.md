# Requests log

Every request from the owner that concerns this workspace, newest last.
Status: ✅ done · 🔄 in progress · ⏳ planned · ❓ needs a decision.

## 2026-10-09

| # | Request | Status | Where |
|---|---|---|---|
| 1 | Review the CoolerControl plugin list and explain it | ✅ | chat |
| 2 | Back up CoolerControl before trying plugins | ✅ | `backups/coolercontrol-20261009-015634-full/`, `scripts/backup-coolercontrol.sh` |
| 3 | Get the Zalman LCD working with CoolerDash; find out whether the driver problem is solved | ✅ | `docs/WORKLOG-2026-10-09.md` |
| 4 | Plan it reversibly, without harming the system | ✅ | `docs/PLAN-zalman-lcd-plugin.md` |
| 5 | Plugin repository: git, GitHub, commits, PRs, issues, milestones; follow the coding rules | ✅ | [cc-plugin-zalman-lcd](https://github.com/droltr/cc-plugin-zalman-lcd) |
| 6 | Translate all written docs to English; gitignore everything except code and needed files | ✅ | this folder, `.gitignore`, `.claudeignore` |
| 7 | Leave PRs #7, #8, #9 unmerged for now | ✅ | — |
| 8 | Explain upstream; write a note for upstream maintainers in the repo | ✅ | `zalman-cc-plugin/docs/upstream.md` (PR #9) |
| 9 | Record today's work; plan tests as a separate track | ✅ | `docs/WORKLOG-2026-10-09.md`, `docs/TEST-PLAN.md` |
| 10 | Today's stack replaces all earlier CoolerControl/LCD work; keep CoolerControl and CoolerDash forks current for our own fixes; our plugin first | ⏳ | `TODO.md` |
| 11 | Fix the plugin homepage link (it opened the driver repo) | ✅ | PR [#10](https://github.com/droltr/cc-plugin-zalman-lcd/pull/10) |
| 12 | CoolerControl fan calibration and automatic fan profiles: quiet when possible, all fans at 100 % above 80 °C | 🔄 blocked | `docs/setup/fan-profiles.md`; system-fan PWM writes rejected by nct6687 |
| 13 | Record every request; code always in a project; every settings change documented in the owning project | ✅ | this file; `docs/setup/` |
| 14 | Fan header mapping: "needs testing" | ⏳ | identify by spinning one header at a time |
| 15 | GPU fans: (a) leave in driver auto (zero-RPM) | ✅ decided | `docs/setup/fan-profiles.md` |
| 16 | Commit email must be the GitHub noreply address; owner approved the force-push | ✅ | 5 repositories rewritten and force-pushed; 2 local-only commits amended |
| 17 | Check that the updated repositories' docs match the code | ✅ | findings in chat; RGB docs updated |
| 18 | Update the GitHub profile description | ✅ | `droltr/droltr` README, Recent Work |
| 19 | Follow and control Claude sessions from the phone | ⏳ | answered in chat (Remote Control) |
| 20 | Explain the status line | ✅ | chat |
| 21 | Short GitHub bio | ❓ | needs `gh auth refresh -s user` by the owner |
| 22 | Merge cc-plugin PRs into main if they work | ✅ | PRs #7–#10 → develop, release PR #11 → main, tag/release v0.1.2 |
| 23 | Put the driver fork in order | ✅ | `droltr/zalman-Alpha2-DS-LCD-Linux` PR #1 → main, tag/release v0.2.0 |
| 24 | Fans: BIOS limits blocked calibration before; set BIOS to full speed, then CoolerControl manages | ⏳ | owner action in BIOS, see `docs/setup/fan-profiles.md` |
| 25 | Remote Control: once for all terminals or per terminal? | ✅ | answered in chat |
| 26 | Add the status line | ✅ | `host-setup/docs/setup/claude-statusline.md` |
| 27 | Does working across several projects cause path or repo conflicts? | ✅ | answered in chat |
| 28 | Are Discord hooks sending anything? | ✅ | no Discord hook configured |
| 29 | CoolerDash colours set to the same stops as the LEDs (done by the owner in the CoolerDash page) | ✅ | owner |
| 30 | LCD: under CPU the fan RPM shows only a dash; under GPU it shows the CPU fan RPM — show the GPU fan RPM there | 🔄 | cause found in `coolerdash/src/mods/split.c`: the CPU pane takes RPM from a "Liquidctl" device (none here; the AIO fans are on nct6687), the GPU pane takes the first GPU-type RPM sensor. Owner chose the radiator fans (`nct6687 fan1`). Implemented in `coolerdash/` branch `zalman-alpha2-profile`, commit `2298b5f`: new `display.cpu_rpm_sensor` + "CPU Fan Speed Source" selector in the CoolerDash page; installed; owner selected nct6687 fan1 RPM; radiator RPM now shown under CPU ✅ |

RGB requests are logged in `Coding/RgbLighting/cc-plugin-thermal-rgb/docs/REQUESTS.md`;
terminal requests in `Coding/DevelopmentEnvironment/host-setup/docs/setup/`.
| 31 | Reach the GPU LEDs afterwards | ⏳ | project `RgbLighting/gpu-rgb-rtx5080` |
| 32 | LCD GPU column stayed blue although RPM was right | ✅ | cause: two GPUs (amdgpu iGPU 41 °C listed first, RTX 5080 52 °C); the legacy "gpu" slot took the iGPU for temperature, load and power. Owner chose option (b): code fix `f76355e` prefers the GPU that reports fan RPM; installed 18:2x, owner confirmed the GPU column is correct ✅ |
| 33 | Are all changes written to the repo of the related hardware? | ✅ | audit: pushed coolerdash branch and thermal phase 2; created private repos desktop-lcd-cooling and host-setup |
