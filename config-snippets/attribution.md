# CC BY-SA attribution (required before imported content goes public)

## 1. Sitewide notice

Paste into the wiki page `MediaWiki:Sitenotice` (edit as a sysop):

```wikitext
Content on this wiki is adapted from the [https://vrising.fandom.com V Rising Fandom wiki], available under [https://creativecommons.org/licenses/by-sa/3.0/ CC BY-SA]. Edit history is preserved for attribution.
```

To make it dismissible, bump the id in `MediaWiki:Sitenotice id` (create the
page with content `1`).

## 2. Footer link (persistent, survives sitenotice dismissal)

Add to `LocalSettings.php` on the server:

```php
// CC BY-SA attribution for content migrated from vrising.fandom.com
$wgHooks['SkinAddFooterLinks'][] = function ( $skin, $key, &$links ) {
	if ( $key === 'info' ) {
		$links['fandomattribution'] = $skin->msg( 'vrising-attribution' )->parse();
	}
};
```

Then create the wiki page `MediaWiki:Vrising-attribution` with:

```wikitext
Content adapted from the [https://vrising.fandom.com V Rising Fandom wiki] under [https://creativecommons.org/licenses/by-sa/3.0/ CC BY-SA].
```

## 3. License config sanity check

`LocalSettings.php` should already declare CC BY-SA so derived content stays
compatible:

```php
$wgRightsUrl = 'https://creativecommons.org/licenses/by-sa/4.0/';
$wgRightsText = 'Creative Commons Attribution-ShareAlike 4.0 International';
$wgRightsIcon = "$wgResourceBasePath/resources/assets/licenses/cc-by-sa.png";
```

(Fandom content is CC BY-SA 3.0; 4.0 is an accepted later version for
adaptations. Keep 3.0 if you prefer exact matching.)
