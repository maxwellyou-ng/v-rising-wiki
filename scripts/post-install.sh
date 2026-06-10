#!/usr/bin/env bash
# Post-install: fetch external extensions (REL1_43) and print LocalSettings additions.
# Run from anywhere; set DATA_ROOT to your data dir (default: ./data).
set -euo pipefail

DATA_ROOT="${DATA_ROOT:-./data}"
EXT_DIR="$DATA_ROOT/config/extensions"
MW_BRANCH="REL1_43"

mkdir -p "$EXT_DIR"

fetch() {
  local name="$1" url="$2" ref="$3"
  if [ -d "$EXT_DIR/$name" ]; then
    echo "== $name already present, skipping"
    return
  fi
  echo "== Fetching $name ($ref)"
  git clone --depth 1 --branch "$ref" "$url" "$EXT_DIR/$name"
  rm -rf "$EXT_DIR/$name/.git"
}

# Cargo — structured data (REL1_43 branch)
fetch Cargo "https://gerrit.wikimedia.org/r/mediawiki/extensions/Cargo" "$MW_BRANCH"

# SearchDigest — Weird Gloop; uses master (not branched per MW release)
fetch SearchDigest "https://github.com/weirdgloop/SearchDigest" "master"

mkdir -p "$DATA_ROOT/config-snippets" 2>/dev/null || true
SNIPPET="$DATA_ROOT/../config-snippets/LocalSettings-additions.php"
mkdir -p "$(dirname "$SNIPPET")"

cat > "$SNIPPET" <<'PHP'
<?php
// ===== V Rising Wiki — append to LocalSettings.php =====

// --- Bundled extensions (if not already enabled by the installer) ---
wfLoadExtension( 'ParserFunctions' );
wfLoadExtension( 'WikiEditor' );
wfLoadExtension( 'VisualEditor' );
wfLoadExtension( 'Scribunto' );
wfLoadExtension( 'TemplateStyles' );

// Scribunto: luastandalone works in the official Docker image
$wgScribuntoDefaultEngine = 'luastandalone';

// --- External extensions ---
wfLoadExtension( 'Cargo' );
wfLoadExtension( 'SearchDigest' );

// --- Uploads & editing ---
$wgEnableUploads = true;
$wgFileExtensions = array_merge( $wgFileExtensions, [ 'svg', 'webp' ] );
$wgUseInstantCommons = false;

// --- Job queue: handled by the dedicated jobrunner container ---
$wgJobRunRate = 0;

// --- Pretty URLs (optional; /wiki/Page_name) ---
// $wgArticlePath = '/wiki/$1';
// $wgUsePathInfo = true;

// --- Attribution (Phase 2: refine wording on a site notice / footer) ---
// Content imported from vrising.fandom.com under CC BY-SA; history preserved.

// ===== Anti-spam: enabled from launch (wiki is public) =====
wfLoadExtension( 'ConfirmEdit' );
wfLoadExtension( 'ConfirmEdit/QuestyCaptcha' );
wfLoadExtension( 'AbuseFilter' );
$wgGroupPermissions['*']['edit'] = false;            // anon editing off
$wgGroupPermissions['*']['createaccount'] = true;
$wgCaptchaClass = 'QuestyCaptcha';
// V Rising-flavored questions beat generic captchas for targeted spam:
$wgCaptchaQuestions = [
	'What resource do vampires in V Rising drink?' => [ 'blood' ],
	'What does sunlight do to a vampire? (one word)' => [ 'burn', 'burns', 'damage' ],
];
$wgCaptchaTriggers['edit'] = false;        // logged-in editing uncaptcha'd
$wgCaptchaTriggers['createaccount'] = true;
$wgCaptchaTriggers['addurl'] = true;
PHP

echo
echo "== Done. Extensions in: $EXT_DIR"
echo "== LocalSettings additions written to: $SNIPPET"
echo "== Next: append the snippet to LocalSettings.php, mount the extension dirs,"
echo "==       restart, then run inside the container:"
echo "==         php maintenance/run.php update --quick"
