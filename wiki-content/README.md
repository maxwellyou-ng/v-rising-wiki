# wiki-content — repo mirrors of on-wiki pages

Source of truth for templates and Lua modules that were rebuilt after the
Fandom migration (the originals depended on Extension:Variables and DPL,
which are deliberately not installed — Variables is unmaintained and
Parsoid-incompatible).

Edit here first, commit, then push to the live wiki from the VPS:

```bash
./scripts/push-wiki-content.sh          # pushes every file below
docker compose restart mediawiki        # web APCu caches templates; CLI edits can't purge it
docker compose exec -T mediawiki php maintenance/run.php purgeParserCache --age 1
```

| File | Wiki page |
|---|---|
| modules/ItemFrame.lua | Module:ItemFrame |
| modules/AbilityIcon.lua | Module:AbilityIcon |
| modules/GameData.lua | Module:GameData |
| modules/Screenshots.lua | Module:Screenshots |
| templates/ItemFrame.wikitext | Template:ItemFrame |
| templates/ItemBox.wikitext | Template:ItemBox |
| templates/Ability.wikitext | Template:Ability |
| templates/AbilityFrame.wikitext | Template:AbilityFrame |
| templates/Recipe.wikitext | Template:Recipe |
| templates/LocationFinder.wikitext | Template:LocationFinder |
| templates/LootDrop.wikitext | Template:LootDrop |
| templates/List_Loot_Sources.wikitext | Template:List Loot Sources |
| templates/Colors.wikitext | Template:Colors |
| templates/Navbox_Weapons.wikitext | Template:Navbox Weapons |
| templates/Screenshots.wikitext | Template:Screenshots |
| modules/Infobox.lua | Module:Infobox |
| templates/Infobox_styles.css | Template:Infobox/styles.css |
| templates/ItemInfobox.wikitext | Template:ItemInfobox |
| templates/StructureInfobox.wikitext | Template:StructureInfobox |
| templates/EquipmentInfobox.wikitext | Template:EquipmentInfobox |
| templates/AbilityInfobox.wikitext | Template:AbilityInfobox |
| templates/WeaponInfobox.wikitext | Template:WeaponInfobox |
| templates/Boss_Infobox.wikitext | Template:Boss Infobox |
| templates/Enemy_Infobox.wikitext | Template:Enemy Infobox |
| templates/OreNodeInfobox.wikitext | Template:OreNodeInfobox |
| templates/Journal.wikitext, Location, Event, Game, QuestTemplate, Titlebox, Box_with_Title, Simple_Window | matching Template: pages |

Notes:

- `Template:LootDrop` declares and stores the Cargo table `loot_drops`;
  `Template:List Loot Sources` queries it (replaces the old DPL category scan).
  After changing the declaration, re-run:
  `docker compose exec -T mediawiki php maintenance/run.php ./extensions/Cargo/maintenance/cargoRecreateData.php --table loot_drops`
- `Template:Screenshots` needs Extension:TabberNeue (bind-mounted like Cargo).
- The data pages `Template:Recipe/data` and `Template:LocationFinder/data`
  stay on-wiki unchanged; Module:GameData parses them directly (no
  LabeledSectionTransclusion dependency).
- On-wiki CSS mirrors stay in `config-snippets/` (see PHASE3.md).
