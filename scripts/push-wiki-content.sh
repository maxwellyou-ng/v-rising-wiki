#!/usr/bin/env bash
# Push wiki-content/ mirrors to the live wiki via maintenance edit.php.
# Run on the VPS from the repo root: ./scripts/push-wiki-content.sh
set -euo pipefail
cd "$(dirname "$0")/.."

SUMMARY="Sync from git wiki-content/ (Lua + Cargo rebuild, no Variables/DPL)"

push() {
	local title="$1" file="$2"
	echo "==> $title"
	docker compose exec -T mediawiki php maintenance/run.php edit \
		--user "Maintenance script" --summary "$SUMMARY" --bot "$title" \
		< "$file"
}

# Modules first — templates reference them.
push "Module:ItemFrame"            wiki-content/modules/ItemFrame.lua
push "Module:AbilityIcon"          wiki-content/modules/AbilityIcon.lua
push "Module:GameData"             wiki-content/modules/GameData.lua
push "Module:Screenshots"          wiki-content/modules/Screenshots.lua

push "Template:ItemFrame"          wiki-content/templates/ItemFrame.wikitext
push "Template:ItemBox"            wiki-content/templates/ItemBox.wikitext
push "Template:Ability"            wiki-content/templates/Ability.wikitext
push "Template:AbilityFrame"       wiki-content/templates/AbilityFrame.wikitext
push "Template:Recipe"             wiki-content/templates/Recipe.wikitext
push "Template:LocationFinder"     wiki-content/templates/LocationFinder.wikitext
push "Template:LootDrop"           wiki-content/templates/LootDrop.wikitext
push "Template:List Loot Sources"  wiki-content/templates/List_Loot_Sources.wikitext
push "Template:Colors"             wiki-content/templates/Colors.wikitext
push "Template:Navbox Weapons"     wiki-content/templates/Navbox_Weapons.wikitext
push "Template:Screenshots"        wiki-content/templates/Screenshots.wikitext

echo "Done. Job queue will refresh transcluding pages (jobrunner container)."
