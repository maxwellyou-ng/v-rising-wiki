# patches/ — local patches for bind-mounted extensions

The extension clones under `data/config/extensions/` are **not tracked by
this repo** (`data/` is gitignored) — they're cloned directly on the VPS.
Fixes we need before upstream releases them live here as patch files.

## cargo-mw1432-db-aliasing.patch

MediaWiki ≥ 1.43.2 changed DB table aliasing (backported from 1.44): tables
in FROM are always aliased, so Cargo 3.7's `setMWJoinConds()`/`addQuotes()`
produce unaddressable `cargo__<table>.<field>` references. Breaks every
non-aggregating `#cargo_query` once the `cargo_backlinks` table exists
(first hit: the Weapons page, `Error 1054: Unknown column
'cargo__weapons._pageID'`). Cargo's REL1_43 branch is frozen at 3.7 without
the fix; this is upstream master's (3.9.2) `mwUsesOldDBAliasing()` change,
verbatim.

Apply on the VPS:

```bash
cd /home/deploy/vrising-wiki/data/config/extensions/Cargo
git apply ../../../../patches/cargo-mw1432-db-aliasing.patch
cd /home/deploy/vrising-wiki
docker compose restart
docker compose exec -T mediawiki php maintenance/run.php purgeParserCache --age 1
```

`git pull` inside the Cargo clone will conflict while this is applied —
`git stash` first, pull, re-apply. **Remove this patch when Cargo is
upgraded to ≥ 3.8** (a deliberate, separate task).
