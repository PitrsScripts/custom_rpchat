local ESX = nil
local ESX = exports["es_extended"]:getSharedObject()

-----------------------------------------------------------------------
-----------DISCORD LOG-------------------------------------------------
-----------------------------------------------------------------------
Citizen.CreateThread(function()
    if not Config.Debug then return end

    print("^5[PITRS RPCHAT] ^7Checking Discord webhooks on startup...")

    local isWebhookConfigured = false

    for command, webhookURL in pairs(Config.DiscordWebhookURLs) do
        if webhookURL and webhookURL ~= 'HOOK' then
            isWebhookConfigured = true
        end
    end

    if isWebhookConfigured then
        print("^5[PITRS RPCHAT] ^7Discord log is set up successfully.")
    else
        print("^5[PITRS RPCHAT] ^7No Discord log set, please configure config.lua")
    end
end)

-----------------------------------------------------------------------
-----------DEBUG FUNCTION----------------------------------------------
-----------------------------------------------------------------------
local function debugPrint(message)
    if Config.Debug then
        print("^5[PITRS RPCHAT DEBUG] ^7" .. message)
    end
end
-----------------------------------------------------------------------
-----------PLAYER NAME FUNCTION---------------------------------------
-----------------------------------------------------------------------
function GetCharacterName(source)
    local Player = ESX.GetPlayerFromId(source)
    if Player then
        return Player.get('name')  -- 'name' includes both firstname and lastname
    end
end

function GetPlayerName2(source)
    local Player = ESX.GetPlayerFromId(source)
    if Player then
        return Player.get('name') -- Get the full name as it is a single string in ESX
    end
end

function GetPlayerNameSteam(source)
    return GetPlayerName(source)
end

function GetLastName(source)
    local Player = ESX.GetPlayerFromId(source)
    if Player then
        local name = Player.get('name')
        local splitName = string.split(name, " ")
        return splitName[2]  -- Extracts last name (assuming it's in first name, last name format)
    end
end

function GetJobName(source)
    local Player = ESX.GetPlayerFromId(source)
    if Player then
        return Player.job.label  -- Accesses the job directly from Player object
    end
end

function IsPlayerVIP(source)
    if not Config.VIPSystem then return false end
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.sub(identifier, 1, 8) == "license:" then
            local license = string.sub(identifier, 9)
            for _, vip in ipairs(Config.VIPLicenses or {}) do
                if vip == license then
                    return true
                end
            end
        end
    end
    return false
end

function GetPlayerNameWithVIP(source)
    local name = GetPlayerName(source)
    if not Config.VIPSystem then return name end
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.sub(identifier, 1, 8) == "license:" then
            local license = string.sub(identifier, 9)
            for _, vip in ipairs(Config.VIPLicenses or {}) do
                if vip == license then
                    return "⭐ " .. name
                end
            end
        end
    end
    return name
end

RegisterNetEvent('rpchat:requestPlayerLicense')
AddEventHandler('rpchat:requestPlayerLicense', function()
    local src = source
    local license = nil
    for k, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            license = string.sub(v, 9)
            break
        end
    end
    TriggerClientEvent('rpchat:receivePlayerLicense', src, license)
end)

-- Funkce pro získání reálného času
RegisterNetEvent('rpchat:requestRealTime')
AddEventHandler('rpchat:requestRealTime', function()
    local src = source
    local realTime = os.date('*t')
    local timeString = string.format('[%02d:%02d]', realTime.hour, realTime.min)
    TriggerClientEvent('rpchat:receiveRealTime', src, timeString)
end)
