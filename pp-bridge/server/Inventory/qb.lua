local data = {}

local QBCore = exports['qb-core']:GetCoreObject()
local inventory = exports['qb-inventory']

data.openInventory = function(playerId, inventoryType, inventoryData)
    if not checkArgs(playerId, inventoryType, inventoryData) then return end
    return inventory:OpenInventory(playerId, inventoryType, inventoryData)
end

data.addItem = function(inventoryName, item, count, metadata)
    if not checkArgs(inventoryName, item, count) then return end
    if item == 'money' then
        local Player = QBCore.Functions.GetPlayer(inventoryName)
        if Player then
            Player.Functions.AddMoney('cash', count)
            return true
        end
    else
        local success = inventory:AddItem(inventoryName, item, count, false, metadata, 'scripted')
        return success
    end
end

data.removeItem = function(inventoryName, item, count, metadata)
    if not checkArgs(inventoryName, item, count) then return end
    if item == 'money' then
        local Player = QBCore.Functions.GetPlayer(inventoryName)
        if Player then
            Player.Functions.RemoveMoney('cash', count)
            return true
        end
    else
        local success = inventory:RemoveItem(inventoryName, item, count, false, 'scripted')
        return success
    end
end

data.canCarryItem = function(inventoryName, item, count, metadata)
    if not checkArgs(inventoryName, item, count) then return end
    if item == 'money' then
        return true
    else
        local canCarry, reason = inventory:CanAddItem(inventoryName, item, count)
        return canCarry
    end
end

data.getItemCount = function(inventoryName, item, metadata)
    if not checkArgs(inventoryName, item) then return end
    if item == 'money' then
        local Player = QBCore.Functions.GetPlayer(inventoryName)
        if Player then
            return Player.Functions.GetMoney('cash')
        end
    else
        return inventory:GetItemCount(inventoryName, item)
    end
end

data.registerStash = function(stashName, stashLabel, stashSlots, stashMaxWeight, stashOwner, stashGroups)
    if not checkArgs(stashName, stashLabel, stashSlots, stashMaxWeight) then return end
    inventory:CreateStash({
        name = stashName,
        label = stashLabel,
        slots = stashSlots,
        maxweight = stashMaxWeight
    })
end

data.setDurability = function(inventoryName, itemSlot, durability)
    if not checkArgs(inventoryName, itemSlot, durability) then return end
    local item = inventory:GetItemBySlot(inventoryName, itemSlot)
    if item then
        item.info.durability = durability
        inventory:SetItemData(inventoryName, item.name, 'info', item.info)
    end
end

return data
