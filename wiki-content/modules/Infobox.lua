-- Module:Infobox — native infobox renderer for V Rising entity templates.
-- Replaces the Fandom Portable Infobox (<infobox> XML) originals; each entry
-- point keeps the parameter interface of the template it backs, so articles
-- need no edits. Styled by Template:Infobox/styles.css against the --vr-*
-- design tokens.

local p = {}

local function trim(v)
	return v and mw.text.trim(v) or ''
end

-- First non-empty of args[k1], args[k2], ..., else the final default.
local function arg(args, k, default)
	local v = trim(args[k])
	if v ~= '' then
		return v
	end
	return default or ''
end

local function nospace(s)
	return (s:gsub(' ', ''))
end

local function pagename()
	return mw.title.getCurrentTitle().text
end

-- [[File:...]] markup for a bare filename (tolerates a File: prefix).
local function fileLink(name, size)
	name = name:gsub('^[Ff]ile:', '')
	return string.format('[[File:%s|%s|center]]', name, size or '250px')
end

-- spec = {
--   title = wikitext,
--   image = wikitext (already [[File:...]] or arbitrary markup),
--   caption = wikitext,
--   rows = { {header=...} | {label=..., value=...} | {value=...}, ... }
-- }
-- Rows with empty values are dropped; headers with no visible rows after
-- them are dropped too.
function p._render(frame, spec)
	local out = {}
	table.insert(out, frame:extensionTag('templatestyles', '', { src = 'Template:Infobox/styles.css' }))
	table.insert(out, '<aside class="vr-infobox">')
	if spec.title and spec.title ~= '' then
		table.insert(out, '<div class="vr-infobox-title">' .. spec.title .. '</div>')
	end
	if spec.image and spec.image ~= '' then
		local caption = (spec.caption and spec.caption ~= '')
			and ('<div class="vr-infobox-caption">' .. spec.caption .. '</div>') or ''
		table.insert(out, '<div class="vr-infobox-image">' .. spec.image .. caption .. '</div>')
	end

	local pendingHeader
	for _, r in ipairs(spec.rows or {}) do
		if r.header then
			pendingHeader = r.header
		elseif r.value and r.value ~= '' then
			if pendingHeader then
				table.insert(out, '<div class="vr-infobox-header">' .. pendingHeader .. '</div>')
				pendingHeader = nil
			end
			if r.label and r.label ~= '' then
				table.insert(out,
					'<div class="vr-infobox-row"><div class="vr-infobox-label">' .. r.label ..
					'</div><div class="vr-infobox-value">' .. r.value .. '</div></div>')
			else
				table.insert(out,
					'<div class="vr-infobox-row vr-infobox-row--full"><div class="vr-infobox-value">' ..
					r.value .. '</div></div>')
			end
		end
	end
	table.insert(out, '</aside>')
	return table.concat(out)
end

-- ===== Template:ItemInfobox =====
function p.item(frame)
	local a = frame:getParent().args
	local page = pagename()
	local category = arg(a, 'category')
	if category ~= '' and arg(a, 'category2') ~= '' then
		category = category .. ', ' .. arg(a, 'category2')
	end
	local station = arg(a, 'station')
	local tele = arg(a, 'teleportable', 'No')
	if tele:lower() == 'yes' then
		tele = '[[Waygates#Teleportable Items|Yes]]'
	end
	local locations = require('Module:GameData')._locations(arg(a, 'location', page))

	return p._render(frame, {
		title = arg(a, 'title', page),
		image = fileLink(arg(a, 'image', 'Item_' .. nospace(page) .. '.png')),
		rows = {
			{ label = 'Category', value = category },
			{ label = 'Refining Station', value = station ~= '' and ('[[' .. station .. ']]') or '' },
			{ label = 'Bloodbound', value = arg(a, 'bloodbound', 'No') },
			{ label = 'Teleportable', value = tele },
			{ label = 'Salvageable', value = arg(a, 'salvageable', 'Yes') },
			{ label = 'Max Stack Size', value = arg(a, 'stack_size', arg(a, 'stack', '200')) },
			{ label = 'Loot Locations', value = locations },
			{ label = 'Description', value = arg(a, 'description', 'No description.') },
		},
	})
end

