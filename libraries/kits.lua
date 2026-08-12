-- Kits category
-- BedWars-specific category for kit modules.

local vape = shared.vape
if not vape or not vape.CreateCategory then
	return
end

if game.PlaceId ~= 6872274481 or vape.Categories.Kits then
	return
end

vape:CreateCategory({
	Name = 'Kits',
	Icon = getcustomasset('newvape/assets/new/miniicon.png'),
	Size = UDim2.fromOffset(19, 12)
})
