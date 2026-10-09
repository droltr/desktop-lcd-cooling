# Open work

Last updated: 2026-10-09

Plugin-level work is tracked as GitHub issues in
[droltr/cc-plugin-zalman-lcd](https://github.com/droltr/cc-plugin-zalman-lcd/issues).
This file lists only workspace-level items.

## Open

- [ ] Run the test plan: [docs/TEST-PLAN.md](docs/TEST-PLAN.md) (plugin issues #2 and #4).
- [ ] Decide on the pull requests #7 (type hints) and #8 (docs) into `develop`.
- [ ] Upstream follow-ups after reviewing `zalman-cc-plugin/docs/upstream.md`:
      CoolerControl UI bug (#1), CoolerDash display profile (#5).
- [ ] Rotate the CoolerControl access token `zalman` (it appeared in a chat
      transcript), then update CoolerDash's token from its plugin page.
- [ ] Make `coolerdash/` independent of the archived repository (today it is a
      worktree of `_archive/CoolingAndLcd/coolerdash-master-3.3.3-2026-10-09`).
      For example, fork CoolerDash on GitHub and push `zalman-alpha2-profile` there.
- [ ] Merge duplicate checkouts (`../dev/`, `../zalman-source/`, `../LCD/`) into a
      single source of truth (scattered hardware repos).

## Superseded (2026-10-09)

The plan from 2026-10-02 was to port the coolercontrold patch to 5.0.1, rebuild
the daemon, and keep a `sudo pip` liquidctl driver in `/usr/local`. After the
Bazzite reinstall, that approach was dropped in favour of a CoolerControl
device-service plugin. The plugin needs no daemon patch, no liquidctl driver,
and no writes to `/usr`. See [docs/WORKLOG-2026-10-09.md](docs/WORKLOG-2026-10-09.md).
