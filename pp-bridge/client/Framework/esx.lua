local data = {}

ESX = exports['es_extended']:getSharedObject()

local function loadPlayerData()
    data.getName = function()
        return {
            fullName = ESX.PlayerData.firstName .. ' ' .. ESX.PlayerData.lastName,
            firstName = ESX.PlayerData.firstName,
            lastName = ESX.PlayerData.lastName
        }
    end

    data.getJob = function()
        return {
            name = ESX.PlayerData.job.name,
            label = ESX.PlayerData.job.label,
            grade = ESX.PlayerData.job.grade,
            grade_label = ESX.PlayerData.job.grade_label
        }
    end

    data.TriggerServerCallback = function(name, cb, ...)
        ESX.TriggerServerCallback(name, cb, ...)
    end

    data.getSex = function()
        return ESX.PlayerData.sex == "m" and "male" or "female"
    end
end

AddEventHandler('esx:playerLoaded', function(playerData)
    ESX.PlayerData = playerData
    loadPlayerData()
end)

if ESX.IsPlayerLoaded() then
    loadPlayerData()
end

return data
