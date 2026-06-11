#!/usr/bin/env python3
"""Export pages from vrising.fandom.com as XML dumps, in batches.

Stdlib only. Fandom's Special:Export caps pages per request, so we batch.
Full revision history is requested (required for CC BY-SA attribution).
Note: Special:Export also caps revisions per page (~1000); pages exceeding
that keep their most recent 1000 revisions, which is acceptable for
attribution purposes on a wiki this size.

Usage:
    python3 scripts/list-pages.py > pages.txt
    python3 scripts/export-fandom.py --pages pages.txt --out exports/

Import on the VPS with:
    docker compose exec mediawiki php maintenance/run.php importDump --quiet <file>
"""

import argparse
import pathlib
import sys
import time
import urllib.parse
import urllib.request

EXPORT_URL = "https://vrising.fandom.com/wiki/Special:Export"
USER_AGENT = "v-rising-wiki-migration/1.0 (https://wiki.v-ris.ing; hi@maxwellyou.ng)"
BATCH_SIZE = 50
DELAY = 1.0  # seconds between batches
RETRIES = 3


def export_batch(titles: list) -> bytes:
    # NOTE: do NOT include "curonly" or "templates" keys at all — MediaWiki's
    # Special:Export treats their mere presence (even empty) as checked, and
    # curonly would silently drop edit history.
    data = urllib.parse.urlencode(
        {
            "pages": "\n".join(titles),
            "history": "1",      # full revision history (CC BY-SA attribution)
            "wpDownload": "1",
            "title": "Special:Export",
        }
    ).encode()
    req = urllib.request.Request(
        EXPORT_URL, data=data, headers={"User-Agent": USER_AGENT}
    )
    last_err = None
    for attempt in range(1, RETRIES + 1):
        try:
            with urllib.request.urlopen(req, timeout=300) as resp:
                return resp.read()
        except Exception as e:  # noqa: BLE001
            last_err = e
            wait = 5 * attempt
            print(f"  attempt {attempt} failed ({e}); retrying in {wait}s", file=sys.stderr)
            time.sleep(wait)
    raise RuntimeError(f"batch failed after {RETRIES} attempts: {last_err}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pages", required=True, help="file with one page title per line")
    ap.add_argument("--out", default="exports", help="output directory")
    ap.add_argument("--batch-size", type=int, default=BATCH_SIZE)
    args = ap.parse_args()

    titles = [
        line.strip()
        for line in pathlib.Path(args.pages).read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    out = pathlib.Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    batches = [
        titles[i : i + args.batch_size] for i in range(0, len(titles), args.batch_size)
    ]
    width = len(str(len(batches)))
    for i, batch in enumerate(batches, 1):
        dest = out / f"batch-{i:0{width}d}.xml"
        if dest.exists() and dest.stat().st_size > 0:
            print(f"[{i}/{len(batches)}] {dest} exists, skipping", file=sys.stderr)
            continue
        print(f"[{i}/{len(batches)}] exporting {len(batch)} pages -> {dest}", file=sys.stderr)
        xml = export_batch(batch)
        if b"<mediawiki" not in xml[:2000]:
            raise RuntimeError(f"batch {i}: response doesn't look like a MediaWiki XML dump")
        dest.write_bytes(xml)
        time.sleep(DELAY)
    print("done", file=sys.stderr)


if __name__ == "__main__":
    main()
