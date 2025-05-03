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
-----------SEND TO DISCORD EVENT--------------------------------------
-----------------------------------------------------------------------
RegisterServerEvent('rpchat:sendToDiscord')
AddEventHandler('rpchat:sendToDiscord', function(command, message, color)
    local webhookURL = Config.DiscordWebhookURLs[command]
    if not webhookURL then
        debugPrint("No webhook URL found for command: " .. command)
        return
    end

    if webhookURL == 'HOOK' then
        debugPrint("No webhook configured for this command: " .. command)
        return
    end

    local playerId = source
    local identifiers = GetPlayerIdentifiers(playerId)
    local discordId

    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, "discord:") then
            discordId = string.sub(identifier, 9)
            break
        end
    end

    if not discordId then
        discordId = "Not connected"
    end

    local playerName = GetPlayerName(playerId)
    local embedConfig = Config.EmbedConfig
    local translation = embedConfig.translation

    local embed = {
        {
            ["color"] = color or embedConfig.color[command],
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S"),
            ["fields"] = {
                {
                    ["name"] = translation.player,
                    ["value"] = playerName
                },
                {
                    ["name"] = translation.discordNickname,
                    ["value"] = (discordId ~= "Not connected") and ("<@" .. discordId .. ">") or "Not connected"
                },
                {
                    ["name"] = translation.time,
                    ["value"] = os.date("%H:%M:%S")
                },
                {
                    ["name"] = translation.message,
                    ["value"] = message
                }
            }
        }
    }

    PerformHttpRequest(webhookURL, function(err, text, headers)
        if err == 200 or err == 204 then
            debugPrint("Message sent successfully to Discord.")
        else
            debugPrint("Error sending message to Discord webhook: " .. tostring(err))
        end
    end, 'POST', json.encode({
        username = embedConfig.username,
        avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png?ex=6816caa1&is=68157921&hm=9157e009449d8dd42d1c8f0203ef5f0921038ca2430708cc237821d0e921875e",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end)
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

