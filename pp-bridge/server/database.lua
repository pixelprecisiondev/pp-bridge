local function checkTable(tables)
    if not checkArgs(tables) then 
        bridgePrint("Invalid arguments provided to checkTable.", 'error')
        return 
    end

    local function tableExists(tableName, callback)
        MySQL.Async.fetchScalar("SHOW TABLES LIKE ?", {tableName}, function(result)
            callback(result ~= nil)
        end)
    end

    local function columnExists(tableName, columnName, callback)
        MySQL.Async.fetchScalar("SHOW COLUMNS FROM `" .. tableName .. "` LIKE ?", {columnName}, function(result)
            callback(result ~= nil)
        end)
    end

    local function primaryKeyExists(tableName, callback)
        MySQL.Async.fetchAll("SHOW KEYS FROM `" .. tableName .. "` WHERE Key_name = 'PRIMARY'", {}, function(result)
            callback(#result > 0)
        end)
    end

    local function createTable(tableName, columns)
        local columnsDef = {}
        local primaryKey = nil
        for _, column in ipairs(columns) do
            if column.type:upper() == "PRIMARY KEY" then
                primaryKey = column.name
            else
                local default = column.default and ("DEFAULT '" .. column.default .. "'") or ""
                if column.type:upper() == "TIMESTAMP" then
                    default = "DEFAULT CURRENT_TIMESTAMP"
                elseif column.type:upper() == "TEXT" then
                    default = ""
                elseif column.type == "AUTO_INCREMENT" then
                    default = "AUTO_INCREMENT"
                end
                table.insert(columnsDef, "`" .. column.name .. "` " .. column.type .. " " .. default)
            end
        end
        if primaryKey then
            table.insert(columnsDef, "PRIMARY KEY (`" .. primaryKey .. "`)")
        end
        local createQuery = "CREATE TABLE `" .. tableName .. "` (" .. table.concat(columnsDef, ", ") .. ")"
        MySQL.Async.execute(createQuery, {}, function(rowsChanged)
            if rowsChanged then
                bridgePrint("Created table " .. tableName .. " with " .. #columns .. " columns.", 'success')
            else
                bridgePrint("Failed to create table " .. tableName .. ".", 'error')
            end
        end)
    end

    local function addColumn(tableName, column)
        columnExists(tableName, column.name, function(exists)
            if not exists then
                local default = column.default and ("DEFAULT '" .. column.default .. "'") or ""
                if column.type:upper() == "TIMESTAMP" then
                    default = "DEFAULT CURRENT_TIMESTAMP"
                elseif column.type:upper() == "TEXT" then
                    default = ""
                elseif column.type == "AUTO_INCREMENT" then
                    default = ""
                end
                local addQuery = "ALTER TABLE `" .. tableName .. "` ADD `" .. column.name .. "` " .. column.type .. " " .. default
                MySQL.Async.execute(addQuery, {}, function(rowsChanged)
                    if rowsChanged then
                        bridgePrint("Added column " .. column.name .. " to table " .. tableName .. ".", 'success')
                    else
                        bridgePrint("Failed to add column " .. column.name .. " to table " .. tableName .. ".", 'error')
                    end
                end)
            end
        end)
    end

    local function getColumnCollation(tableName, columnName, callback)
        MySQL.Async.fetchAll("SHOW FULL COLUMNS FROM `" .. tableName .. "` WHERE Field = ?", {columnName}, function(result)
            if #result > 0 then
                callback(result[1].Collation)
            else
                callback(nil)
            end
        end)
    end

    local function changeCollation(tableName, columnName, collation)
        getColumnCollation(tableName, columnName, function(currentCollation)
            if currentCollation then
                local changeQuery = "ALTER TABLE `" .. tableName .. "` MODIFY `" .. columnName .. "` " .. collation
                MySQL.Async.execute(changeQuery, {}, function(rowsChanged)
                    if rowsChanged then
                        bridgePrint("Changed collation of column " .. columnName .. " in table " .. tableName .. " from " .. currentCollation .. " to " .. collation:match("COLLATE%s(%S+)") .. ".", 'success')
                    else
                        bridgePrint("Failed to change collation of column " .. columnName .. " in table " .. tableName .. ".", 'error')
                    end
                end)
            end
        end)
    end

    local function tableCollation(tableName, callback)
        MySQL.Async.fetchScalar("SELECT TABLE_COLLATION FROM information_schema.tables WHERE TABLE_NAME = ?", {tableName}, function(result)
            callback(result)
        end)
    end

    local function databaseCollation(callback)
        MySQL.Async.fetchScalar("SELECT @@collation_database", {}, function(result)
            callback(result)
        end)
    end

    local function finalize(success)
        if success then
            bridgePrint("Database checked successfully. No issues found.", 'success')
        else
            bridgePrint("Database check completed with some issues.", 'error')
        end
    end

    databaseCollation(function(dbCollation)
        if not dbCollation then
            bridgePrint("Cannot proceed without database collation.", 'error')
            return
        end

        local totalChecks = 0
        local completedChecks = 0
        local success = true

        for tableName, columns in pairs(tables) do
            totalChecks = totalChecks + 1
            tableExists(tableName, function(exists)
                if not exists then
                    createTable(tableName, columns)
                else
                    tableCollation(tableName, function(tableCol)
                        if tableCol and tableCol ~= dbCollation then
                            MySQL.Async.execute("ALTER TABLE `" .. tableName .. "` CONVERT TO CHARACTER SET utf8mb4 COLLATE " .. dbCollation, {}, function(rowsChanged)
                                if rowsChanged then
                                    bridgePrint("Changed collation of table " .. tableName .. " to " .. dbCollation .. ".", 'success')
                                else
                                    bridgePrint("Failed to change collation of table " .. tableName .. ".", 'error')
                                    success = false
                                end
                            end)
                        end

                        for _, column in ipairs(columns) do
                            columnExists(tableName, column.name, function(colExists)
                                if not colExists then
                                    addColumn(tableName, column)
                                elseif column.type == "AUTO_INCREMENT" then
                                    primaryKeyExists(tableName, function(pkExists)
                                        if not pkExists then
                                            addPrimaryKey(tableName, column.name)
                                        end
                                    end)
                                else
                                    getColumnCollation(tableName, column.name, function(colCollation)
                                        if colCollation and colCollation ~= dbCollation and column.type:upper() ~= "TIMESTAMP" then
                                            changeCollation(tableName, column.name, column.type .. " COLLATE " .. dbCollation)
                                        end
                                    end)
                                end
                            end)
                        end
                    end)
                end

                completedChecks = completedChecks + 1
                if completedChecks == totalChecks then
                    finalize(success)
                end
            end)
        end

        if totalChecks == 0 then
            finalize(success)
        end
    end)
end

exports('checkTable', checkTable)
