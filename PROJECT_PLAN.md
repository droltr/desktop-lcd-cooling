# Desktop LCD Cooling — Project Plan

## Classification

This is a Linux hardware-integration workspace combining a Zalman LCD integration, liquidctl, CoolerControl, and CoolerDash. It contains upstream source snapshots, a local integration/fix, installation and verification scripts, and an incident record. It is not Windows-specific.

## Current status

- A dated incident document records a successful LCD connection and repeated HTTP responses after a local fix.
- The root directory is an integration workspace rather than one clean upstream repository.
- Upstream components must remain distinguishable from local patches and the selected immutable revisions.
- Hardware state is not re-verified by this planning pass; no device write was performed.

## Plan

### 1. Provenance and source separation

- Identify the exact upstream repository, license, revision, and retrieval date for liquidctl, CoolerControl, and CoolerDash.
- Identify the local Zalman integration revision and every local patch.
- Keep upstream snapshots read-only; place local changes in a dedicated integration layer.
- Record dependency update and rollback procedures.

### 2. Incident and root-cause record

- Extract symptom, first failing layer, root cause, fix, validation, and remaining uncertainty from `docs/INCIDENT-2026-09-13.md`.
- Remove machine-specific paths and device identifiers from publishable documents; retain them only in private operational notes when necessary.
- Distinguish mocked/API validation from physical LCD verification.

### 3. Reproducible installation

- Review `scripts/install-zalman-fix.sh` for prerequisites, privilege boundaries, paths, idempotence, and rollback.
- Make `scripts/verify.sh` read-only and explicit about what it validates.
- Add dry-run and backup steps before service or driver changes.
- Document service ownership, restart behavior, and recovery if the display becomes unavailable.

### 4. Hardware safety

- Do not send experimental USB/display packets.
- Limit tests to the explicitly selected display and start with a static low-impact state.
- Require explicit authorization immediately before any physical write.
- Keep automated tests mock-only and record observed physical results separately.

### 5. Release readiness

- Run source, dependency, license, secret, privacy, and identifier scans.
- Validate Python/package metadata and service configuration.
- Confirm that local paths, device identifiers, and host-specific details are absent from public artifacts.
- Publish only after upstream provenance, rollback, and hardware validation are reviewed.

## Acceptance criteria

- A fresh operator can identify upstream versus local code.
- Installation is repeatable, reversible, and does not overwrite unknown files silently.
- Verification is read-only and reports clear evidence.
- Hardware tests have a selected target, low-impact first action, observed result, and rollback path.
- No public documentation contains machine-specific identifiers or credentials.
