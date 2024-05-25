local data = {}

data.getUserData = function(args, additionalColumns, callback)
    if not checkArgs(args, callback) then return end

    local baseColumns = { 'firstname', 'lastname', 'sex', 'dob', 'identifier' }
    local validColumns = {}
    local params = {}
    local conditions = {}

    for _, col in ipairs(baseColumns) do
        table.insert(validColumns, col)
    end

    if additionalColumns then
        for _, col in ipairs(additionalColumns) do
            table.insert(validColumns, col)
        end
    end


    MySQL.Async.fetchAll('SHOW COLUMNS FROM users', {}, function(columnsResult)
        local existingColumns = {}
        for _, column in ipairs(columnsResult) do
            existingColumns[column.Field] = true
        end

        local foundColumns = {}
        for _, col in ipairs(validColumns) do
            if existingColumns[col:gsub('`', '')] then
                table.insert(foundColumns, col)
            end
        end

        local useOr = args.useOr
        args.useOr = nil

        for k, v in pairs(args) do
            local columnName = k
            if v:find("%%") then
                table.insert(conditions, columnName .. ' LIKE @' .. k)
            else
                table.insert(conditions, columnName .. ' = @' .. k)
            end
            params['@' .. k] = v
        end

        local query = 'SELECT ' ..
            table.concat(foundColumns, ', ') ..
            ' FROM users WHERE ' .. table.concat(conditions, useOr and ' OR ' or ' AND ')
        MySQL.Async.fetchAll(query, params, function(result)
            if result and #result > 0 then
                local userData = {}
                for _, col in ipairs(foundColumns) do
                    userData[col:gsub('`', '')] = result[1][col:gsub('`', '')]
                end
                userData.sex = result[1].sex == 'm' and 'male' or 'female'
                callback(userData)
            else
                callback(nil)
            end
        end)
    end)
end



data.getVehicleData = function(args, additionalColumns, callback)
    if not checkArgs(args, callback) then return end

    local baseColumns = { 'owner', 'plate', 'vehicle', 'stored' }
    local validColumns = {}
    local params = {}
    local conditions = {}


    for _, col in ipairs(baseColumns) do
        table.insert(validColumns, col)
    end


    if additionalColumns then
        for _, col in ipairs(additionalColumns) do
            table.insert(validColumns, col)
        end
    end


    MySQL.Async.fetchAll('SHOW COLUMNS FROM owned_vehicles', {}, function(columnsResult)
        local existingColumns = {}
        for _, column in ipairs(columnsResult) do
            existingColumns[column.Field] = true
        end

        local foundColumns = {}
        for _, col in ipairs(validColumns) do
            if existingColumns[col:gsub('`', '')] then
                table.insert(foundColumns, col)
            end
        end

        for k, v in pairs(args) do
            table.insert(conditions, k .. ' = @' .. k)
            params['@' .. k] = v
        end

        local query = 'SELECT ' ..
            table.concat(foundColumns, ', ') .. ' FROM owned_vehicles WHERE ' .. table.concat(conditions, ' AND ')
        MySQL.Async.fetchAll(query, params, function(result)
            if #result > 0 then
                local vehicles = {}
                local remaining = #result

                for _, vehicle in ipairs(result) do
                    local ownerIdentifier = vehicle.owner
                    data.getUserData({ identifier = ownerIdentifier }, { 'firstname', 'lastname' }, function(userData)
                        local vehicleData = {
                            owner = userData and {
                                identifier = ownerIdentifier,
                                name = userData.firstname .. ' ' .. userData.lastname
                            } or nil,
                            plate = vehicle.plate,
                            hash = json.decode(vehicle.vehicle).model,
                            stored = vehicle.stored
                        }

                        for _, col in ipairs(additionalColumns or {}) do
                            vehicleData[col] = vehicle[col]
                        end
                        table.insert(vehicles, vehicleData)
                        remaining = remaining - 1
                        if remaining == 0 then
                            callback(vehicles)
                        end
                    end)
                end
            else
                callback(nil)
            end
        end)
    end)
end

return data
