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
- [ ] Branding assets — logo/wordmark, favicon, OpenGraph image
      (`$wgLogos`, `$wgFavicon` in LocalSettings.php; game-styled original art,
      not Stunlock sprites)

## Stage 2 — Polish (after template porting)

- [ ] Infobox system — base template + per-entity variants
      (boss, weapon, gear, recipe, ability, creature)
      TemplateStyles + Cargo-backed; rarity coloring via `--vr-rarity-*` tokens
- [ ] Port broken templates — priority order:
      1. Infobox templates (currently rendering raw XML on article pages)
      2. Navigation templates
      3. Cargo table declarations
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
