#!/usr/bin/env bash
# Register this overlay with Portage. Run as root (doas/sudo).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF=/etc/portage/repos.conf/sonarp.conf

mkdir -p /etc/portage/repos.conf
cat > "${CONF}" << EOF
[sonarp]
location = ${ROOT}
masters = gentoo
auto-sync = no
EOF

ln -sfn "${ROOT}" /var/db/repos/sonarp
echo "Registered sonarp overlay at ${ROOT}"
echo "Next: emerge -av media-libs/libgp_parser media-sound/sonarpractice"
