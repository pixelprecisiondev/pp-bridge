local data = {}

QBCore = exports['qb-core']:GetCoreObject()

local function loadPlayerData()
    local charinfo = QBCore.Functions.GetPlayerData().charinfo

    data.getName = function ()
        return {
            fullName = charinfo.firstname .. ' ' .. charinfo.lastname,
            firstName = charinfo.firstname,
            lastName = charinfo.lastname
        }
    end

    data.getJob = function()
        local job = QBCore.Functions.GetPlayerData().job
        return {
            name = job.name,
            label = job.label,
            grade = job.grade.level,
            grade_label = job.grade.name
        }
    end

    data.TriggerServerCallback = function(name, cb, ...)
        QBCore.Functions.TriggerCallback(name, cb, ...)
    end

    data.getSex = function()
        return QBCore.Functions.GetPlayerData().charinfo.gender == 1 and "male" or "female"
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    print('loaded')
    loadPlayerData()
end)
print(type(QBCore.Functions.GetPlayerData().charinfo), 'type')
if QBCore.Functions.GetPlayerData().charinfo ~= nil then
    print('loaded')
    loadPlayerData()
end

return data
