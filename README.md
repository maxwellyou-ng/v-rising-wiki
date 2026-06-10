# V Rising Wiki — Infrastructure

Self-hosted MediaWiki alternative to the V Rising Fandom wiki, deployed on a
Hetzner VPS with Docker Compose. This repo contains infra config, docs, and
scripts — no secrets, no wiki content (that lives in the database and backups).

## Layout

- `docker-compose.yml` — Caddy (TLS) + MediaWiki 1.43 LTS + MariaDB 11.4 + job runner
- `caddy/Caddyfile` — reverse proxy config
- `docs/hetzner-deploy.md` — provision, harden, deploy
- `docs/first-run-setup.md` — installer, extensions, backup/restore test
- `scripts/post-install.sh` — fetches Cargo + SearchDigest, generates LocalSettings additions
- `config-snippets/` — php.ini overrides, generated LocalSettings snippet

## Quick start

See `docs/hetzner-deploy.md`. Never commit `.env` or `LocalSettings.php`.

## License note

Wiki content is migrated from [vrising.fandom.com](https://vrising.fandom.com)
under CC BY-SA, with edit history preserved for attribution.
