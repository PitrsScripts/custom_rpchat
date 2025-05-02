local ESX = nil
ESX = exports["es_extended"]:getSharedObject()

local discordBotToken = "MTMwOTY5NzU3OTg1NjE3MTA3OQ.G6gg5c.MPspQLfPV36UXK6bJLC0ozZtfVcqwUHEacNjgQ"

-----------------------------------------------------------------------
-----------DISCORD LOG-------------------------------------------------
-----------------------------------------------------------------------
Citizen.CreateThread(function()
    print("^5[PITRS RPCHAT] ^7Checking Discord webhooks on startup...")

    local isWebhookConfigured = false

    for command, webhookURL in pairs(Config.DiscordWebhookURLs) do
        if webhookURL ~= 'HOOK' then
            isWebhookConfigured = true
        end
    end

    if isWebhookConfigured then
        print("^5[PITRS RPCHAT] ^7Discord log is set up successfully..")
    else
        print("^5[PITRS RPCHAT] ^7No Discord log set please configure config.lua")
    end
end)

RegisterServerEvent('rpchat:sendToDiscord')
AddEventHandler('rpchat:sendToDiscord', function(command, message, color)
    local webhookURL = Config.DiscordWebhookURLs[command]
    if not webhookURL then
        print("No webhook URL found for command: " .. command)
        return
    end

    if webhookURL ~= 'HOOK' then
        print(string.format("^5[RPCHAT] ^7Sending message to Discord for command ^3%s ^7with color ^1%s", command, color))
    else
        print("^5[PITRS RPCHAT] ^7No webhook configured for this command: ^3" .. command)
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
        print("No Discord ID found for playerId: " .. tostring(playerId))
        discordId = "Not connected"
    end

    local playerName = GetPlayerName(playerId)
    local embedConfig = Config.EmbedConfig
    local translation = embedConfig.translation
    local discordNick = "Not connected"
    if discordId then
        discordNick = GetDiscordNickname(discordId) or "Not connected"
    end

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
                    ["value"] = discordNick
                },
                {
                    ["name"] = translation.time,
                    ["value"] = os.date("%Y-%m-%d %H:%M:%S")
                },
                {
                    ["name"] = translation.todayAt,
                    ["value"] = os.date("%H:%M")
                },
                {
                    ["name"] = translation.message,
                    ["value"] = message
                }
            }
        }
    }

    PerformHttpRequest(webhookURL, function(err, text, headers)
        if err ~= 200 then
            --print("Error posting to Discord webhook: " .. err)
        else
           -- print("Message has been successfully sent to Discord.")
        end
    end, 'POST', json.encode({
        username = embedConfig.username,  -- Název bota
        avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png?ex=68157921&is=681427a1&hm=4aad44ff457d9c7f06dd798eb3e1ce992d3952ec10cf9e4a5add80fbafd386c2&", 
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end)
----------------------------------------------------------------------------
-------DISCORD PLAYER NAME FUNCTION-----------------------------------------
----------------------------------------------------------------------------

function GetDiscordNickname(discordId)
    local url = "https://discord.com/api/v6/users/" .. discordId

    local headers = {
        ["Authorization"] = "Bot " .. discordBotToken,
        ["Content-Type"] = "application/json"
    }

    local response = nil

    PerformHttpRequest(url, function(err, text, headers)
        if err == 200 then
            local data = json.decode(text)
            response = data.username .. "#" .. data.discriminator
        else
            print("Error getting Discord nickname: " .. err)
        end
    end, 'GET', '', headers)

    while response == nil do
        Citizen.Wait(0)
    end

    return response
end
----------------------------------------------------------------------------
-----------PLAYER NAME FUNCTION---------------------------------------------
----------------------------------------------------------------------------

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
