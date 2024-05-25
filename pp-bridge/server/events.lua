-- RegisterNetEvent('esx:playerLoaded', function(playerId)
--     TriggerEvent('pp-bridge:framework:server:playerLoaded', tonumber(playerId))
-- end)

-- RegisterNetEvent('esx:playerLogout', function(playerId)
--     TriggerEvent('pp-bridge:framework:server:playerLogout', tonumber(playerId))
-- end)

-- RegisterNetEvent('QBCore:Player:OnPlayerLoaded', function(playerId)
--     TriggerEvent('pp-bridge:framework:server:playerLoaded', tonumber(playerId))
-- end)

-- RegisterNetEvent('QBCore:Player:OnPlayerUnload', function(playerId)
--     TriggerEvent('pp-bridge:framework:server:playerLogout', tonumber(playerId))
-- end)

-- RegisterNetEvent('ox_inventory:openedInventory', function(playerId, inventoryName)
--     TriggerEvent('pp-bridge:inventory:server:inventoryOpened', playerId, inventoryName)
-- end)

-- RegisterNetEvent('ox_inventory:closedInventory', function(playerId, inventoryName) 
--     TriggerEvent('pp-bridge:inventory:server:inventoryClosed', playerId, inventoryName)
-- end)

-- RegisterNetEvent('ox_inventory:usedItem', function(playerId, itemName, itemSlot, itemMetadata) 
--     TriggerEvent('pp-bridge:inventory:server:onItemUse', playerId, itemName, itemSlot, itemMetadata)
-- end)