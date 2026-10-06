#!/usr/bin/env bash
# One-command private WireGuard VPN (wg-easy) for a small group of friends.
# Usage (on a fresh Ubuntu 22.04/24.04 VPS, as root):
#   curl -fsSL https://raw.githubusercontent.com/cajyben/onestate-vpn/main/install.sh | bash
set -euo pipefail

echo "==> Private VPN installer"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this as root (or with sudo)."; exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "==> Installing Docker..."
  curl -fsSL https://get.docker.com | sh
fi

PUBLIC_IP=$(curl -fsSL https://api.ipify.org || curl -fsSL https://ifconfig.me)
echo "==> Server public IP: $PUBLIC_IP"

if [ -z "${VPN_ADMIN_PASSWORD:-}" ]; then
  read -rsp "Choose an admin panel password: " VPN_ADMIN_PASSWORD </dev/tty; echo
fi
HASH_LINE=$(docker run --rm ghcr.io/wg-easy/wg-easy:14 wgpw "$VPN_ADMIN_PASSWORD")
PASSWORD_HASH=$(echo "$HASH_LINE" | sed -E "s/^PASSWORD_HASH='(.*)'$/\1/")

docker rm -f wg-easy >/dev/null 2>&1 || true
docker run -d \
  --name=wg-easy \
  -e LANG=en \
  -e WG_HOST="$PUBLIC_IP" \
  -e PASSWORD_HASH="$PASSWORD_HASH" \
  -e WG_DEFAULT_DNS=1.1.1.1 \
  -e WG_PERSISTENT_KEEPALIVE=25 \
  -v /root/.wg-easy:/etc/wireguard \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy:14

if command -v ufw >/dev/null 2>&1; then
  ufw allow OpenSSH >/dev/null
  ufw allow 51820/udp >/dev/null
  ufw allow 51821/tcp >/dev/null
  ufw --force enable >/dev/null
fi

echo
echo "==> Done."
echo "Admin panel:  http://$PUBLIC_IP:51821"
echo "Add one client per friend there and send them their QR code privately."
echo "When everyone is added, close the panel:  ufw delete allow 51821/tcp"
