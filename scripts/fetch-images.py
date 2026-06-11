#!/usr/bin/env python3
"""Download all images from vrising.fandom.com for importImages.php.

Stdlib only. Lists files via the allimages API, downloads original-size
binaries, and skips files already present (safe to re-run / resume).

Usage:
    python3 scripts/fetch-images.py --out images-import/

Then on the VPS (after copying images-import/ over):
    docker compose exec mediawiki php maintenance/run.php importImages \
        --comment "Imported from vrising.fandom.com (CC BY-SA)" /path/to/images-import/
"""

import argparse
import json
import pathlib
import sys
import time
import urllib.parse
import urllib.request

API = "https://vrising.fandom.com/api.php"
USER_AGENT = "v-rising-wiki-migration/1.0 (https://wiki.v-ris.ing; hi@maxwellyou.ng)"
DELAY = 0.3
RETRIES = 3


def api_get(params: dict) -> dict:
    params = {**params, "format": "json"}
    url = API + "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.load(resp)


def list_all_images():
    aicontinue = None
    while True:
        params = {
            "action": "query",
            "list": "allimages",
            "ailimit": "500",
            "aiprop": "url|size|sha1",
        }
        if aicontinue:
            params["aicontinue"] = aicontinue
        data = api_get(params)
        yield from data["query"]["allimages"]
        cont = data.get("continue", {}).get("aicontinue")
        if not cont:
            break
        aicontinue = cont
        time.sleep(DELAY)


def download(url: str, dest: pathlib.Path):
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    last_err = None
    for attempt in range(1, RETRIES + 1):
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                dest.write_bytes(resp.read())
            return
        except Exception as e:  # noqa: BLE001
            last_err = e
            time.sleep(3 * attempt)
    raise RuntimeError(f"download failed after {RETRIES} attempts: {url}: {last_err}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="images-import", help="output directory")
    ap.add_argument("--manifest", default=None, help="optional path to write a JSON manifest")
    args = ap.parse_args()

    out = pathlib.Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    images = list(list_all_images())
    total_bytes = sum(i.get("size", 0) for i in images)
    print(f"{len(images)} files, ~{total_bytes / 1e6:.0f} MB total", file=sys.stderr)

    if args.manifest:
        pathlib.Path(args.manifest).write_text(json.dumps(images, indent=1), encoding="utf-8")

    skipped = fetched = failed = 0
    for n, img in enumerate(images, 1):
        name = img["name"]  # already underscored, filesystem-safe on Fandom
        dest = out / name
        if dest.exists() and dest.stat().st_size == img.get("size", -1):
            skipped += 1
            continue
        try:
            download(img["url"], dest)
            fetched += 1
        except RuntimeError as e:
            print(f"FAILED: {e}", file=sys.stderr)
            failed += 1
        if n % 50 == 0:
            print(f"  {n}/{len(images)} (fetched {fetched}, skipped {skipped}, failed {failed})", file=sys.stderr)
        time.sleep(DELAY)

    print(f"done: fetched {fetched}, skipped {skipped}, failed {failed}", file=sys.stderr)
    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
