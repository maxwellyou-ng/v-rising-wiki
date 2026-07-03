-- Module:GameData — reads the comma-delimited data blobs kept on
-- Template:Recipe/data and Template:LocationFinder/data and renders the
-- recipe table (Template:Recipe) and map-location list (Template:LocationFinder).
-- Replaces the Fandom implementation built on Variables + LabeledSectionTransclusion.
--
-- Data record format (see the /data pages):
--   ,Recipe_ITEM,QTY1,REAGENT1,QTY2,REAGENT2,...  padded with empty fields
--   ,Item_ITEM,MARKER1,LOCATION1,MARKER2,LOCATION2,...

local p = {}
local ItemFrame = require('Module:ItemFrame')

-- All comma-separated tokens from every <section begin="dataN"/> block.
local function tokens(dataPage)
	local title = mw.title.new(dataPage)
	local content = title and title:getContent() or ''
	local parts = {}
	for body in content:gmatch('<section begin="data%d+"%s*/>(.-)<section end="data%d+"%s*/>') do
		table.insert(parts, body)
	end
	local toks = mw.text.split(table.concat(parts, ','), ',', true)
	for i, t in ipairs(toks) do
		toks[i] = mw.text.trim(t)
	end
	return toks
end

-- Value/label pairs following the record marker, stopping at the next record.
local function record(dataPage, key, nextRecordPrefix)
	local toks = tokens(dataPage)
	local start
	for i, t in ipairs(toks) do
		if t == key then
			start = i
			break
		end
	end
	if not start then
		return {}
	end
	local pairsOut = {}
	local i = start + 1
	while i < #toks do
		local a, b = toks[i], toks[i + 1] or ''
		if a:sub(1, #nextRecordPrefix) == nextRecordPrefix
			or b:sub(1, #nextRecordPrefix) == nextRecordPrefix then
			break
		end
		if a ~= '' or b ~= '' then
			table.insert(pairsOut, { a, b })
		end
		i = i + 2
	end
	return pairsOut
end

local function first(args, ...)
	for _, k in ipairs({ ... }) do
		local v = args[k]
		if v then
			v = mw.text.trim(v)
			if v ~= '' then
				return v
			end
		end
	end
	return ''
end

function p.recipe(frame)
	local args = frame:getParent().args
	local name = first(args, 1)
	if name == '' then
		name = mw.title.getCurrentTitle().text
	end
	local reagents = record('Template:Recipe/data', 'Recipe_' .. name, 'Recipe_')

	local qty = first(args, 3)
	local productCell = ItemFrame._itemFrame({
		name,
		recipe = qty ~= '' and (qty .. '&nbsp;') or '',
	})

	local reagentParts = {}
	for _, r in ipairs(reagents) do
		if r[1] ~= '' then
			table.insert(reagentParts, ItemFrame._itemFrame({ r[2], r[1] }))
		end
	end

	local structure = first(args, 2)
	local structureCell
	if structure == 'Crafting' then
		structureCell = '[[Crafting|By hand]]'
	else
		structureCell = ItemFrame._itemFrame({
			structure ~= '' and structure or 'Unknown',
			type = 'Structure',
		})
	end

	local unlockedBy = first(args, 'unlocked_by')
	local out = {
		'\n{| class="wikitable"',
		'!Item',
		'!Recipe',
		'!Structure' .. (unlockedBy ~= '' and '!! style="width:126px"|Unlocked by' or ''),
		'|-',
		'|<div style="text-align:center">' .. productCell .. '</div>',
		'|' .. table.concat(reagentParts, '<br>'),
		'|' .. structureCell .. (unlockedBy ~= '' and ('||' .. unlockedBy) or ''),
		'|}',
	}
	return table.concat(out, '\n')
end

function p.locations(frame)
	local args = frame:getParent().args
	local name = first(args, 1)
	if name == '' then
		name = mw.title.getCurrentTitle().text
	end
	local locations = record('Template:LocationFinder/data', 'Item_' .. name, 'Item_')

	local out = {}
	for _, loc in ipairs(locations) do
		if loc[1] ~= '' then
			-- the interactive map has not been migrated; markers still point at
			-- the Fandom map page (CC BY-SA source)
			table.insert(out, string.format(
				'[https://vrising.fandom.com/wiki/Map:Vardoran?marker=%s %s]', loc[1], loc[2]))
		end
	end
	return table.concat(out, '<br>')
end

return p
