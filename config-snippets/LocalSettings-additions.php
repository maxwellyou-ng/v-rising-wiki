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
