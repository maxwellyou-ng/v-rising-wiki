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

push "Template:Navbox"             wiki-content/templates/Navbox.wikitext
push "Template:Navbox Patches"     wiki-content/templates/Navbox_Patches.wikitext
push "Template:Patch"              wiki-content/templates/Patch.wikitext
push "Template:Tl"                 wiki-content/templates/Tl.wikitext
push "Template:Stub"               wiki-content/templates/Stub.wikitext
push "Template:Outdated"           wiki-content/templates/Outdated.wikitext

# Content/project pages mirrored in the repo.
push "Weapons"                     wiki-content/pages/Weapons.wikitext
push "Armours"                     wiki-content/pages/Armours.wikitext
push "Consumables"                 wiki-content/pages/Consumables.wikitext
push "Structures"                  wiki-content/pages/Structures.wikitext
push "V Blood Carriers"            wiki-content/pages/V_Blood_Carriers.wikitext
push "Patch 1.0"                   wiki-content/pages/Patch_1.0.wikitext
push "Patch 1.1"                   wiki-content/pages/Patch_1.1.wikitext
push "Secrets of Gloomrot"         wiki-content/pages/Secrets_of_Gloomrot.wikitext
push "Bloodfeast"                  wiki-content/pages/Bloodfeast.wikitext
push "Early Access Release"        wiki-content/pages/Early_Access_Release.wikitext
push "Patch Notes"                 wiki-content/pages/Patch_Notes.wikitext
push "Blood"                       wiki-content/pages/Blood.wikitext
push "Main Page"                   wiki-content/pages/Main_Page.wikitext
push "Project:Style guide"         wiki-content/pages/Style_guide.wikitext
push "VRW:STYLE"                   wiki-content/pages/VRW_STYLE.wikitext

echo "Done. Job queue will refresh transcluding pages (jobrunner container)."
echo "NOTE: web workers cache templates in APCu, which CLI edits cannot purge."
echo "For the changes to render, now run:"
echo "  docker compose restart mediawiki"
echo "  docker compose exec -T mediawiki php maintenance/run.php purgeParserCache --age 1"
echo ""
echo "If a #cargo_declare changed (weapons: gear_level/physical_power/durability"
echo "became numeric 2026-07-05; equipment: gear_level/durability became numeric"
echo "2026-07-06; patches is new), also rebuild those tables:"
echo "  docker compose exec -T mediawiki php maintenance/run.php ./extensions/Cargo/maintenance/cargoRecreateData.php --table weapons"
echo "  docker compose exec -T mediawiki php maintenance/run.php ./extensions/Cargo/maintenance/cargoRecreateData.php --table equipment"
echo "  docker compose exec -T mediawiki php maintenance/run.php ./extensions/Cargo/maintenance/cargoRecreateData.php --table patches"