-- ===== Template:StructureInfobox =====
function p.structure(frame)
	local a = frame:getParent().args
	local page = pagename()
	local description = arg(a, 'description')
	return p._render(frame, {
		title = arg(a, 'title', page),
		image = fileLink(arg(a, 'image', 'Structure_' .. nospace(page):gsub("'", '') .. '.png')),
		rows = {
			{ label = 'Build Category', value = arg(a, 'build_category') },
			{ label = 'Room', value = arg(a, 'room') },
			{ label = 'Resources', value = arg(a, 'resources') },
			{ label = 'Unlocked By', value = arg(a, 'unlocked_by', 'Default') },
			{ label = 'Description', value = description ~= '' and ("''" .. description .. "''") or '' },
			{ label = 'Dimensions', value = arg(a, 'dimensions') },
		},
	})
end

-- ===== Template:EquipmentInfobox =====
function p.equipment(frame)
	local a = frame:getParent().args
	local page = pagename()
	local category = arg(a, 'category')
	if category ~= '' and arg(a, 'category2') ~= '' then
		category = category .. ', ' .. arg(a, 'category2')
	end
	return p._render(frame, {
		title = arg(a, 'title', page),
		image = fileLink(arg(a, 'image', arg(a, 'type', 'Cloak') .. '_' .. nospace(page) .. '.png')),
		caption = arg(a, 'description'),
		rows = {
			{ label = 'Category', value = category },
			{ label = 'Gear Level', value = arg(a, 'gear_level') },
			{ label = 'Attributes', value = arg(a, 'stats') },
			{ label = 'Set Bonus', value = arg(a, 'set_bonus') },
			{ label = 'Durability', value = arg(a, 'durability') },
			{ label = 'Bloodbound', value = arg(a, 'bloodbound', 'Yes') },
			{ label = 'Salvageable', value = arg(a, 'salvageable', 'Yes') },
		},
	})
end

-- ===== Template:AbilityInfobox =====
function p.ability(frame)
	local a = frame:getParent().args
	local page = pagename()
	local abilityName = nospace(arg(a, 'ability', page))
	local class = arg(a, 'class', 'Basic')
	local border = arg(a, 'border')

	local image = arg(a, 'image')
	if image ~= '' then
		image = fileLink(image)
	else
		local frameName = border ~= '' and border or 'normal'
		if class == 'Passive' or class == 'Vampire Power' then
			frameName = 'circle'
		end
		image = frame:expandTemplate{ title = 'AbilityFrame', args = {
			abilityName, border ~= '' and '256' or '225', frameName, link = 'yes',
		} }
	end

	local function blue(v)
		if v == '' then
			return ''
		end
		return frame:expandTemplate{ title = 'Blue', args = { v } }
	end

	local classValue = ({
		Basic = 'Basic Spell', basic = 'Basic Spell',
		Ultimate = 'Ultimate Spell', ultimate = 'Ultimate Spell',
		['vampire power'] = '[[Abilities#Vampire Powers|Vampire Power]]',
		['Vampire Power'] = '[[Abilities#Vampire Powers|Vampire Power]]',
		['Vampire Powers'] = '[[Abilities#Vampire Powers|Vampire Power]]',
	})[class] or arg(a, 'class')

	local school = arg(a, 'school')
	local description = arg(a, 'description')
	return p._render(frame, {
		title = arg(a, 'title', page),
		image = image,
		rows = {
			{ value = description ~= '' and ('<div style="text-align: center">' .. description .. '</div>') or '' },
			{ label = 'Unlock Requirement', value = arg(a, 'requirements') },
			{ label = 'Magic School', value = school ~= ''
				and string.format('[[Abilities#%s Magic|%s]]', school, school) or '' },
			{ label = 'Class', value = classValue },
			{ label = 'Type', value = arg(a, 'type') },
			{ label = 'Dash Range', value = blue(arg(a, 'range')) },
			{ label = 'Cast Time', value = blue(arg(a, 'castTime')) },
			{ label = 'Cooldown', value = blue(arg(a, 'cooldown')) },
			{ label = 'Charges', value = blue(arg(a, 'charges')) },
			{ label = 'Recast Time', value = blue(arg(a, 'RecastTime')) },
		},
	})
end

