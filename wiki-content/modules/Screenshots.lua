-- Module:Screenshots — Male/Female armour screenshot tab panels
-- (Template:Screenshots). Lua port of the Fandom Variables-based original.
-- Requires Extension:TabberNeue for the <tabber> tag.

local p = {}

local slots = { 'Set', 'Chest', 'Leggings', 'Boots', 'Gloves' }

local function panel(name, slot, sex)
	local file = string.format('%s %s %s.png', name, slot, sex)
	local title = mw.title.new('File:' .. file)
	if title and title.exists then
		return string.format('[[File:%s|0x400px|left]]', file)
	end
	return "<center>'''No Image Found.''' Please ["
		.. tostring(mw.uri.fullUrl('Category:Screenshots', 'action=edit'))
		.. ' Upload It.] [[Category:Screenshot Missing]]</center>'
end

local function genderTabs(frame, name, sex)
	local parts = {}
	for _, slot in ipairs(slots) do
		table.insert(parts, slot .. '=\n' .. panel(name, slot, sex))
	end
	return frame:extensionTag('tabber', table.concat(parts, '\n|-|\n'))
end

function p.main(frame)
	local args = frame:getParent().args
	local pagename = mw.text.trim(args[1] or '')
	if pagename == '' then
		pagename = mw.title.getCurrentTitle().text:gsub(' Armour Set', '')
	end
	local name = pagename:gsub("'", '')
	return frame:extensionTag('tabber',
		'Male=\n' .. genderTabs(frame, name, 'Male')
		.. '\n|-|\nFemale=\n' .. genderTabs(frame, name, 'Female'))
end

return p
