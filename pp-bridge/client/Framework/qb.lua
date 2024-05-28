local data = {}

QBCore = exports['qb-core']:GetCoreObject()



data.getName = function ()
    local charinfo = QBCore.Functions.GetPlayerData().charinfo
    if not charinfo then 
        return {
            fullName = '',
            firstName = '',
            lastName = ''
        } 
    end
    return {
        fullName = charinfo.firstname .. ' ' .. charinfo.lastname,
        firstName = charinfo.firstname,
        lastName = charinfo.lastname
    }
end

data.getJob = function()
    local job = QBCore.Functions.GetPlayerData().job
    if not job then 
        return {
            name = '',
            label = '',
            grade = 0,
            grade_label = ''
        }
    end
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
    local charinfo = QBCore.Functions.GetPlayerData().charinfo
    return charinfo and (charinfo.gender == 1 and "male" or "female") or "male"
end

return data
