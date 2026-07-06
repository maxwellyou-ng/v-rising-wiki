-- Module:ItemFrame — inline item icon + link (Template:ItemFrame) and the
-- larger floating box variant (Template:ItemBox).
-- Lua port of the Fandom originals, which used Extension:Variables for local
-- variables; parameter interfaces are unchanged.

local p = {}

-- First non-empty argument among the given keys, trimmed.
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

function p._itemFrame(args)
	local itemName = first(args, 'sub', 'itemName', 1)
	local imageName = itemName:gsub(' ', ''):gsub("'", ''):gsub('JewelTier', 'Tier')
	local bgSize = first(args, 'size')
	if bgSize == '' then bgSize = '30' end
	local imageType = first(args, 'itemType', 'type')
	if imageType == '' then imageType = 'Item' end
	local image = first(args, 'image')
	if image == '' then image = imageName end

	local quantity = first(args, 2)
	if quantity == '' then quantity = '0' end
	local qtyNum = tonumber(quantity)

	local out = {}
	table.insert(out, string.format(
		'<span style="position: relative; margin-right:2px; display:inline-flex; justify-content: space-around; align-items: center; width:%spx; height: %spx; background-color: #000000;">',
		bgSize, bgSize))
	table.insert(out, string.format('[[File:%s_%s.png|frameless|%sx%spx|link=%s|alt=%s]]',
		imageType, image, bgSize, bgSize, itemName, itemName))
	-- decorative border: empty alt so screen readers skip the duplicate link
	table.insert(out, string.format(
		'<span style="position: absolute; left: 0; top: 0;">[[File:InventorySlotBorder.png|class=hidden|%sx%spx|link=%s|alt=]]</span></span>',
		bgSize, bgSize, itemName))

	if quantity == '0' then
		table.insert(out, first(args, 'recipe'))
	else
		table.insert(out, quantity)
		if qtyNum then
			local discountQty = math.ceil(qtyNum * 0.75)
			-- crafting-discount quantity, shown unless suppressed via |discountable=N
			if qtyNum ~= discountQty and first(args, 'discountable') == '' then
				table.insert(out, '&nbsp;(' .. discountQty .. ')')
			end
		end
		table.insert(out, '&nbsp;')
	end

	local display = first(args, 'display')
	if display == '' then display = itemName end
	table.insert(out, string.format('[[%s|%s]]', itemName, display))
	return table.concat(out)
end

function p._itemBox(args)
	local itemName = first(args, 'sub', 'itemName', 1)
	local imageName = itemName:gsub(' ', ''):gsub("'", '')
	local imageType = first(args, 'type')
	if imageType == '' then imageType = 'Item' end
	local size = '112'

	return table.concat({
		string.format('<center class="mobileonly">[[%s]]</center>', itemName),
		string.format('<div style="position: relative; float:left; margin: 8px 8px 5px 16px; width:%spx;">', size),
		string.format('<div style="position: absolute; width:%spx; height: %spx; display: flex; justify-content: space-around; align-items: center; overflow: hidden; background-color: #000000;">', size, size),
		string.format('[[File:%s_%s.png|frameless|%sx%spx|link=%s|alt=%s]]', imageType, imageName, size, size, itemName, itemName),
		string.format('<span style="position: absolute;left:0;top:0;">[[File:InventorySlotBorder.png|class=hidden|%sx%spx|link=%s|alt=]]</span>', size, size, itemName),
		'</div>',
		'<div class="hidden" style="position: relative; z-index: 1; margin-left: -16px; margin-top: 98px; min-width: 96px; max-width: 116px; padding: 0 8px 0 8px; border: solid 2px #808080; background-color: rgba(45, 45, 45, 0.95)">',
		string.format('[[%s]]', itemName),
		'</div></div>',
	})
end

function p.itemFrame(frame)
	return p._itemFrame(frame:getParent().args)
end

function p.itemBox(frame)
	return p._itemBox(frame:getParent().args)
end

return p
