local data = {}

local inventory = exports.ox_inventory

data.openInventory = function(inventoryType, inventoryData)
    if not checkArgs(type, data) then return end
    inventory:openInventory(inventoryType, inventoryData)
end

data.getCurrentWeapon = function()
    return inventory:getCurrentWeapon()
end

data.getItemCount = function(itemName, metadata)
    if not checkArgs(itemName) then return end
    return inventory:GetItemCount(itemName, metadata)
end

return data