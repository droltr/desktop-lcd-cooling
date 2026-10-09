#!/usr/bin/env bash
# Full CoolerControl backup (config, secrets, plugins). Run with sudo.
# Usage: sudo scripts/backup-coolercontrol.sh [target_dir]
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
target=${1:-"$project_dir/backups/coolercontrol-$(date +%Y%m%d-%H%M%S)-full"}
owner=${SUDO_USER:-$(id -un)}

mkdir -p "$target"
cp -a /etc/coolercontrol "$target/etc-coolercontrol"
cp -a /var/lib/coolercontrol "$target/var-lib-coolercontrol"
{
    rpm-ostree status
    rpm -q coolercontrol coolercontrold liquidctl
} > "$target/system-state.txt" 2>&1
chown -R "$owner:" "$target"
# Secrets stay readable only by the owner.
chmod -R go-rwx "$target"
echo "Backup written to $target"
