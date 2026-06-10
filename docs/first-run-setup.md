# First-Run Setup

## 0. Prerequisites

- VPS provisioned and stack running (`docs/hetzner-deploy.md`)
- DNS resolving, Caddy serving your domain over HTTPS
- `data/config/php-overrides.ini` in place (from `config-snippets/`)
- mediawiki container running **without** a LocalSettings.php mount

## 1. Run the web installer

1. Open `https://wiki.yourdomain` — "Please set up the wiki first"
2. Database settings:
   - Type: MariaDB
   - Host: `db`
   - Database: `vrising_wiki`, user `wiki`, password from `.env`
3. Wiki name: **V Rising Wiki**. Create the admin account.
4. License: **CC BY-SA 4.0** (required — content is derived from Fandom's CC BY-SA wiki)
5. Tick the bundled extensions: `ParserFunctions`, `WikiEditor`, `VisualEditor`,
   `Scribunto`, `TemplateStyles`, `ConfirmEdit`, `AbuseFilter`
6. Finish — the installer offers `LocalSettings.php` as a download

## 2. Install LocalSettings.php

1. Place the downloaded file at `data/config/LocalSettings.php` on the server
2. Run `scripts/post-install.sh` (fetches Cargo + SearchDigest, prints the
   LocalSettings additions) and append the snippet — it includes the launch
   anti-spam config (captcha on account creation/anon actions, anon editing off)
3. Set `$wgServer = "https://wiki.yourdomain";`
4. Uncomment the LocalSettings.php + extensions mounts in `docker-compose.yml`
   (both `mediawiki` and `jobrunner`), then `docker compose up -d`
5. Inside the mediawiki container: `php maintenance/run.php update --quick`
   (creates Cargo/SearchDigest/AbuseFilter tables)
6. Verify `Special:Version` lists everything

## 3. Verify the job runner

Edit any page, then check `Special:Statistics` — the job queue should drain to 0.

## 4. Backup/restore test (do this BEFORE any content work)

```bash
# Backup
docker compose exec db mariadb-dump -uroot -p"$DB_ROOT_PASSWORD" vrising_wiki > backup.sql
tar czf files.tgz -C data images config

# Destroy: docker compose down, move data/ aside, recreate empty dirs

# Restore: untar files, docker compose up -d db, then
docker compose exec -T db mariadb -uroot -p"$DB_ROOT_PASSWORD" vrising_wiki < backup.sql
docker compose up -d
# verify pages, history, an uploaded image, and login
```

If the restored wiki is identical, the backup story is proven and content
migration (Phase 2) can begin.
