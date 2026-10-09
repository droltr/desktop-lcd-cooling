# Fan calibration and profiles — proposal

Status: **proposed 2026-10-09, not applied.** Request #12 in `docs/REQUESTS.md`:
quiet whenever possible, **all fans at 100 % above 80 °C (CPU)**.

## Inventory (CoolerControl 5.0.1, live at 05:2x)

| Device / channel | Label | Now | Calibrated | Notes |
|---|---|---|---|---|
| nct6687 `fan1` | CPU Fan | 951 rpm @ 22 % | ✅ min stable 20 %, 1938 rpm max | AIO radiator fans (assumed) |
| nct6687 `fan2` | Pump Fan | 1860 rpm @ 39 % | ✅ min 0 %, max effective 95 %, 3342 rpm | Zalman AIO pump (assumed) |
| nct6687 `fan3` | System Fan #1 | 539 rpm @ 25 % | ❌ | connected |
| nct6687 `fan7` | System Fan #5 | 543 rpm @ 25 % | ❌ | connected |
| nct6687 `fan8` | System Fan #6 | 572 rpm @ 25 % | ❌ | connected |
| nct6687 `fan4` `fan5` `fan6` | System Fan #2–4 | 0 rpm | — | nothing connected |
| RTX 5080 `fan1` `fan2` | GPU fans | 0 rpm (zero-RPM idle) | ✅ ~3380 rpm max | driver accepts 30–100 % only |

All channels are currently **Unmanaged** (only the Default profile exists).
Temperature sources: CPU `k10temp temp1` (Tctl); GPU `GPU Temp`.

## Step 1 — calibrate the three system fans

CoolerControl's calibration ramps each fan through its range (loud for about 1–2 minutes
per fan) and records min start/stable duty and the rpm curve. Run it for `fan3`, `fan7` and
`fan8`, one at a time, with the owner present.

## Step 2 — profiles (CPU = Tctl, GPU = GPU Temp)

A smoothing function (`Standard`: response delay 3 s, deviance 2 °C, faster up than down)
is applied to every profile, so short spikes do not make the fans surge.

| Profile | Source | Curve (°C → duty %) | Used by |
|---|---|---|---|
| **CPU Radiator** | CPU | 45→25 · 55→30 · 65→45 · 72→65 · 78→85 · **80→100** | `fan1` |
| **Pump** | CPU | 40→55 · 60→65 · 70→75 · 78→90 · **80→100** | `fan2` |
| **Case (CPU)** | CPU | 45→25 · 60→35 · 70→55 · 77→80 · **80→100** | via Mix |
| **Case (GPU)** | GPU | 50→25 · 65→40 · 75→70 · 82→100 | via Mix |
| **Case** = Mix(max) of Case (CPU) and Case (GPU) | — | the higher of both | `fan3` `fan7` `fan8` |
| **GPU** | GPU | 50→30 · 60→35 · 70→55 · 78→80 · 83→100 | via Mix |
| **CPU Emergency** | CPU | 79→0 · **80→100** | via Mix |
| **GPU Fans** = Mix(max) of GPU and CPU Emergency | — | GPU curve, but 100 % when CPU ≥ 80 °C | RTX `fan1` `fan2` |

Duties below a fan's calibrated minimum are raised to that minimum by CoolerControl.
GPU fans stay at or above 30 % (driver limit) while managed. Alternative: leave them in
driver auto (zero-RPM idle) and give up the "100 % above 80 °C CPU" rule for the GPU fans.

## Step 3 — verify

CoolerControl stress test: CPU for 3 minutes, then GPU for 3 minutes. Watch the
curves; confirm 100 % on all fans once CPU Tctl ≥ 80 °C, and quiet idle afterwards.

## Revert

Set every channel back to **Default (Unmanaged)**, or restore
`backups/coolercontrol-20261009-015634-full/etc-coolercontrol/config.toml`.

## Result of step 1 (2026-10-09 05:29–05:34): calibration failed

CoolerControl's calibration of `fan3`, `fan7` and `fan8` stopped at the first write:

```text
Error on nct6687:fan3 for duty 45 - Unable to set PWM value 115 for /sys/class/hwmon/hwmon3/pwm3 Reason: Input/output error (os error 5)
kernel: nct6687: The device rejected new configuration as invalid
```

The same kernel message already appeared at 01:35 (the first calibration run, when the CPU
fan and pump calibrated successfully).

- Driver: out-of-tree `nct6687d` (`/lib/modules/…/extra/nct6687d/nct6687.ko.xz`), shipped by
  Bazzite, loaded with `fan_config=msi_alt1`. All `pwmN_enable = 2`, i.e. firmware curve mode.
- On MSI boards this driver writes a manual duty by rewriting the firmware fan curve. The
  board's EC rejected the curve for the system-fan channels.
- The driver has `msi_fan_brute_force` ("write to all 7 curve points"), which exists for this
  case. It is currently off.
- The fans were left untouched at their previous duty (25 %).

Next: try the module option (needs root, reversible), see the chat proposal, or set the
system fans' curves in the BIOS (Hardware Monitor) and leave them unmanaged.

### Owner's earlier experience (recorded 2026-10-09)

The same failure happened before the reinstall. Calibration could not run because the
**BIOS fan limits** constrained the channels. Fix that worked: in the BIOS (Hardware Monitor)
set the affected fans to **full speed / maximum** and leave them there. The fans then run at
full speed until the OS boots, and CoolerControl takes over and manages them.

Plan:
1. Owner: reboot into BIOS → Hardware Monitor → set System Fan 1, 5 and 6 (and check the CPU fan
   and pump) to full speed / no custom curve → save and reboot.
2. Claude: re-run calibration for `fan3`, `fan7` and `fan8`. While each one ramps, the owner names
   the physical fan (header mapping, request #14).
3. Apply the profiles above (GPU fans stay in driver auto, request #15).

The `msi_fan_brute_force=1` driver option stays as a fallback if the BIOS change is not enough.
