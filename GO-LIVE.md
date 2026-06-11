# Phase 2 — Content Migration Checklist

Phase 1 is complete (wiki live at https://wiki.v-ris.ing, backup tested).
This checklist covers migrating content from the V Rising Fandom wiki.

**Scope (from the Fandom API, 2026-06-10):** 5,865 pages (1,359 articles),
2,619 images, 34,323 edits.

## Progress (2026-06-10)

- [x] Migration scripts written, validated, committed (stdlib-only)
- [x] Pushed to GitHub; VPS repo pulled to `7256b15` (live Caddyfile/compose
      edits were redundant with incoming commits; stash verified + dropped)
- [x] Steps 1–6 complete (2026-06-11)
- [x] Clean `/w/` URLs working (wgArticlePath + Caddy rewrite)
- [x] CC BY-SA attribution live (sitenotice, footer hook, MediaWiki messages)

## 1. Run the migration scripts

On the VPS, from `~/vrising-wiki` (not inside a container), in tmux:

```bash
tmux new -s migration   # or: tmux attach -t migration
./scripts/run-migration.sh
```

Produces `pages.txt`, `exports/*.xml` (full edit history — required for
CC BY-SA attribution), and `images-import/` (~2,600 files). Re-runnable;
finished batches and downloaded images are skipped.

## 2. Import XML

Run step 1 on the VPS itself (preferred) so `exports/` and `images-import/`
land directly in `~/vrising-wiki`. If you ran it elsewhere, rsync first:

```bash
rsync -av -e "ssh -i ~/.ssh/hetzner_vrising" exports/ images-import/ \
  deploy@5.78.219.66:/home/deploy/vrising-wiki/
```

On the VPS (`ssh -i ~/.ssh/hetzner_vrising deploy@5.78.219.66`), stdin piping —
there is no import mount in the compose file:

```bash
cd ~/vrising-wiki
for f in exports/*.xml; do
  docker compose exec -T mediawiki php maintenance/run.php importDump --quiet < "$f"
done
docker compose exec mediawiki php maintenance/run.php rebuildrecentchanges
```

Use `importDump.php` — **not** Special:Import (web importer fails on large files).

## 3. Import images

```bash
docker compose cp images-import mediawiki:/tmp/images-import
docker compose exec mediawiki php maintenance/run.php importImages \
  --comment "Imported from vrising.fandom.com (CC BY-SA)" /tmp/images-import
docker compose exec mediawiki rm -rf /tmp/images-import
```

Expect redirects, duplicates, and SVGs that need cleanup —
`images-manifest.json` (written by the fetch script) has names/sizes/sha1s
for cross-checking.

## 4. Add attribution notice

Follow `config-snippets/attribution.md`: sitenotice wikitext, footer hook for
`LocalSettings.php`, and license config check. CC BY-SA requires this before
the imported content is public-facing.

## 5. Port templates and Lua modules

After import, identify broken templates (red links on heavily-templated pages).
Fandom templates often depend on custom CSS or JS that needs to be rebuilt.
Priority order:
1. Infobox templates (bosses, items, abilities)
2. Navigation templates
3. Cargo table declarations

## 6. Verify

- Spot-check 10–20 article pages for broken templates or missing images
- Check `Special:BrokenRedirects` and `Special:WantedPages`
- Run `Special:Statistics` — page/file counts should be near 5,865 / 2,619;
  job queue should drain to 0 after ~10 minutes (jobrunner container)
- Confirm full edit history on a few imported pages (history tab)

## What's deliberately NOT done yet

Phase 3 (skin/theming, Cargo schemas for game entities, CommentStreams) starts
only after the content migration is verified.

## Known gaps / future to-dos

- **Full edit history**: The API export (`action=query&export=1`) only captures
  the latest revision per page. Full editor history was not preserved.
  To fix: retry `Special:Export` with `history=1` (was blocked by 403 during
  migration — try with a logged-in session cookie or from a residential IP).
  Re-import with `importDump.php --no-updates` to merge without overwriting
  current content. Until then, footer attribution covers CC BY-SA.
