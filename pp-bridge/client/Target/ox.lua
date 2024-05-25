local data = {}

local oxtarget = exports.ox_target

data.addEntityTarget = function(netIds, options)
    if not checkArgs(netIds, options) then return end
    oxtarget:addEntity(netIds, options)
end

data.addCircleZone = function(circledata)
    if not checkArgs(circledata.coords, circledata.options) then return end
    oxtarget:addSphereZone(circledata)
end

data.addBoxZone = function(boxdata)
    if not checkArgs(boxdata.coords, boxdata.size, boxdata.options) then return end
    oxtarget:addBoxZone({
        coords = boxdata.coords,
        size = boxdata.size,
        options = boxdata.options,
        debugPoly = boxdata.debugPoly,
        heading = boxdata.heading,
        minZ = boxdata.minZ,
        maxZ = boxdata.maxZ
    })
end

return data