# V Rising Wiki — Project Context for Claude Code

## Goal

Stand up a self-hosted MediaWiki instance as an independent alternative to the V Rising Fandom wiki. Deploy directly to a public Hetzner VPS (no local/Unraid phase). This repo holds the infra config (compose, docs, scripts) and is pushed to GitHub — the wiki itself runs on the VPS.

## Current status

**Phase 2 — Content migration from Fandom**

Live at https://wiki.v-ris.ing. Phase 1 fully complete: stack deployed, all
extensions active, anti-spam running, backup/restore tested, nightly cron set.

## VPS access

```bash
ssh -i ~/.ssh/hetzner_vrising deploy@5.78.219.66
```

Repo lives at `/home/deploy/vrising-wiki` on the VPS. Commands that touch the
live wiki (imports, maintenance scripts, docker compose) run there via this
SSH connection — assume this when generating commands.

## Phases

### Phase 1 — Deploy to Hetzner VPS ✅ COMPLETE
- Hetzner CX22, Ubuntu 24.04, Docker Compose
- wiki.v-ris.ing live with HTTPS via Caddy
- MediaWiki 1.43.8, MariaDB 11.4.12, PHP 8.3
- All extensions installed and verified (see Special:Version)
- Anti-spam active: QuestyCaptcha on account creation, AbuseFilter on edits with external links, anonymous editing off
- Nightly backup cron running at 2am (scripts/backup.sh)
- Backup/restore tested before content work began

### Phase 2 — Content migration from Fandom (current phase)
- **Text**: enumerate all pages via `Special:AllPages`/API, export in batches from `https://vrising.fandom.com/wiki/Special:Export` (XML). The exporter caps pages and revisions per request — batching is mandatory
- Import with CLI `importDump.php`, **not** Special:Import (web importer fails on large files / PHP upload limits)
- Preserve edit history (required for CC BY-SA attribution); also add a site-wide attribution notice pointing at the source wiki
- **Images are NOT in the XML export.** Fetch them separately (API `allimages` listing or file-page scrape) and import via `importImages.php`. Expect this to be the most tedious migration step
- Identify templates and Lua modules that need to be rebuilt/ported

### Phase 3 — Design and configuration
- Skin and theming: Citizen skin, dark default, game-styled branding — see `docs/theming-plan.md` and `docs/theme-mockup.html` (approved direction)
- Infobox templates for V Rising entities (bosses, weapons, crafting recipes, abilities, etc.)
- **Article comments** via Extension:CommentStreams (`REL1_43` branch, bind-mounted like Cargo):
  - `wfLoadExtension` + run `update.php` (creates comment tables)
  - Scope to `NS_MAIN` only; exclude comment namespace from search
  - `cs-comment` for registered users only (no anon, consistent with edit policy); `cs-moderator-*` for sysops
  - Extend AbuseFilter external-link rule + ConfirmEdit captcha to the comment namespace before enabling — comments are the top spam target
  - Style against the theme design tokens in `MediaWiki:Common.css`
  - Note: Fandom comments are not in the XML export — section starts empty
- Review and iterate with collaborators

## Tech Stack (pinned)

- **Wiki software**: MediaWiki **1.43 LTS** (supported until Dec 2027). Pin the image tag (e.g. `mediawiki:1.43`) — never `:latest`. Extensions must match the `REL1_43` branch
- **Database**: MariaDB **11.4 LTS** (pinned major)
- **Containerization**: Docker Compose on the VPS
- **Host**: Hetzner Cloud VPS (CX22)
- **Domain**: wiki.v-ris.ing
- **Reverse proxy / TLS**: Caddy (automatic Let's Encrypt)
- **PHP overrides** (volume-mounted `php.ini`): raise `upload_max_filesize`, `post_max_size`, `memory_limit`, `max_execution_time` — needed for imports and VisualEditor

## Extensions installed

Bundled with 1.43:
- `ParserFunctions` — logic in wikitext
- `WikiEditor` — enhanced source editor toolbar
- `VisualEditor` — WYSIWYG editing (Parsoid built in)
- `Scribunto` — Lua scripting for templates
- `TemplateStyles` — scoped CSS in templates
- `ConfirmEdit` + `QuestyCaptcha` — captcha on account creation and edits with external links
- `AbuseFilter` — edit heuristics

Installed separately:
- `Cargo` 3.7 — structured data/database for game entities
- `SearchDigest` 1.5.1 — surfaces failed searches

## Backups

- Nightly `mariadb-dump` + tarball of `/images` and config, cron at 2am
- Backup script: `scripts/backup.sh`
- Restore tested ✅ — verified before any content work

## Key constraints

- All persistent data (database, uploaded files, `LocalSettings.php`, `php.ini`) must be in volumes/bind mounts — nothing important inside containers
- Server moves should require only: DB dump, `/images` copy, `LocalSettings.php`, and updating `$wgServer`/DNS
- Pin all image versions; upgrades are deliberate, never automatic
- No secrets in the GitHub repo — `.env` is gitignored, `LocalSettings.php` lives only on the server and in backups

## Reference links

- MediaWiki Docker image: https://hub.docker.com/_/mediawiki
- MediaWiki version lifecycle: https://www.mediawiki.org/wiki/Version_lifecycle
- Weird Gloop extensions: https://github.com/orgs/weirdgloop/repositories
- Fandom XML export: https://vrising.fandom.com/wiki/Special:Export
- Cargo extension docs: https://www.mediawiki.org/wiki/Extension:Cargo
- Scribunto docs: https://www.mediawiki.org/wiki/Extension:Scribunto
- importDump.php docs: https://www.mediawiki.org/wiki/Manual:ImportDump.php
- importImages.php docs: https://www.mediawiki.org/wiki/Manual:ImportImages.php
- Citizen skin: https://github.com/StarCitizenTools/mediawiki-skins-Citizen
- CommentStreams docs: https://www.mediawiki.org/wiki/Extension:CommentStreams
