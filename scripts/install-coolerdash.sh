#!/usr/bin/env bash
# Install a locally built CoolerDash into CoolerControl's plugin directory only.
# Unlike `make install`, nothing goes to /usr (immutable on Bazzite) and no
# packages are installed. uninstall-coolerdash.sh removes it again.
#
# Build first (in the coolerdash-build distrobox):
#   cd coolerdash && distrobox enter coolerdash-build -- make
# Then: sudo bash scripts/install-coolerdash.sh
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
src="$project_dir/coolerdash"
target=/var/lib/coolercontrol/plugins/coolerdash
stage="$target.new"
owner=${SUDO_USER:-}
token_file=${owner:+$(getent passwd "$owner" | cut -d: -f6)/.config/cc-token}

test "$(id -u)" -eq 0 || { echo "run with sudo" >&2; exit 1; }
test -x "$src/bin/coolerdash" || { echo "build $src first" >&2; exit 1; }
version=$(cat "$src/VERSION")

rm -rf "$stage"
mkdir -p "$stage/ui"
install -m 0755 "$src/bin/coolerdash" "$stage/coolerdash"
install -m 0644 "$src/etc/coolercontrol/plugins/coolerdash/ui/index.html" "$stage/ui/index.html"
install -m 0644 "$src/images/shutdown.png" "$stage/shutdown.png"
install -m 0644 "$src/README.md" "$src/CHANGELOG.md" "$src/VERSION" "$src/LICENSE" "$stage/"
sed -e "s/{{VERSION}}/$version/g" \
    -e "s|^executable = .*|executable = \"$target/coolerdash\"|" \
    "$src/etc/coolercontrol/plugins/coolerdash/manifest.toml" > "$stage/manifest.toml"
sed -i "s/{{VERSION}}/$version/g" "$stage/ui/index.html"

# Keep an existing config; otherwise start from the defaults with:
# - "zalman" allowlisted (CoolerDash otherwise drops ServicePlugin LCDs)
# - a font that exists on this host (Roboto is not installed)
if [ -f "$target/config.json" ]; then
    install -m 0600 "$target/config.json" "$stage/config.json"
else
    python3 - "$src/etc/coolercontrol/plugins/coolerdash/config.json" "$stage/config.json" <<'EOF'
import json, sys
src, dst = sys.argv[1:]
with open(src) as f:
    cfg = json.load(f)
cfg["device_detection"]["allowlist"] = "zalman"
cfg["font"]["face"] = "Lato Black"
with open(dst, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
EOF
    chmod 0600 "$stage/config.json"
fi

# Access token: keep existing credentials, else take the user's ~/.config/cc-token.
if [ -f "$target/credentials.json" ]; then
    install -m 0600 "$target/credentials.json" "$stage/credentials.json"
elif [ -n "$token_file" ] && [ -s "$token_file" ]; then
    python3 -c 'import json,sys; json.dump({"access_token": open(sys.argv[1]).read().strip()}, open(sys.argv[2], "w"))' \
        "$token_file" "$stage/credentials.json"
    chmod 0600 "$stage/credentials.json"
else
    echo "warning: no access token; CoolerDash cannot update the LCD until one is set in its UI" >&2
fi

rm -rf "$target"
mv "$stage" "$target"
# SELinux: let systemd execute the binary from /var/lib (label goes with the folder).
if command -v selinuxenabled >/dev/null && selinuxenabled; then
    chcon -t bin_t "$target/coolerdash"
fi
echo "CoolerDash $version installed to $target"
echo "Activate with: sudo systemctl restart coolercontrold"
