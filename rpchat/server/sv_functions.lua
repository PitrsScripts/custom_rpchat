local ESX = nil
ESX = exports["es_extended"]:getSharedObject()
---------------------------------
-----------DISCORD LOG-----------
---------------------------------
RegisterServerEvent('rpchat:sendToDiscord')
AddEventHandler('rpchat:sendToDiscord', function(command, message, color)
    local webhookURL = Config.DiscordWebhookURLs[command]
    if not webhookURL then
        print("No webhook URL found for command: " .. command)
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
        print("No Discord ID found for playerId: " .. tostring(playerId))
        discordId = "Není propojeno"
    end

    local playerName = GetPlayerName(playerId)
    local embedConfig = Config.EmbedConfig
    local translation = embedConfig.translation

    -- Získat Discord nickname z Discord API
    local discordNick = "Není propojeno"
    if discordId then
        discordNick = GetDiscordNickname(discordId) or "Není propojeno"
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
            print("Chyba při odesílání na Discord webhook: " .. err)
        else
            print("Zpráva byla úspěšně odeslána na Discord.")
        end
    end, 'POST', json.encode({
        username = embedConfig.username,
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end)
--------------------------------------
-------DISCORD PLAYER NAME FUNCTION---
--------------------------------------
function GetDiscordNickname(discordId)
    local botToken = Config.DiscordBotToken
    local url = "https://discord.com/api/v6/users/" .. discordId

    local headers = {
        ["Authorization"] = "Bot " .. botToken,
        ["Content-Type"] = "application/json"
    }

    local response = nil

    PerformHttpRequest(url, function(err, text, headers)
        if err == 200 then
            local data = json.decode(text)
            response = data.username .. "#" .. data.discriminator
        else
            print("Chyba při získávání Discord nickname: " .. err)
        end
    end, 'GET', '', headers)

    while response == nil do
        Citizen.Wait(0)
    end

    return response
end
--------------------------------------
-----------PLAYER NAME FUNCTION-------
--------------------------------------
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


