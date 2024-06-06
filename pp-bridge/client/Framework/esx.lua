local data = {}

ESX = exports['es_extended']:getSharedObject()

data.getName = function()
    local playerdata = ESX.GetPlayerData()
    if not playerdata?.firstName then 
        return {
            fullName = '',
            firstName = '',
            lastName = ''
        } 
    end
    return {
        fullName = playerdata.firstName .. ' ' .. playerdata.lastName,
        firstName = playerdata.firstName,
        lastName = playerdata.lastName
    }
end

data.getJob = function()
    local playerdata = ESX.GetPlayerData()
    if not playerdata?.job then 
        return {
            name = '',
            label = '',
            grade = 0,
            grade_label = ''
        }
    end
    return {
        name = playerdata.job.name,
        label = playerdata.job.label,
        grade = playerdata.job.grade,
        grade_label = playerdata.job.grade_label
    }
end

data.TriggerServerCallback = function(name, cb, ...)
    ESX.TriggerServerCallback(name, cb, ...)
end

data.getSex = function()
    local playerdata = ESX.GetPlayerData()
    return playerdata?.sex and (playerdata.sex == "m" and "male" or "female") or "male"
end

return data
