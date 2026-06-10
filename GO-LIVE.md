# Go-Live Checklist (human steps)

Everything in this repo is ready — compose stack, Caddy config, docs, scripts
(all tested). What remains needs *you*: accounts, money, DNS, and clicking
through the installer. Roughly 1–2 hours total.

## 1. Push this repo to GitHub (~2 min)

Create an empty repo on github.com, then locally:

```bash
git remote add origin git@github.com:<you>/v-rising-wiki.git
git push -u origin main
```

## 2. Buy the VPS (~10 min)

Hetzner Cloud → new project → new server: **CX22**, Ubuntu 24.04, add your SSH
key. ~€4/mo. Note the IP.

## 3. Point DNS (~5 min)

At your domain registrar: A record `wiki.yourdomain.com` → the VPS IP.
Do this *before* deploying — Caddy needs the DNS to resolve to issue the TLS cert.

## 4. Deploy (~30 min)

SSH in and follow `docs/hetzner-deploy.md` top to bottom: harden the box,
install Docker, clone your repo, set passwords in `.env`, set your real domain
in `caddy/Caddyfile`, `docker compose up -d`.

## 5. Run the MediaWiki installer (~15 min)

Follow `docs/first-run-setup.md`: web installer (your admin account, CC BY-SA
4.0 license), place `LocalSettings.php`, run `scripts/post-install.sh`, append
the generated snippet, enable the mounts, run `update.php`.

**One choice to make**: the anti-spam snippet includes two V Rising-themed
captcha questions for account creation. Review/replace them in the snippet —
custom questions only work if they're not googleable in 5 seconds.

## 6. Test backup AND restore (~20 min)

`docs/first-run-setup.md` §4. Do not skip — a backup you've never restored
doesn't exist. Then add the cron line for `scripts/backup.sh` and (recommended)
order a Hetzner Storage Box to ship backups off the VPS.

## 7. Open the doors

The wiki is now live and editable by anyone who creates an account (anonymous
editing is off, account creation is on, captcha-gated). To invite collaborators:
send them the URL — they self-register. Make trusted people admins at
`Special:UserRights` (add to `sysop`).

Quick sanity checks before announcing anywhere:
- `Special:Version` lists all extensions
- Create a second (non-admin) test account and make an edit
- Job queue drains (`Special:Statistics`)
- An image upload works

## What's deliberately NOT done yet

Phase 2 (Fandom content migration) starts only after step 6 passes. That's the
next session of work — export tooling, `importDump.php`, image fetching.
