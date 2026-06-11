# Theming Plan — Gloop-tier quality

Goal: visual quality on par with [Weird Gloop wikis](https://weirdgloop.org) (runescape.wiki, minecraft.wiki, etc.). Decisions: **Citizen skin**, **dark default**, **game-styled branding**, **foundation now / polish after content migration**.

## What makes Gloop wikis look good

From [their theming docs](https://meta.weirdgloop.org/w/Themes) and inspecting the wikis, the quality comes from five things, none of which require their infrastructure:

1. **Design tokens** — a single CSS-variable palette that every element (infoboxes, tables, navboxes, buttons) draws from. No one-off colors.
2. **Dark + light themes** as first-class citizens, switchable, respecting `prefers-color-scheme`.
3. **A designed main page** — grid layout, entry-point cards, featured content. Not a wall of links.
4. **A consistent infobox/table system** — one visual language for all entity types, styled centrally.
5. **Game-flavored identity** — logo, accent colors, and subtle texture from the game, applied with restraint.

Gloop does this with Vector 2010 + thousands of lines of custom Less. Citizen gets us ~70% of the way out of the box (responsive, dark mode, modern typography, sticky header, styled extension UIs), so our custom CSS budget goes into the V Rising identity instead of fixing skin basics.

## Stage 1 — Foundation (now, before/during content import)

### 1.1 Install Citizen

- [StarCitizenTools/mediawiki-skins-Citizen](https://github.com/StarCitizenTools/mediawiki-skins-Citizen) — pin the **latest release tagged compatible with MW 1.43** (do not track `main`; v3 development targets newer Codex). Bind-mount like Cargo/SearchDigest: `data/config/skins/Citizen`.
- `wfLoadSkin( 'Citizen' ); $wgDefaultSkin = 'citizen';`
- Citizen is fully responsive → **no MobileFrontend/Minerva needed** (one theme to maintain instead of two — this is the big win over copying Gloop's Vector+Minerva split).
- Keep Vector installed as a fallback user preference.
- Config: `$wgCitizenThemeDefault = 'dark';` (toggle + OS preference respected built-in).
- Verify against our extension set: VisualEditor, Cargo tables, AbuseFilter, SearchDigest pages all render sanely.

### 1.2 Branding assets (game-styled)

- Logo/wordmark in V Rising's gothic style + favicon + OpenGraph image (`$wgLogos`, `$wgFavicon`).
- Note: game-styled means *evoking* Stunlock's art direction (palette, blackletter-adjacent display type, ornamental flourishes), not copying UI sprites wholesale. Screenshots/renders on content pages are normal fan-wiki fair use; the site chrome should be original work in the game's style.

### 1.3 Design tokens — `MediaWiki:Citizen.css`

Citizen themes via [CSS variable overrides](https://github.com/StarCitizenTools/mediawiki-skins-Citizen/wiki/Adapting-Citizen-styles). Define the palette once:

- **Dark (default)**: near-black surfaces with a cool/desaturated cast (V Rising's night palette), blood-red primary accent, muted gold secondary (matches in-game rarity/UI accents), high-contrast off-white text. Restraint: red is for accents and interactive states, not large surfaces.
- **Light**: parchment-leaning neutrals, same red/gold accents darkened for contrast.
- Define our *own* semantic variables too (`--vr-rarity-*`, `--vr-infobox-*`, etc.) in `MediaWiki:Common.css` so templates never hardcode colors — this is the Gloop discipline that makes everything cohere.
- Typography: a gothic display face for headings/wordmark (self-hosted woff2, no Google Fonts CDN), clean sans for body. Test long-form readability before committing.

### 1.4 Main page shell

- Grid of entry-point cards (Bosses, Weapons, Crafting, Castle, Servants, Spells…) built with TemplateStyles, themed via the tokens.
- Works at mobile widths; placeholder sections for "featured" content to fill post-migration.

### 1.5 Baseline content styling

- `MediaWiki:Common.css`: wikitable styling (both themes), thumbnails/galleries, TOC, redlinks/visited links tuned for dark backgrounds.
- Site-wide attribution notice (CC BY-SA, required) styled to be present but unobtrusive.

**Stage 1 exit criteria:** imported Fandom pages land on a wiki that already looks intentional — correct palette, logo, readable tables — even before templates are rebuilt.

## Stage 2 — Polish (after Phase 2 template/module porting)

1. **Infobox system**: one base infobox template (TemplateStyles + Cargo-backed) with per-entity variants — boss, weapon, gear, recipe, ability, creature. Single visual language: header bar, image frame, labeled rows, rarity coloring via tokens.
2. **Navboxes, tooltips, item icons**: consistent footer navboxes; consider hover-tooltips for item links (Gloop-style) as a later gadget.
3. **Cargo query result styling**: sortable list/table pages (all weapons, all bosses) styled to match.
4. **Light theme audit**: full pass — dark is default but light must not feel like an afterthought.
5. **Main page v2**: replace placeholders with featured content, recent patch notes, community links.
6. **Comment section styling**: CommentStreams (installed per Phase 3 in CLAUDE.md) doesn't match Citizen out of the box — theme its thread UI, reply boxes, and vote buttons against the design tokens in both modes.

## Verification (both stages)

- Cross-check at 360px / 768px / 1440px widths; Citizen handles layout but our custom CSS must not break it.
- Contrast: WCAG AA on body text in both themes (dark reds on dark backgrounds are the classic failure).
- Side-by-side against runescape.wiki and minecraft.wiki on: article page, table-heavy page, main page, search, history/diff pages.
- Logged-out view is the one that matters — most readers never log in.
- Collaborator review round before calling Phase 3 done (per CLAUDE.md).

## Risks / notes

- **Citizen version pinning**: same discipline as everything else — pin a release, upgrades deliberate. Watch the changelog; Citizen moves fast and renames CSS tokens between majors.
- **Skin CSS lives on-wiki** (`MediaWiki:Citizen.css` etc.), not in this repo — mirror copies into `config-snippets/` so theming survives in git and backups.
- **Don't theme against placeholder content.** Stage 2 infobox styling waits for real ported templates; styling guesses get thrown away.
