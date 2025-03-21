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

data.getJobs = function()
    local jobs = ESX.GetJobs()
    local response = {}

    for jobname, jobdata in pairs(jobs) do
        local jobInfo = {
            name = jobname,
            label = jobdata.label,
            grades = {}
        }

        for grade, gradeData in pairs(jobdata.grades) do
            jobInfo.grades[tonumber(grade)] = {
                grade = tonumber(grade),
                name = gradeData.name,
                label = gradeData.label
            }
        end

        table.insert(response, jobInfo)
    end

    return response
end

return data
