local data = {}

local QBCore = exports['qb-core']:GetCoreObject()

data.openInventory = function(playerId, inventoryType, inventoryData)
    --[[ NOT AVAILABLE ]]
    return false
end

data.addItem = function(inventoryName, item, count, metadata)
    if not checkArgs(inventoryName, item, count) then return end
    local Player = QBCore.Functions.GetPlayer(inventoryName)
    if Player then
        if item == 'money' then
            Player.Functions.AddMoney('cash', count)
            return true
        else
            return Player.Functions.AddItem(item, count, false, metadata)
        end
    end
    return false
end

data.removeItem = function(inventoryName, item, count, metadata)
    if not checkArgs(inventoryName, item, count) then return end
    local Player = QBCore.Functions.GetPlayer(inventoryName)
    if Player then
        if item == 'money' then
            Player.Functions.RemoveMoney('cash', count)
            return true
        else
            return Player.Functions.RemoveItem(item, count)
        end
    end
    return false
end

data.canCarryItem = function(inventoryName, item, count, metadata)
    --[[ NOT AVAILABLE ]]
    return true
end

data.getItemCount = function(inventoryName, item, metadata)
    if not checkArgs(inventoryName, item) then return end
    local Player = QBCore.Functions.GetPlayer(inventoryName)
    if Player then
        if item == 'money' then
            return Player.Functions.GetMoney('cash')
        else
            return Player.Functions.GetItemByName(item) and Player.Functions.GetItemByName(item).amount or 0
        end
    end
    return 0
end

data.registerStash = function(stashName, stashLabel, stashSlots, stashMaxWeight, stashOwner, stashGroups)
    --[[ NOT AVAILABLE ]]
    return false
end

data.setDurability = function(inventoryName, itemSlot, durability)
    if not checkArgs(inventoryName, itemSlot, durability) then return end
    local Player = QBCore.Functions.GetPlayer(inventoryName)
    if Player then
        local item = Player.Functions.GetItemBySlot(itemSlot)
        if item then
            item.info.durability = durability
            Player.Functions.SetInventory(Player.PlayerData.items)
            return true
        end
    end
    return false
end

return data