-- ===== Template:WeaponInfobox =====
function p.weapon(frame)
	local a = frame:getParent().args
	local title = mw.title.getCurrentTitle()
	local root = title.rootText
	local gearLevel = arg(a, 'gear_level')
	local weaponType = arg(a, 'weapon_type')
	local physicalPower = arg(a, 'physical_power')
	local structure = arg(a, 'structure')

	local skills = arg(a, 'Skills')
	if skills == '' then
		skills = frame:expandTemplate{ title = 'WeaponInfobox/Skills', args = { gearLevel, weaponType } }
	end
	local resourceNode = arg(a, 'resource_node')
	if resourceNode == '' then
		resourceNode = frame:expandTemplate{ title = 'WeaponInfobox/Resource', args = { gearLevel } }
	end

	return p._render(frame, {
		title = arg(a, 'title', title.text),
		image = fileLink(arg(a, 'image', 'Weapon_' .. nospace(root):gsub("'", '') .. '.png')),
		caption = arg(a, 'description'),
		rows = {
			{ label = 'Structure', value = structure ~= '' and ('[[' .. structure .. ']]') or '' },
			{ header = '[[Attributes]]' },
			{ label = 'Weapon Type', value = weaponType ~= '' and ('[[' .. weaponType .. ']]') or '' },
			{ label = 'Weapon Skills', value = skills },
			{ label = 'Gear Level', value = gearLevel },
			{ label = 'Physical Power', value = physicalPower ~= '' and ('+' .. physicalPower) or '' },
			{ label = 'Attributes', value = arg(a, 'stats') },
			{ label = 'Durability', value = arg(a, 'durability') },
			{ label = 'Max Tier Resource Node', value = resourceNode },
			{ label = 'Salvageable', value = arg(a, 'salvageable', '?') },
		},
	})
end

-- ===== Template:Boss Infobox =====
function p.boss(frame)
	local a = frame:getParent().args
	local page = pagename()
	return p._render(frame, {
		title = arg(a, 'title', page),
		image = fileLink(arg(a, 'image', nospace(page:lower()) .. '.png')),
		caption = arg(a, 'caption1'),
		rows = {
			{ label = 'Level', value = arg(a, 'level') },
			{ label = 'Location', value = arg(a, 'location') },
			{ label = 'Unit ID', value = arg(a, 'unit_id') },
			{ label = 'Voice Actor', value = arg(a, 'voice_actor') },
			{ label = 'Unlocked Spells', value = arg(a, 'unlocked_spells') },
			{ label = 'Unlocked Vampire Powers', value = arg(a, 'unlocked_vampirepowers') },
			{ label = 'Unlocked Structures', value = arg(a, 'unlocked_structures') },
			{ label = 'Unlocked Recipes', value = arg(a, 'unlocked_recipes') },
			{ label = 'Possible Recipe Drops', value = arg(a, 'possibe_recipe_drops') },
		},
	})
end

-- ===== Template:Enemy Infobox =====
function p.enemy(frame)
	local a = frame:getParent().args
	local page = pagename()
	return p._render(frame, {
		title = arg(a, 'title', page),
		image = fileLink(arg(a, 'image', 'Item ' .. nospace(page) .. '.png')),
		caption = arg(a, 'caption1'),
		rows = {
			{ label = 'Level', value = arg(a, 'level') },
			{ label = 'Blood Type', value = arg(a, 'blood_type') },
			{ label = 'Location', value = arg(a, 'location') },
			{ label = 'Unit ID', value = arg(a, 'unit_id') },
			{ label = 'Description', value = arg(a, 'description') },
		},
	})
end

-- ===== Template:OreNodeInfobox =====
function p.oreNode(frame)
	local a = frame:getParent().args
	local function side(label, imgKey, sizeKey, sizeDefault, dropsKey)
		local rows = { { header = label } }
		local img = arg(a, imgKey)
		if img ~= '' then
			table.insert(rows, { value = fileLink(img, '220px') })
		end
		table.insert(rows, { label = 'Node Size', value = arg(a, sizeKey, sizeDefault) })
		table.insert(rows, { label = 'Item Drops', value = arg(a, dropsKey) })
		return rows
	end
	local rows = side('Small', 'smallImage', 'smallSize', 'Small', 'smallDrops')
	for _, r in ipairs(side('Massive', 'largeImage', 'largeSize', 'Massive', 'largeDrops')) do
		table.insert(rows, r)
	end
	return p._render(frame, { title = arg(a, 'title', pagename()), rows = rows })
end

