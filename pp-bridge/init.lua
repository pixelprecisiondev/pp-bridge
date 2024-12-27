Bridge = {}

local Config = {
    Framework = {
        client = {
            ['es_extended'] = 'esx.lua',
            ['qb-core'] = 'qb.lua',
            ['qbx_core'] = 'qbx.lua',
            --['ox_core'] = 'ox.lua'
        },
        server = {
            ['es_extended'] = 'esx.lua',
            ['qb-core'] = 'qb.lua',
            ['qbx_core'] = 'qbx.lua',
            --['ox_core'] = 'ox.lua'
        },
    },
    Inventory = {
        client = {
            ['ox_inventory'] = 'ox_inv.lua',
            ['qb-inventory'] = 'qb_inv.lua',
            ['qb-core'] = 'qb.lua',
            ['es_extended'] = 'esx.lua'
        },
        server = {
            ['ox_inventory'] = 'ox_inv.lua',
            ['qb-inventory'] = 'qb_inv.lua',
            ['qb-core'] = 'qb.lua',
            ['es_extended'] = 'esx.lua'
        },
    },
    Target = {
        client = {
            ['ox_target'] = 'ox.lua',
            ['qb-target'] = 'qb.lua'
        }
    },
    Database = {
        server = {
            ['es_extended'] = 'esx.lua',
            ['qb-core'] = 'qb.lua',
            ['qbx_core'] = 'qbx.lua',
            --['ox_core'] = 'ox.lua'
        }
    }
}

local resourceName = GetCurrentResourceName()
local isBridge = GetResourceMetadata(resourceName, 'isBridge', 0)

if resourceName ~= 'pp-bridge' and isBridge == 'true' then
    Citizen.CreateThread(function()
        while true do 
            Citizen.Wait(1000)
            print(('Change resource name from %s to pp-bridge'):format(resourceName))
        end
    end)
    return
end

local printtypes = {
    ['error'] = '^1[ERROR] ^0',
    ['success'] = '^2[SUCCESS] ^0',
    ['info'] = '^4[INFO] ^0'
}

function bridgePrint(message, type, bridge)
    if bridge and resourceName ~= 'pp-bridge' then return end
    local prefix = printtypes[type] or printtypes['error']
    print(prefix .. message)
end

function checkArgs(...)
    local args = {...}
    local funcInfo = debug.getinfo(2, "nSl")
    local funcName = funcInfo and funcInfo.name or "unknown function"

    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        local argName = debug.getlocal and debug.getlocal(2, i) or ("arg#%d"):format(i)
        if arg == nil then
            print(("^1[ERROR] ^0Missing required argument '%s' in %s"):format(argName or "unknown argument", funcName))
            return false
        end
    end
    return true
end

local function loadBridgeModule(modulePath)
    local file = LoadResourceFile('pp-bridge', modulePath)
    if not file then
        bridgePrint(('Failed to load module %s: File not found'):format(modulePath), 'error', true)
        return nil
    end

    local func, err = load(file, modulePath)
    if not func then
        bridgePrint(('Failed to load module %s: %s'):format(modulePath, err), 'error', true)
        return nil
    end

    local success, module = pcall(func)
    if not success then
        bridgePrint(('Failed to load module %s: %s'):format(modulePath, module), 'error', true)
        return nil
    end

    return module
end

local server = IsDuplicityVersion()

local function setup()
    local settings = {
        Framework = GetConvar('pp-bridge:Framework', 'auto'),
        Inventory = GetConvar('pp-bridge:Inventory', 'auto'),
        Target = GetConvar('pp-bridge:Target', 'auto'),
        Database = GetConvar('pp-bridge:Database', 'auto')
    }

    for name, setting in pairs(settings) do
        if setting == 'auto' then
            settings[name] = nil
            bridgePrint(('Auto-detecting %s modules'):format(name), 'info', true)
        elseif setting then
            bridgePrint(('%s module forced to %s'):format(name, setting), 'info', true)
        end
    end

    local missingCategories = {}
    local loadedModules = {client = {}, server = {}}

    for name, module in pairs(Config) do
        local setting = settings[name]

        if server and module.server then
            for framework, path in pairs(module.server) do
                if loadedModules.server[name] then break end
                if setting and framework ~= setting then
                    goto continue
                end
                if GetResourceState(framework) ~= "missing" or (setting and framework == setting) then
                    local data = loadBridgeModule('server/' .. name .. '/' .. path)
                    if data then
                        for funcName, func in pairs(data) do
                            Bridge[funcName] = func
                        end
                        bridgePrint(('%s %s server module loaded'):format(framework, name), 'success', true)
                        loadedModules.server[name] = true
                    else
                        bridgePrint(('Failed to load %s %s server module'):format(framework, name), 'error', true)
                    end
                end
                ::continue::
            end
            if not loadedModules.server[name] and name ~= 'Target' then
                table.insert(missingCategories, name)
            end
        elseif not server and module.client then
            for framework, path in pairs(module.client) do
                if loadedModules.client[name] then break end
                Citizen.CreateThread(function()
                    if name == 'Target' and GetResourceState('ox_target') ~= "missing" and framework ~= 'ox_target' then
                        bridgePrint(('Skipping %s %s client module because ox_target is available'):format(framework, name), 'info', true)
                        return
                    elseif name == 'Framework' and GetResourceState('qbx_core') ~= "missing" and framework == 'qb-core' then
                        bridgePrint(('Skipping %s %s client module because qbx_core is available'):format(framework, name), 'info', true)
                        return
                    end
                    if setting and framework ~= setting then
                        return
                    end
                    while GetResourceState(framework) == "starting" do
                        Citizen.Wait(100)
                    end
                    if GetResourceState(framework) ~= "missing" or (setting and framework == setting) then
                        local data = loadBridgeModule('client/' .. name .. '/' .. path)
                        if data then
                            for funcName, func in pairs(data) do
                                Bridge[funcName] = func
                            end
                            bridgePrint(('%s %s client module loaded'):format(framework, name), 'success', true)
                            loadedModules.client[name] = true
                        else
                            bridgePrint(('Failed to load %s %s client module'):format(framework, name), 'error', true)
                        end
                    end
                end)
            end
        end
    end

    if server then
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(1000)
                for _, category in ipairs(missingCategories) do
                    bridgePrint(('No active resources found for category %s, functionality will not work'):format(category), 'error', true)
                end
            end
        end)
    end
end

setup()
