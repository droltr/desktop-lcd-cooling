#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_file="$project_dir/zalman-Alpha2-DS-LCD-Linux/zalman_lcd/device.py"
target_file=/usr/local/lib/zalman-integration/zalman_lcd/device.py

test -f "$source_file"
python3 -m unittest discover -s "$project_dir/zalman-Alpha2-DS-LCD-Linux/tests" -v
sudo install -m 0644 "$source_file" "$target_file"
sudo systemctl restart coolercontrold.service
systemctl --no-pager --full status coolercontrold.service cc-plugin-coolerdash.service
sha256sum "$source_file" "$target_file"

