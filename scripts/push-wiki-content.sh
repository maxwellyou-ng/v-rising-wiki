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
push "Module:Infobox"              wiki-content/modules/Infobox.lua

push "Template:Infobox/styles.css" wiki-content/templates/Infobox_styles.css

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

push "Template:ItemInfobox"        wiki-content/templates/ItemInfobox.wikitext
push "Template:StructureInfobox"   wiki-content/templates/StructureInfobox.wikitext
push "Template:EquipmentInfobox"   wiki-content/templates/EquipmentInfobox.wikitext
push "Template:AbilityInfobox"     wiki-content/templates/AbilityInfobox.wikitext
push "Template:WeaponInfobox"      wiki-content/templates/WeaponInfobox.wikitext
push "Template:Boss Infobox"       wiki-content/templates/Boss_Infobox.wikitext
push "Template:Enemy Infobox"      wiki-content/templates/Enemy_Infobox.wikitext
push "Template:OreNodeInfobox"     wiki-content/templates/OreNodeInfobox.wikitext
push "Template:Journal"            wiki-content/templates/Journal.wikitext
push "Template:Location"           wiki-content/templates/Location.wikitext
push "Template:Event"              wiki-content/templates/Event.wikitext
push "Template:Game"               wiki-content/templates/Game.wikitext
push "Template:QuestTemplate"      wiki-content/templates/QuestTemplate.wikitext
push "Template:Titlebox"           wiki-content/templates/Titlebox.wikitext
push "Template:Box with Title"     wiki-content/templates/Box_with_Title.wikitext
push "Template:Simple Window"      wiki-content/templates/Simple_Window.wikitext

echo "Done. Job queue will refresh transcluding pages (jobrunner container)."
