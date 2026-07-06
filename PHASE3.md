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
- [x] TabberNeue extension — installed and on Special:Version (2026-07-06)
- [x] Navboxes (2026-07-05) — generic `Template:Navbox` (`.vr-navbox-*`
      classes in Common.css); `Navbox Weapons` refactored onto it; V Blood
      navbox migration still open
- [x] Cargo query result styling (2026-07-05) — `.cargoTable` +
      `.article-table` styled in Common.css, `.vr-table-scroll` wrapper
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

## Stage 3 — Reference-wiki parity (from 2026-07-05 UX review)

Derived from a product/UX review of minecraft.wiki, stardewvalleywiki.com,
and wiki.leagueoflegends.com (27 pages surveyed). Full plan:
`~/.claude/plans/review-these-wikis-https-minecraft-wiki-federated-planet.md`.

- [x] **Weapons → Cargo table** (2026-07-06) — sortable all-weapons
      `#cargo_query` live (numeric declare + cargoRecreateData done;
      needed the Cargo aliasing backport, see Known follow-ups)
- [ ] **Remaining list pages → Cargo tables** — armor, consumables,
      structures, bosses as sortable Cargo query tables; dual index on
      hubs (icon grid to browse + sortable table to compare); keep
      "Removed …" archive sections standardized at page end
- [x] **Project:Style guide** (2026-07-05) — live at
      `V Rising Wiki:Style guide` with `VRW:STYLE` shortcut; universal
      section sequence, per-page-type layouts, Brutal/PvP sections,
      linking/naming/image rules
- [ ] **Normalize top-traffic pages to the style guide** — bosses and
      weapon classes first
- [ ] **Guide: namespace** — `$wgExtraNamespaces` for long-form guides
      (Getting started, castle building, boss strategies); reference pages
      link out instead of embedding strategy; guides hub by progression;
      "outdated as of patch X" banner for stale guides (operator step:
      LocalSettings.php edit)
- [ ] **Patch pages** — one article per game update: infobox, Additions/
      Changes/Fixes with icon-linked entities, date-stamped hotfixes,
      prev/next patch nav + patch navbox; backfill majors (1.0, 1.1 …)
- [ ] **Update history convention** — per-page reverse-chronological
      section, "increased to X from Y" notation, **Bug Fix:**/**Removed:**
      prefixes; superseded values migrate here, never linger in body text
- [ ] **Redirect pass** — boss short names, plurals, alt spellings,
      ability names; monthly SearchDigest review mines failed searches
      into new redirects
- [ ] **Index pages** for ambiguous concepts (e.g. `Blood` → Blood types,
      Blood Essence, V Blood, Blood Moon) — linkable index, not disambig
- [ ] **Hub pages** behind every main-page card (Bosses = V Blood grid by
      level + sortable table; footnote markers for exceptions)
- [ ] **Main page routing rows** — "New vampire?" → Guide:Getting started;
      "Latest patch" → newest patch article; community links
- [ ] **Accessibility** — `alt=` required in Module:ItemFrame /
      Module:Infobox image params; real header cells with `scope` in
      generated tables; table `overflow-x` wrapper for mobile; WCAG AA
      incl. rarity colors on dark
- [ ] **Community scaffolding** — Project:How to help, Template:Stub /
      Template:Outdated (patch param) + tracking categories, `/doc`
      subpages for all templates and modules

## SEO / discoverability (2026-07-03)

- [x] robots.txt served by Caddy; legacy `/wiki/` → `/w/` 301
- [x] Sitemap: `scripts/generate-sitemap.sh` → `/images/sitemap/`, daily cron
- [ ] Meta descriptions / OpenGraph tags — needs WikiSEO + PageImages +
      TextExtracts (REL1_43 bind mounts; verified still missing from
      Special:Version 2026-07-06 — TabberNeue made it in, these didn't)
- [ ] Submit sitemap to Google Search Console

## Known follow-ups

- **Local Cargo patch (2026-07-06)**: MW ≥ 1.43.2 changed DB table
  aliasing; Cargo 3.7 (and its frozen REL1_43 branch) generates broken SQL
  (`cargo__weapons._pageID` against an aliased FROM) for non-aggregating
  `#cargo_query` backlink tracking. Upstream 3.9.2's
  `mwUsesOldDBAliasing()` fix ships as
  `patches/cargo-mw1432-db-aliasing.patch` (the `data/` extension clones
  are gitignored — apply on the VPS per `patches/README.md`). Remove when
  Cargo is upgraded to ≥ 3.8 — treat that upgrade as its own deliberate
  task.
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
