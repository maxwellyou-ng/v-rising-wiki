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
| templates/Navbox.wikitext | Template:Navbox (generic footer navbox, `.vr-navbox-*` classes) |
| templates/Patch.wikitext | Template:Patch (patch infobox, declares Cargo table `patches`) |
| templates/Navbox_Patches.wikitext | Template:Navbox Patches (game-update footer navbox) |
| templates/Tl.wikitext | Template:Tl (template-link helper for docs) |
| templates/Stub.wikitext | Template:Stub |
| templates/Outdated.wikitext | Template:Outdated (takes last-verified patch) |
| pages/Weapons.wikitext | Weapons (overview page with Cargo all-weapons table) |
| pages/Armours.wikitext | Armours (all-equipment Cargo table + tabber set details) |
| pages/Consumables.wikitext | Consumables (all-consumables Cargo table + crafting details) |
| pages/Structures.wikitext | Structures (all-structures Cargo table; replaced the raw Fandom data dump, old revision in page history) |
| pages/V_Blood_Carriers.wikitext | V Blood Carriers (all-bosses Cargo table + by-act table) |
| pages/Patch_1.0.wikitext, Patch_1.1, Secrets_of_Gloomrot, Bloodfeast, Early_Access_Release | patch articles (Template:Patch infobox feeds Cargo `patches`; hotfixes are sections, not pages) |
| pages/Patch_Notes.wikitext | Patch Notes (version index hub; major rows link to the patch articles) |
| pages/Style_guide.wikitext | Project:Style guide |
| pages/VRW_STYLE.wikitext | VRW:STYLE (shortcut redirect) |

Notes:

- `Template:LootDrop` declares and stores the Cargo table `loot_drops`;
  `Template:List Loot Sources` queries it (replaces the old DPL category scan).
  After changing the declaration, re-run:
  `docker compose exec -T mediawiki php maintenance/run.php ./extensions/Cargo/maintenance/cargoRecreateData.php --table loot_drops`
- `Template:Screenshots` needs Extension:TabberNeue (bind-mounted like Cargo).
- Whenever a `#cargo_declare` changes, re-run
  `cargoRecreateData.php --table <name>` after pushing (weapons went
  numeric and patches was created this way on 2026-07-05; equipment
  gear_level/durability went numeric 2026-07-06).
- `Template:Navbox`, `Template:Stub`, `Template:Outdated`, and the Weapons
  page's `vr-table-scroll` wrapper depend on the `.vr-navbox-*` /
  `.vr-banner` / table CSS added to `config-snippets/Common.css` — paste
  that to `MediaWiki:Common.css` before or with the push.
- The data pages `Template:Recipe/data` and `Template:LocationFinder/data`
  stay on-wiki unchanged; Module:GameData parses them directly (no
  LabeledSectionTransclusion dependency).
- On-wiki CSS mirrors stay in `config-snippets/` (see PHASE3.md).
