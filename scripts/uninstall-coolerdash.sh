#!/usr/bin/env bash
# Remove the CoolerDash plugin installed by install-coolerdash.sh.
# Usage: sudo bash scripts/uninstall-coolerdash.sh
set -euo pipefail
test "$(id -u)" -eq 0 || { echo "run with sudo" >&2; exit 1; }
rm -rf /var/lib/coolercontrol/plugins/coolerdash /var/lib/coolercontrol/plugins/coolerdash.new
systemctl restart coolercontrold
echo "CoolerDash plugin removed"
