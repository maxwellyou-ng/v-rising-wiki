# V Rising Wiki — Infrastructure

Self-hosted MediaWiki alternative to the V Rising Fandom wiki, deployed on a
Hetzner VPS with Docker Compose. This repo contains infra config, docs, and
scripts — no secrets, no wiki content (that lives in the database and backups).

**Live at https://wiki.v-ris.ing** — Phase 1 complete, Phase 2 (content migration) in progress.

## Layout

- `docker-compose.yml` — Caddy (TLS) + MediaWiki 1.43 LTS + MariaDB 11.4 + job runner
- `caddy/Caddyfile` — reverse proxy config
- `docs/hetzner-deploy.md` — provision, harden, deploy (reference)
- `docs/first-run-setup.md` — installer, extensions, backup/restore test (reference)
- `scripts/post-install.sh` — fetches Cargo + SearchDigest, generates LocalSettings additions
- `scripts/backup.sh` — nightly DB dump + files tarball (cron at 2am)
- `config-snippets/` — php.ini overrides, generated LocalSettings snippet

## Phase 2 — Content migration

See `GO-LIVE.md` for the next steps: exporting from Fandom, importing with
`importDump.php`, and fetching images separately.

## License note

Wiki content is migrated from [vrising.fandom.com](https://vrising.fandom.com)
under CC BY-SA, with edit history preserved for attribution.
