local data = {}

local inventory = exports['qb-inventory']

data.openInventory = function(inventoryType, inventoryData)
    if not checkArgs(inventoryType, inventoryData) then return end
    inventory:OpenInventory(inventoryType, inventoryData)
end

data.getCurrentWeapon = function()
    local playerPed = PlayerPedId()
    local weaponHash = GetSelectedPedWeapon(playerPed)
    local weapon = nil
    
    for _, item in pairs(QBCore.Functions.GetPlayerData().items) do
        if item.name == weaponHash then
            weapon = item
            break
        end
    end
    
    return weapon
end

data.getItemCount = function(itemName, metadata)
    if not checkArgs(itemName) then return end
    return inventory:GetItemCount(itemName)
end

return data
