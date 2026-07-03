# Phase 3 — Design and Configuration Checklist

## Stage 1 — Foundation ✅ COMPLETE (2026-06-11)

- [x] Citizen skin v3.17.0 installed, dark default
      (`data/config/skins/Citizen`, `wfLoadSkin('Citizen')`,
      `$wgCitizenThemeDefault = 'dark'`)
- [x] Design tokens — `MediaWiki:Citizen.css`
      (V Rising palette: near-black surfaces, blood-red primary, muted gold
      accent; light theme variant; semantic `--vr-*` variables for templates)
- [x] Baseline content styles — `MediaWiki:Common.css`
      (wikitables, thumbnails, redlinks, visited links, category links,
      attribution notice class)
- [x] Main page shell — entry-point card grid
      (wikitext at `Main_Page`, TemplateStyles at
      `Template:Main_Page/styles.css`)
- [x] Branding assets (2026-07-03) — original fanged-V icon + wordmark SVGs,
      favicon, OG image in `assets/branding/`, served from
      `data/images/branding/`; `$wgLogos`/`$wgFavicon`/`$wgSitename`
      ("V Rising Wiki") wired in LocalSettings.php

## Stage 2 — Polish (after template porting)

- [x] Infobox system — `Module:Infobox` + per-entity wrappers (2026-07-03)
      (item, structure, equipment, ability, weapon, boss, enemy, ore node…)
      TemplateStyles at `Template:Infobox/styles.css`, Cargo tables per type
      (items, structures, equipment, abilities, weapons, bosses, enemies);
      rarity coloring via `--vr-rarity-*` tokens still TODO
- [x] Port broken templates (2026-07-03) — all Variables/DPL/PortableInfobox
      dependencies removed; Lua ports in `wiki-content/` (repo mirror,
      `scripts/push-wiki-content.sh` syncs to the wiki):
      - ItemFrame/ItemBox, Ability/AbilityFrame → Module:ItemFrame/AbilityIcon
      - Recipe/LocationFinder → Module:GameData (parses /data pages, no LST)
      - LootDrop/List Loot Sources → Cargo `loot_drops` (was DPL)
      - Screenshots → Module:Screenshots (needs TabberNeue — see below)
      - `$wgPFEnableStringFunctions = true` for `{{#replace:}}` et al.
- [ ] TabberNeue extension — bind mount is in docker-compose.yml and the
      REL1_43 clone step is documented; needs `docker compose up -d` +
      `wfLoadExtension( 'TabberNeue' )` (blocked on operator action)
- [ ] Navboxes — consistent footer navboxes across entity types
- [ ] Cargo query result styling — sortable list/table pages
- [ ] Light theme audit — full pass, WCAG AA contrast check
- [ ] Main page v2 — replace placeholders with featured content,
      recent patch notes, community links
- [ ] CommentStreams extension:
      - Install (`REL1_43` branch, bind-mount like Cargo)
      - Run `update.php` (creates comment tables)
      - Scope to NS_MAIN only; registered users only
      - Extend AbuseFilter + ConfirmEdit to comment namespace
      - Style against design tokens
- [ ] Collaborator review round

## SEO / discoverability (2026-07-03)

- [x] robots.txt served by Caddy; legacy `/wiki/` → `/w/` 301
- [x] Sitemap: `scripts/generate-sitemap.sh` → `/images/sitemap/`, daily cron
- [ ] Meta descriptions / OpenGraph tags — needs WikiSEO + PageImages +
      TextExtracts (REL1_43 bind mounts, same operator step as TabberNeue)
- [ ] Submit sitemap to Google Search Console

## Known follow-ups

- Search index was empty after CLI import — if search results look thin,
  re-run `maintenance/run.php rebuildtextindex`
- LocationFinder map links still point at the Fandom interactive map
  (Map:Vardoran) — no local equivalent yet
- Old Fandom template copies (`ItemFrameOld`, `AbilityFrameTest*`,
  `TemplateTester`, `Test2`) still exist; delete when convenient

## On-wiki CSS locations

Mirrors of all on-wiki CSS live in `config-snippets/` in this repo.
Edit there first, then paste to the wiki. Pages:

- `MediaWiki:Citizen.css` ← `config-snippets/Citizen.css`
- `MediaWiki:Common.css` ← `config-snippets/Common.css`
- `Template:Main_Page/styles.css` ← `config-snippets/main-page.css`

## Verification checklist (run before calling Phase 3 done)

- Cross-check at 360px / 768px / 1440px widths
- WCAG AA contrast on body text in both themes
- Side-by-side vs runescape.wiki and minecraft.wiki on: article, table-heavy
  page, main page, search, history/diff
- Logged-out view (most readers never log in)
- Collaborator sign-off
