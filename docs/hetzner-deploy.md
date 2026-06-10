# Hetzner Deploy

## 1. Provision

1. Hetzner Cloud → new server: **CX22** (2 vCPU / 4 GB) is plenty to start, Ubuntu 24.04 LTS, add your SSH key
2. DNS: A record for `wiki.yourdomain` → server IP

## 2. Harden (5 minutes, do it first)

```bash
apt update && apt upgrade -y
adduser deploy && usermod -aG sudo deploy
rsync -a ~/.ssh /home/deploy/ && chown -R deploy:deploy /home/deploy/.ssh
# /etc/ssh/sshd_config: PasswordAuthentication no, PermitRootLogin no
systemctl restart ssh
ufw allow OpenSSH && ufw allow 80 && ufw allow 443 && ufw enable
apt install -y fail2ban unattended-upgrades
```

## 3. Install Docker & deploy

```bash
curl -fsSL https://get.docker.com | sh
usermod -aG docker deploy

# as deploy:
git clone <your-github-repo> ~/vrising-wiki && cd ~/vrising-wiki
cp .env.example .env && nano .env        # strong passwords; never commit .env
mkdir -p data/{db,images,config/extensions,caddy/data,caddy/config}
cp config-snippets/php-overrides.ini data/config/php-overrides.ini
nano caddy/Caddyfile                     # set your real domain
docker compose up -d
```

## 4. First-run setup

Follow `docs/first-run-setup.md` (web installer → LocalSettings.php → extensions
→ job runner → **backup/restore test before any content work**).

Because the wiki is public immediately, anti-spam is enabled at launch — the
post-install LocalSettings snippet turns on ConfirmEdit + AbuseFilter and
disables anonymous editing by default.

## 5. Backups (off-box)

Nightly cron on the VPS using `scripts/backup.sh` (DB dump + images/config
tarball, prunes after 14 days):

```bash
sudo mkdir -p /backups && sudo chown deploy /backups
crontab -e   # add:
# 0 3 * * * cd /home/deploy/vrising-wiki && ./scripts/backup.sh >> /var/log/wiki-backup.log 2>&1
```

Ship `/backups` off the VPS — a Hetzner Storage Box (~€4/mo, BX11) with rsync or
restic is the easy answer. Test a restore before importing content.