-- ===== Template:Journal =====
function p.journal(frame)
	local a = frame:getParent().args
	return p._render(frame, {
		title = arg(a, 'title', pagename()),
		rows = {
			{ label = 'Unlocks', value = arg(a, 'unlocks') },
			{ header = 'Quest progression' },
			{ label = 'Previous', value = arg(a, 'previous') },
			{ label = 'Next', value = arg(a, 'next') },
		},
	})
end

-- ===== Template:Location =====
function p.location(frame)
	local a = frame:getParent().args
	local rows = {
		{ label = 'Type', value = arg(a, 'type') },
		{ label = 'Level', value = arg(a, 'level') },
		{ label = 'Location', value = arg(a, 'location') },
		{ label = 'Inhabitants', value = arg(a, 'inhabitants') },
	}
	local map = arg(a, 'map')
	if map ~= '' then
		local mapCaption = arg(a, 'mapcaption')
		table.insert(rows, 1, { value = fileLink(map)
			.. (mapCaption ~= '' and ('<div class="vr-infobox-caption">' .. mapCaption .. '</div>') or '') })
	end
	local image = arg(a, 'image')
	return p._render(frame, {
		title = arg(a, 'title', pagename()),
		image = image ~= '' and fileLink(image) or '',
		caption = arg(a, 'imagecaption'),
		rows = rows,
	})
end

-- ===== Template:Event =====
function p.event(frame)
	local a = frame:getParent().args
	local image = arg(a, 'image')
	return p._render(frame, {
		title = arg(a, 'title', pagename()),
		image = image ~= '' and fileLink(image) or '',
		caption = arg(a, 'imagecaption'),
		rows = {
			{ label = 'Performers', value = arg(a, 'performers') },
			{ label = 'Date', value = arg(a, 'date') },
			{ label = 'Location', value = arg(a, 'location') },
		},
	})
end

-- ===== Template:Game =====
function p.game(frame)
	local a = frame:getParent().args
	local image = arg(a, 'image')
	return p._render(frame, {
		title = arg(a, 'title', pagename()),
		image = image ~= '' and fileLink(image) or '',
		caption = arg(a, 'caption-image'),
		rows = {
			{ label = 'Developer / Publisher', value = arg(a, 'developer') },
			{ label = 'Engine', value = arg(a, 'engine') },
			{ label = 'Version', value = arg(a, 'version') },
			{ label = 'Platform', value = arg(a, 'platform') },
			{ label = 'Release date', value = arg(a, 'releasedate') },
			{ label = 'Genre', value = arg(a, 'genre') },
			{ label = 'Mode', value = arg(a, 'mode') },
			{ label = 'Rating', value = arg(a, 'rating') },
			{ label = 'Media', value = arg(a, 'media') },
			{ header = 'System requirements' },
			{ value = arg(a, 'requirements') },
		},
	})
end

-- ===== Template:QuestTemplate =====
function p.quest(frame)
	local a = frame:getParent().args
	local image = arg(a, 'IngameQuestNotice')
	local rows = {}
	if arg(a, 'QuestReward') ~= '' then
		table.insert(rows, { header = 'Quest Rewards' })
	end
	table.insert(rows, { value = arg(a, 'Reward1') })
	if arg(a, 'QuestProgress') ~= '' then
		table.insert(rows, { header = 'Quest Progression' })
	end
	table.insert(rows, { label = 'Preceded by', value = arg(a, 'PreviousQuest') })
	table.insert(rows, { label = 'Followed by', value = arg(a, 'NextQuest') })
	return p._render(frame, {
		title = arg(a, 'QuestName', pagename()),
		image = image ~= '' and fileLink(image) or '',
		caption = arg(a, 'caption-IngameQuestNotice'),
		rows = rows,
	})
end

-- ===== Template:Titlebox / Box with Title / Simple Window =====
function p.titlebox(frame)
	local a = frame:getParent().args
	return p._render(frame, {
		title = arg(a, 'title1', pagename()),
		rows = { { value = arg(a, 'row3') } },
	})
end

function p.boxWithTitle(frame)
	local a = frame:getParent().args
	return p._render(frame, {
		title = arg(a, 'title2'),
		rows = { { label = 'Label', value = arg(a, 'row3') } },
	})
end

function p.simpleWindow(frame)
	local a = frame:getParent().args
	return p._render(frame, {
		title = arg(a, 'title1'),
		rows = { { label = 'Method', value = arg(a, 'method') } },
	})
end

return p
