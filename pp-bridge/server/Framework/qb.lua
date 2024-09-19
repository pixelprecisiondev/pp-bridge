QBCore = exports['qb-core']:GetCoreObject()

local function validatePlayer(player)
    if not player or not player.PlayerData or not player.PlayerData.source then
        local funcInfo = debug.getinfo(2, "nSl")
        local funcName = funcInfo.name or "unknown function"
        bridgePrint(("Framework player is not valid in function '%s'"):format(funcName), 'error')
        return false
    end
    return true
end

local data = {}

data.getPlayerFromId = function(playerId)
    if not checkArgs(playerId) then return end
    local player = QBCore.Functions.GetPlayer(playerId)
    return player
end

data.getPlayerFromIdentifier = function(playerIdentifier)
    if not checkArgs(playerIdentifier) then return end
    local player = QBCore.Functions.GetPlayerByCitizenId(playerIdentifier)
    return player
end

data.getIdentifier = function(frPlayer)
    if not checkArgs(frPlayer) or not validatePlayer(frPlayer) then return end
    local identifier = frPlayer.PlayerData.citizenid
    return identifier
end

data.RegisterServerCallback = function(name, callback)
    if not checkArgs(name, callback) then return end
    QBCore.Functions.CreateCallback(name, callback)
end

data.getSource = function(frPlayer)
    if not checkArgs(frPlayer) or not validatePlayer(frPlayer) then return end
    return frPlayer.PlayerData.source
end

data.getName = function(frPlayer)
    if not checkArgs(frPlayer) or not validatePlayer(frPlayer) then return end
    local response = {
        fullName = frPlayer.PlayerData.charinfo.firstname .. ' ' .. frPlayer.PlayerData.charinfo.lastname,
        firstName = frPlayer.PlayerData.charinfo.firstname,
        lastName = frPlayer.PlayerData.charinfo.lastname
    }

    return response
end

data.getJob = function(frPlayer)
    if not checkArgs(frPlayer) or not validatePlayer(frPlayer) then return end
    local job = frPlayer.PlayerData.job
    local response = {
        name = job.name,
        label = job.label,
        grade = job.grade.level,
        grade_label = job.grade.name,
    }
    
    return response
end

data.getAllPlayers = function()
    local players = {}
    for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
        table.insert(players, QBCore.Functions.GetPlayer(playerId))
    end
    return players
end

data.setJob = function(frPlayer, job, grade)
    if not checkArgs(frPlayer, job, grade) or not validatePlayer(frPlayer) then return end
    frPlayer.Functions.SetJob(job, grade)
end

data.doesJobExist = function(job, grade)
    if not checkArgs(job, grade) then return end
    local jobs = QBCore.Shared.Jobs
    return jobs[job] and jobs[job].grades[tonumber(grade)] ~= nil
end

data.getCoords = function(frPlayer)
    if not checkArgs(frPlayer) or not validatePlayer(frPlayer) then return end
    local ped = GetPlayerPed(frPlayer.PlayerData.source)
    if not ped or ped == -1 then return end
    local coords = GetEntityCoords(ped)
    return vec3(coords.x, coords.y, coords.z)
end

data.getJobs = function()
    local jobs = QBCore.Shared.Jobs
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
