local data = {}

ESX = exports['es_extended']:getSharedObject()

data.getName = function()
    if not ESX.PlayerData then 
        return {
            fullName = '',
            firstName = '',
            lastName = ''
        } 
    end
    return {
        fullName = ESX.PlayerData.firstName .. ' ' .. ESX.PlayerData.lastName,
        firstName = ESX.PlayerData.firstName,
        lastName = ESX.PlayerData.lastName
    }
end

data.getJob = function()
    if not ESX.PlayerData then 
        return {
            name = '',
            label = '',
            grade = 0,
            grade_label = ''
        }
    end
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
    return ESX.PlayerData and (ESX.PlayerData.sex == "m" and "male" or "female") or "male"
end

return data
