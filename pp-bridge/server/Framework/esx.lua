ESX = exports['es_extended']:getSharedObject()

local function validatePlayer(player)
    if not player or not player.source then
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
    local player = ESX.GetPlayerFromId(tonumber(playerId))
    return player
end

data.getPlayerFromIdentifier = function(playerIdentifier)
    if not checkArgs(playerIdentifier) then return end
    local player = ESX.GetPlayerFromIdentifier(playerIdentifier)
    return player
end

data.getIdentifier = function(frPlayer)
    if not checkArgs(frPlayer) or not validatePlayer(frPlayer) then return end
    local identifier = frPlayer.getIdentifier()
    return identifier
end

data.RegisterServerCallback = function(name, callback)
    if not checkArgs(name, callback) then return end
    return ESX.RegisterServerCallback(name, callback)
end

data.getSource = function(frPlayer)
    if not checkArgs(frPlayer) or not validatePlayer(frPlayer) then return end
    local frsource = frPlayer.source
    return frsource
end

data.getName = function(frPlayer)
    if not checkArgs(frPlayer) or not validatePlayer(frPlayer) then return end
    local response = {
        fullName = frPlayer.getName(),
        firstName = frPlayer.get("firstName"),
        lastName = frPlayer.get("lastName")
    }

    return response
end

data.getJob = function(frPlayer)
    if not checkArgs(frPlayer) or not validatePlayer(frPlayer) then return end
    local job = frPlayer.getJob()
    local response = {
        name = job.name,
        label = job.label,
        grade = job.grade,
        grade_name = job.grade_name,
        grade_label = job.grade_label,
    }
    
    return response
end

data.getAllPlayers = function()
    return ESX.GetExtendedPlayers()
end

data.setJob = function(frPlayer, job, grade)
    if not checkArgs(frPlayer, job, grade) or not validatePlayer(frPlayer) then return end
    frPlayer.setJob(job, grade)
end

data.doesJobExist = function(job, grade)
    if not checkArgs(job, grade) then return end
    return ESX.DoesJobExist(job, grade)
end

data.getCoords = function(frPlayer)
    if not checkArgs(frPlayer) or not validatePlayer(frPlayer) then return end
    local ped = GetPlayerPed(frPlayer.source)
    if not ped or ped == -1 then return end
    local coords = GetEntityCoords(ped)
    return vec3(coords.x, coords.y, coords.z)
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