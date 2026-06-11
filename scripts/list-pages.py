#!/usr/bin/env python3
"""Enumerate all pages on vrising.fandom.com via the MediaWiki API.

Stdlib only — runs anywhere with Python 3.8+.

Usage:
    python3 scripts/list-pages.py > pages.txt

Namespaces exported (everything importDump.php needs for a faithful copy):
    0   Main (articles)
    4   Project
    6   File (description pages; the binaries come via fetch-images.py)
    10  Template
    14  Category
    828 Module (Scribunto/Lua)
"""

import json
import sys
import time
import urllib.parse
import urllib.request

API = "https://vrising.fandom.com/api.php"
USER_AGENT = "v-rising-wiki-migration/1.0 (https://wiki.v-ris.ing; hi@maxwellyou.ng)"
NAMESPACES = [0, 4, 6, 10, 14, 828]
DELAY = 0.5  # seconds between requests; be polite


def api_get(params: dict) -> dict:
    params = {**params, "format": "json"}
    url = API + "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.load(resp)


def list_namespace(ns: int):
    apcontinue = None
    while True:
        params = {
            "action": "query",
            "list": "allpages",
            "apnamespace": ns,
            "aplimit": "500",
        }
        if apcontinue:
            params["apcontinue"] = apcontinue
        data = api_get(params)
        for page in data["query"]["allpages"]:
            yield page["title"]
        cont = data.get("continue", {}).get("apcontinue")
        if not cont:
            break
        apcontinue = cont
        time.sleep(DELAY)


def main():
    total = 0
    for ns in NAMESPACES:
        count = 0
        for title in list_namespace(ns):
            print(title)
            count += 1
        total += count
        print(f"namespace {ns}: {count} pages", file=sys.stderr)
        time.sleep(DELAY)
    print(f"total: {total} pages", file=sys.stderr)


if __name__ == "__main__":
    main()
