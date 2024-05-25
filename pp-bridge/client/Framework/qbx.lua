local data = {}

QBCore = exports['qb-core']:GetCoreObject()
qbx = exports.qbx_core

local function loadPlayerData()
    local charinfo = qbx:GetPlayerData().charinfo

    data.getName = function ()
        return {
            fullName = charinfo.firstname .. ' ' .. charinfo.lastname,
            firstName = charinfo.firstname,
            lastName = charinfo.lastname
        }
    end

    data.getJob = function()
        local job = qbx:GetPlayerData().job
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
        return qbx:GetPlayerData().charinfo.gender == 1 and "male" or "female"
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    loadPlayerData()
end)

if qbx:GetPlayerData().charinfo ~= nil then
    loadPlayerData()
end

return data
