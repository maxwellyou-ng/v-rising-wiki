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
- [x] **Remaining list pages → Cargo tables** (2026-07-06) — Armours,
      Consumables, Structures (dump page rewritten; hatnote to Castle
      Building), V Blood Carriers; dual index kept (curated sections +
      sortable all-X table). equipment table went numeric
      (gear_level/durability → Integer, pre-flighted clean); armour/
      jewelry category backfill still outstanding (see Known follow-ups)
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
- [x] **Patch pages** (2026-07-06) — Patch 1.0 + Patch 1.1 backfilled
      (curated Additions/Changes/Fixes + date-stamped hotfix sections);
      EA majors stubbed (Secrets of Gloomrot, Bloodfeast, Early Access
      Release); Template:Navbox Patches; Patch Notes is the version-index
      hub with major rows linked
- [x] **Update history convention** (2026-07-05/06) — defined in the
      style guide §Update history; patch articles use the notation.
      Rolling it out to entity pages happens with the style-guide
      normalization item above
- [x] **Redirect pass** (2026-07-06) — initial pass:
      `wiki-content/redirects.tsv` (94 redirects: boss short names,
      plurals/spellings, patch aliases) via `scripts/push-redirects.sh`
      - [ ] monthly SearchDigest review mines failed searches into new
            redirects (recurring)
- [x] **Index pages** (2026-07-06) — resolved as hatnotes per the style
      guide (primary topic + hatnote, no separate index): Blood now
      routes Blood Essence / V Blood / Blood Moon / Blood Potion
- [x] **Hub pages** (2026-07-06) — audit: Bosses hub = upgraded V Blood
      Carriers (Cargo table + by-act table); Weapons/Castle Building/
      Crafting/Servants/Abilities all adequate
- [x] **Main page routing rows** (2026-07-06) — routing strip: Journal
      starter link, Cargo-driven "Latest patch", Patch Notes, Guides,
      style guide. "New vampire?" points at Journal until the Guide:
      namespace ships (Guide:Getting started still open above)
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

- **equipment category/type backfill (2026-07-06)**: `equipment.category`
  is NULL on ~137/144 rows and `type` only set for Bag/Jewelry, so the
  Armours page shows an all-equipment table — an armour-only filter needs
  `type=` backfilled on ~110 entity pages first
- **bosses.level stays String deliberately (2026-07-06)**: all values are
  two-digit (16–91, one "80+"), so lexical sort is correct; revisit only
  if a single-digit or 100+ boss ever ships
- **structures.unlocked_by** has raw Fandom HTML-span junk on a few rows —
  clean the source pages when convenient
- **pages.txt** is regenerated from the live wiki now (allpages API; the
  Phase-2 file was empty); `pages-redirects.txt` alongside it, both
  gitignored

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
