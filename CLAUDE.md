# V Rising Wiki — Project Context for Claude Code

## Goal

Stand up a self-hosted MediaWiki instance as an independent alternative to the V Rising Fandom wiki. Deploy directly to a public Hetzner VPS (no local/Unraid phase). This repo holds the infra config (compose, docs, scripts) and is pushed to GitHub — the wiki itself runs on the VPS.

## Phases

### Phase 1 — Deploy to Hetzner VPS (current phase)
- Hetzner Cloud VPS (CX22-class is plenty to start), Docker Compose on the VPS
- Domain already owned — point it at the VPS from day one
- HTTPS via Caddy or Nginx + Let's Encrypt in front of MediaWiki
- All config (`LocalSettings.php`, `php.ini` overrides) in volumes/bind mounts — nothing baked into images
- A job runner must run continuously (sidecar container) — MediaWiki defers link-table updates and Cargo rebuilds to the job queue, so pages look stale without it
- **Anti-spam from day one** (wiki is public immediately): `ConfirmEdit` (captcha), `AbuseFilter`, restrict anonymous editing until the community warrants opening up
- The VPS will later also host a separate portfolio site (static, served by the same reverse proxy on another domain) — keep the proxy config structured for multiple sites

### Phase 2 — Content migration from Fandom
- **Text**: enumerate all pages via `Special:AllPages`/API, export in batches from `https://vrising.fandom.com/wiki/Special:Export` (XML). The exporter caps pages and revisions per request — batching is mandatory
- Import with CLI `importDump.php`, **not** Special:Import (web importer fails on large files / PHP upload limits)
- Preserve edit history (required for CC BY-SA attribution); also add a site-wide attribution notice pointing at the source wiki
- **Images are NOT in the XML export.** Fetch them separately (API `allimages` listing or file-page scrape) and import via `importImages.php`. Expect this to be the most tedious migration step
- Identify templates and Lua modules that need to be rebuilt/ported

### Phase 3 — Design and configuration
- Skin and theming
- Infobox templates for V Rising entities (bosses, weapons, crafting recipes, abilities, etc.)
- Review and iterate with collaborators

### Phase 4 — Portfolio site
- Separate static portfolio site on its own domain, served from the same VPS via the reverse proxy (or Cloudflare Pages if preferred — independent decision)

## Tech Stack (pinned)

- **Wiki software**: MediaWiki **1.43 LTS** (supported until Dec 2027). Pin the image tag (e.g. `mediawiki:1.43`) — never `:latest`. Extensions must match the `REL1_43` branch
- **Database**: MariaDB **11.4 LTS** (pinned major)
- **Containerization**: Docker Compose on the VPS
- **Host**: Hetzner Cloud VPS
- **Reverse proxy / TLS**: Caddy (automatic Let's Encrypt) — simplest for multi-site later
- **PHP overrides** (volume-mounted `php.ini`): raise `upload_max_filesize`, `post_max_size`, `memory_limit`, `max_execution_time` — needed for imports and VisualEditor

## Extensions to install

Bundled with 1.43 (just enable in `LocalSettings.php`):
- `ParserFunctions` — logic in wikitext
- `WikiEditor` — enhanced source editor toolbar
- `VisualEditor` — WYSIWYG editing (Parsoid is built in — no separate container; ignore old tutorials that add one)
- `Scribunto` — Lua scripting for templates
- `TemplateStyles` — scoped CSS in templates
- `ConfirmEdit`, `AbuseFilter` — **enabled from launch** (public wiki)

Install separately (`REL1_43` branch):
- `Cargo` — structured data/database for game entities (preferred over SMW for game wikis)
- `SearchDigest` (Weird Gloop, GPLv3, https://github.com/weirdgloop) — surfaces failed searches so missing content is easy to spot

## Backups

- Nightly `mariadb-dump` + rsync/restic of `/images` and config volume, retained **off the VPS** (e.g. Hetzner Storage Box or object storage)
- A restore from these artifacts must be tested **before** any content work begins (see "What to build first")

## Key constraints

- All persistent data (database, uploaded files, `LocalSettings.php`, `php.ini`) must be in volumes/bind mounts — nothing important inside containers
- Server moves should require only: DB dump, `/images` copy, `LocalSettings.php`, and updating `$wgServer`/DNS
- Pin all image versions; upgrades are deliberate, never automatic
- No secrets in the GitHub repo — `.env` is gitignored, `LocalSettings.php` lives only on the server and in backups

## What to build first

1. `docker-compose.yml` — MediaWiki 1.43 + MariaDB 11.4 + Caddy + job runner
2. Hetzner deploy doc (provision, harden, DNS, compose up)
3. First-run setup doc (web installer creates `LocalSettings.php`)
4. Post-install script to enable and configure extensions (incl. anti-spam)
5. Test teardown + restore from backup before doing any content work

## Reference links

- MediaWiki Docker image: https://hub.docker.com/_/mediawiki
- MediaWiki version lifecycle: https://www.mediawiki.org/wiki/Version_lifecycle
- Weird Gloop extensions: https://github.com/orgs/weirdgloop/repositories
- Fandom XML export: https://vrising.fandom.com/wiki/Special:Export
- Cargo extension docs: https://www.mediawiki.org/wiki/Extension:Cargo
- Scribunto docs: https://www.mediawiki.org/wiki/Extension:Scribunto
