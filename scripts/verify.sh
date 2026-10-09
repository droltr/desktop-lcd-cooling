#!/usr/bin/env bash
set -euo pipefail

systemctl is-active coolercontrold.service cc-plugin-coolerdash.service
test -e /dev/ttyACM0
readlink -f /sys/class/tty/ttyACM0/device/driver
liquidctl list --verbose
journalctl -u coolercontrold.service -u cc-plugin-coolerdash.service \
  --since '-2 minutes' --no-pager | \
  grep -E 'Zalman LCD connected|Zalman LCD overlay updated|PUT /devices/.*/screen|502 Bad Gateway|Matching LCD'

