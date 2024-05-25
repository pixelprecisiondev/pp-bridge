local data = {}

local qbtarget = exports['qb-target']

data.addEntityTarget = function(netIds, options)
    if not checkArgs(netIds, options) then return end
    local formattedOptions = {}
    for _, option in pairs(options) do
        table.insert(formattedOptions, {
            icon = option.icon,
            label = option.label,
            action = option.onSelect,
            job = option.groups,
            distance = option.distance
        })
    end
    qbtarget:AddTargetEntity(netIds, { options = formattedOptions, distance = 2.0 })
end

data.addCircleZone = function(circledata)
    if not checkArgs(circledata.coords, circledata.options) then return end
    local name = circledata.name or ("circleZone" .. math.random(1, 999999999))
    local radius = circledata.radius or 1.5
    local formattedOptions = {}
    for _, option in pairs(circledata.options) do
        table.insert(formattedOptions, {
            icon = option.icon,
            label = option.label,
            action = option.onSelect,
            job = option.groups,
            distance = option.distance
        })
    end
    qbtarget:AddCircleZone(name, circledata.coords, radius, { name = name, debugPoly = circledata.debugPoly or false }, {
        options = formattedOptions,
        distance = circledata.distance or 2.0
    })
end

data.addBoxZone = function(boxdata)
    if not checkArgs(boxdata.coords, boxdata.size, boxdata.options) then return end
    local name = boxdata.name or ("boxZone" .. math.random(1, 999999999))
    local length = boxdata.size.x
    local width = boxdata.size.y
    local heading = boxdata.heading or 0.0
    local formattedOptions = {}
    for _, option in pairs(boxdata.options) do
        table.insert(formattedOptions, {
            icon = option.icon,
            label = option.label,
            action = option.onSelect,
            job = option.groups,
            distance = option.distance
        })
    end
    qbtarget:AddBoxZone(name, boxdata.coords, length, width, { name = name, heading = heading, debugPoly = boxdata.debugPoly or false, minZ = boxdata.minZ or boxdata.coords.z - 1, maxZ = boxdata.maxZ or boxdata.coords.z + 1 }, {
        options = formattedOptions,
        distance = boxdata.distance or 2.0
    })
end

return data
