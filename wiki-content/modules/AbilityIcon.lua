-- Module:AbilityIcon — framed ability icons.
-- Lua port of the Fandom Variables-based Template:Ability (icon + text link)
-- and Template:AbilityFrame (icon only); parameter interfaces are unchanged.
-- The frame art has built-in margins, so the icon/frame pair is scaled and
-- offset against each other; travel/ultimate frames invert which layer shrinks.

local p = {}

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

local function round(x)
	return math.floor(x + 0.5)
end

-- Format a pixel value: integers plain, fractions trimmed to 2 decimals.
local function px(n)
	if n == math.floor(n) then
		return tostring(math.floor(n))
	end
	return (string.format('%.2f', n):gsub('0+$', ''):gsub('%.$', ''))
end

function p.ability(frame)
	local args = frame:getParent().args
	local name = first(args, 'sub', 'abilityName', 1)
	local imageName = name:gsub(' ', '')
	local aType = first(args, 'type')
	if aType == '' then aType = 'Ability' end
	local link = first(args, 1)
	if link == '' then link = name end
	local sizeParam = tonumber(first(args, 'size', 2)) or 27
	local frameName = first(args, 'frameName', 3)
	if frameName == '' then frameName = 'normal' end

	local bgSize = round(sizeParam)
	local up = round(bgSize * 1.45)
	local down = round(bgSize * 0.68)
	local offsetBase = -round((up - bgSize) / 2)
	local offsetSpecial = round((bgSize - down - 0.5) / 2)
	local special = frameName == 'travel' or frameName == 'ultimate'
	local offsetLeft = special and offsetSpecial or offsetBase
	local offsetTop = special and (offsetSpecial * 0.91 + 1) or (offsetBase + 1)

	local icon = string.format('[[File:%s_%s.png|%spx|link=%s]]', aType, imageName, px(bgSize), link)
	local iconSmall = string.format('[[File:%s_%s.png|%spx|link=%s]]', aType, imageName, px(down), link)
	local frameImg = string.format('[[File:AbilityFrame_%s.png|%spx|link=%s]]', frameName, px(bgSize), link)
	local frameImgBig = string.format('[[File:AbilityFrame_%s.png|%spx|link=%s]]', frameName, px(up), link)

	local out = {}
	table.insert(out, string.format(
		'<span style="width: %spx; height: %spx; margin-right:2px; display: inline-flex; justify-content: space-around; align-items:center; padding-right:2px">',
		sizeParam, sizeParam))
	table.insert(out, string.format('<span style="position: relative; height:%spx; %s">',
		px(bgSize), frameName == 'circle' and 'clip-path: circle(56% at 50% 51%);' or ''))
	if special then
		table.insert(out, '<span class="nomobile">' .. frameImg .. '</span>')
	else
		table.insert(out, icon)
	end
	table.insert(out, string.format('<span style="position: absolute; left: %spx; top: %spx;">',
		px(offsetLeft), px(offsetTop)))
	if special then
		table.insert(out, iconSmall)
	else
		table.insert(out, '<span class="nomobile">' .. frameImgBig .. '</span>')
	end
	table.insert(out, '</span></span></span>')

	local display = first(args, 'display')
	if display == '' then display = name end
	table.insert(out, string.format('[[%s|%s]]', link, display))
	return table.concat(out)
end

function p.abilityFrame(frame)
	local args = frame:getParent().args
	local name = first(args, 'sub', 'abilityName', 1)
	local imageName = name:gsub(' ', '')
	local aType = first(args, 'type')
	if aType == '' then aType = 'Ability' end
	local link
	if first(args, 'link') ~= '' then
		-- link to the icon's file page instead of the ability page
		link = 'File:' .. aType .. '_' .. imageName .. '.png'
	else
		link = first(args, 1)
		if link == '' then link = name end
	end
	local sizeParam = tonumber(first(args, 'size', 2)) or 25
	local frameName = first(args, 'frameName', 3)
	if frameName == '' then frameName = 'normal' end

	local bgSize = round(sizeParam * 0.95)
	local up = round(bgSize * 1.4)
	local down = round(bgSize * 0.65)
	local offsetBase = -round((up - bgSize) / 2)
	local offsetSpecial = round((bgSize - down) / 2)
	local special = frameName == 'travel' or frameName == 'ultimate'
	local offset = special and offsetSpecial or offsetBase

	local icon = string.format('[[File:%s_%s.png|%spx|link=%s]]', aType, imageName, px(bgSize), link)
	local iconSmall = string.format('[[File:%s_%s.png|%spx|link=%s]]', aType, imageName, px(down), link)
	local frameImg = string.format('[[File:AbilityFrame_%s.png|%spx|link=%s]]', frameName, px(bgSize), link)
	local frameImgBig = string.format('[[File:AbilityFrame_%s.png|%spx|link=%s]]', frameName, px(up), link)

	local out = {}
	table.insert(out, string.format(
		'<div class="hidden" style="width: %spx; height: %spx; display: inline-flex; justify-content: space-around; align-items:center;">',
		sizeParam, sizeParam))
	table.insert(out, string.format('<span style="position: relative; height:%spx; %s">',
		px(bgSize), frameName == 'circle' and 'clip-path: circle(53% at 50% 50%); background-color:#000000;' or ''))
	table.insert(out, special and frameImg or icon)
	table.insert(out, string.format('<span style="position: absolute; left: %spx; top: %spx;">',
		px(offset), px(offset)))
	table.insert(out, special and iconSmall or frameImgBig)
	table.insert(out, '</span></span></div>')
	-- plain fallback image for narrow screens (shown via CSS when .hidden is hidden)
	table.insert(out, string.format('<div class="mobileonly">[[File:%s_%s.png|%spx|link=%s]]</div>',
		aType, imageName, px(up), link))
	return table.concat(out)
end

return p
