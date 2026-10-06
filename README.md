# Private game VPN

A private WireGuard VPN for a small group of friends, so they can connect to the game from a server outside India.

> **This repo does not run the VPN.** GitHub only stores code and hosts static pages. The VPN itself runs on a small VPS you rent (around $4–$6/month). This repo gives you a one-command installer and a guide page you can send to friends.

## What's in here

| File | What it does |
|---|---|
| `install.sh` | Sets up the VPN server (Docker + wg-easy + firewall) in one command |
| `docs/index.html` | A friend-facing guide, published with GitHub Pages |

## Admin setup (you do this once)

1. **Rent a VPS** with Ubuntu 22.04 or 24.04. Pick a region where the game works and ping to India is low (UAE or Singapore are good). Hetzner, DigitalOcean, Vultr and Contabo all work.
2. **SSH in as root** and run:
```bash
   curl -fsSL https://raw.githubusercontent.com/cajyben/onestate-vpn/main/install.sh | bash
```
3. **Open the admin panel** at `http://YOUR_SERVER_IP:51821`, log in, and click **New Client** once per friend.
4. **Send each friend their QR code privately** (WhatsApp, Discord DM). Never post configs or QR codes in this repo: anyone with one can use your server.
5. **Close the panel** when you're done adding people: `ufw delete allow 51821/tcp`. Reopen it with `ufw allow 51821/tcp` when you need to add someone.

## Publish the friend guide

1. Repo **Settings → Pages**.
2. Source: **Deploy from a branch**, branch `main`, folder `/docs`.
3. Share the link: `https://cajyben.github.io/onestate-vpn/`

## Notes

- Keep the repo **public** only if you're fine with people seeing the installer (it contains no secrets). Configs and QR codes live only on your server.
- Games with anti-cheat may block VPN IPs or ban accounts that use them. Check the game's terms before your friends use it on their main accounts.
- To remove someone, delete or disable their client in the admin panel.
