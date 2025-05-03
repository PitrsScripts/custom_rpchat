local ESX = nil
local lastCommand = {} 

ESX = exports["es_extended"]:getSharedObject()

-- Cooldown Commands
local function handleCooldown(source, commandName)
    local currentTime = os.time()  
    if lastCommand[source] and (currentTime - lastCommand[source] < Config.CommandCooldown) then
        local remainingTime = Config.CommandCooldown - (currentTime - lastCommand[source])
        
        local data = {
            title = 'Cooldown',
            description = 'Please wait ' .. remainingTime .. ' seconds before using ' .. commandName .. ' again.',
            type = 'error',
            duration = 3000  
        }
        
        TriggerClientEvent('ox_lib:notify', source, data)
        return false
    end
    
    lastCommand[source] = currentTime  
    return true
end

-- BlackListed Word
local function containsBlacklistedWord(message)
    for _, word in ipairs(Config.Blacklisted) do
        if string.find(string.lower(message), string.lower(word)) then
            return true
        end
    end
    return false
end
-- CHAT
AddEventHandler('chatMessage', function(source, name, message)
    if string.sub(message, 1, string.len('/')) ~= '/' then
        CancelEvent()
        if containsBlacklistedWord(message) then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Blacklisted Word',
                description = 'Your message contains a blacklisted word and was not sent.',
                type = 'error',
                duration = 5000
            })
            return
        end

        if not handleCooldown(source, 'local chat') then
            return
        end

        TriggerClientEvent('rpchat:sendLocalOOC', -1, source, name, message, {30, 144, 255})
    end
end)

-- ME
RegisterCommand('me', function(source, args, raw)
    if source == 0 then
        return
    end

    if not Config.MeCommand then
        return
    end

    local message = table.concat(args, ' ')
    if containsBlacklistedWord(message) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Blacklisted Word',
            description = 'Your message contains a blacklisted word and was not sent.',
            type = 'error',
            duration = 5000
        })
        return
    end

    if not handleCooldown(source, '/me') then
        return
    end

    local name = GetCharacterName(source)
    TriggerClientEvent('rpchat:sendMe', -1, source, name, message, {196, 33, 246})
end)

-- DO
RegisterCommand('do', function(source, args, raw)
    if source == 0 then
        return
    end

    if not Config.DoCommand then
        return
    end

    local message = table.concat(args, ' ')
    if containsBlacklistedWord(message) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Blacklisted Word',
            description = 'Your message contains a blacklisted word and was not sent.',
            type = 'error',
            duration = 5000 
        })
        return
    end

    if not handleCooldown(source, '/do') then
        return
    end

    local name = GetCharacterName(source)
    TriggerClientEvent('rpchat:sendDo', -1, source, name, message, {255, 198, 0})
end)

-- Sheriff
RegisterCommand('lssd', function(source, args, rawCommand)
    if not Config.SheriffCommand then
        print('rpchat: The /lssd command is disabled in the config.')
        return
    end

    if not handleCooldown(source, '/lssd') then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local toSay = table.concat(args, ' ')
    if containsBlacklistedWord(toSay) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Blacklisted Word',
            description = 'Your message contains a blacklisted word and was not sent.',
            type = 'error',
            duration = 5000 
        })
        return
    end

    if xPlayer.getJob().name == Config.sheriff then
        TriggerClientEvent('chat:addMessage', -1, {
            template = '<div style="font-weight:bold;font-size:1.35vh;color: #54E0FF; margin: 0.05vw;">👮 LSSD Announcement: <b style=color:#ffffff;font-weight:normal>{0}</b></div>',
            args = { toSay }
        })
    else 
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="color: #FF3E32; margin: 0.05vw;"><i class="fas fa-exclamation"></i>  You need to be a sheriff officer to use this command. <i class="fas fa-exclamation"></i></div>',
            args = {}
        })
    end
end, false)

-- Announcement
RegisterCommand('announcement', function(source, args, raw)
    if not Config.AnnouncementsCommand then
        return
    end
    if source == 0 then
        return
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()

    if not Config.AllowedGroups[playerGroup] then
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="color: #FF3E32; margin: 0.05vw;"><i class="fas fa-exclamation"></i>  You do not have permission to use this command. <i class="fas fa-exclamation"></i></div>',
            args = {}
        })
        return
    end

    if #args < 1 then
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="color: #FF3E32; margin: 0.05vw;"><i class="fas fa-exclamation"></i>  You must provide a message for the announcement. <i class="fas fa-exclamation"></i></div>',
            args = {}
        })
        return
    end

    local message = table.concat(args, ' ')
    if containsBlacklistedWord(message) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Blacklisted Word',
            description = 'Your message contains a blacklisted word and was not sent.',
            type = 'error',
            duration = 5000 
        })
        return
    end

    local playerName = GetPlayerName(source)
    local webhookURL = Config.DiscordWebhookURLs["announcement"]

    local discordId
    local identifiers = GetPlayerIdentifiers(source)

    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, "discord:") then
            discordId = string.sub(identifier, 9)
            break
        end
    end

    if not discordId then
        discordId = "Not connected"
    end

    local embedConfig = {
        color = {
            ["announcement"] = 16711680
        },
        translation = {
            player = "Player",
            discordNickname = "Discord Nickname",
            time = "Time",
            message = "Message"
        }
    }

    local embed = {
        {
            ["color"] = embedConfig.color["announcement"],
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S"),
            ["fields"] = {
                {
                    ["name"] = embedConfig.translation.player,
                    ["value"] = playerName
                },
                {
                    ["name"] = embedConfig.translation.discordNickname,
                    ["value"] = (discordId ~= "Not connected") and ("<@" .. discordId .. ">") or "Not connected"
                },
                {
                    ["name"] = embedConfig.translation.time,
                    ["value"] = os.date("%H:%M:%S")
                },
                {
                    ["name"] = embedConfig.translation.message,
                    ["value"] = message
                }
            }
        }
    }

    if webhookURL then
        PerformHttpRequest(webhookURL, function(err, text, headers)
            if err ~= 200 and err ~= 204 then
            end
        end, 'POST', json.encode({
            username = "Announcement Bot",
            avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png?ex=6816caa1&is=68157921&hm=9157e009449d8dd42d1c8f0203ef5f0921038ca2430708cc237821d0e921875e",
            embeds = embed
        }), { ['Content-Type'] = 'application/json' })
    end

    TriggerClientEvent('rpchat:sendAnnouncement', -1, source, "Announcement", message, {255, 0, 0})
end)
-- MSG
RegisterCommand('msg', function(source, args, raw)
    if not Config.MsgCommand then
        print('rpchat: The /msg command is disabled in the config.')
        return
    end
    if source == 0 then
        print('rpchat: you can\'t use this command from rcon!')
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()

    if not Config.AllowedGroups[playerGroup] then
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="color: #FF3E32; margin: 0.05vw;"><i class="fas fa-exclamation"></i>  You do not have permission to use this command. <i class="fas fa-exclamation"></i></div>',
            args = {}
        })
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="color: #FF3E32; margin: 0.05vw;"><i class="fas fa-exclamation"></i>  Invalid player ID. <i class="fas fa-exclamation"></i></div>',
            args = {}
        })
        return
    end

    table.remove(args, 1)
    local message = table.concat(args, ' ')
    if containsBlacklistedWord(message) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Blacklisted Word',
            description = 'Your message contains a blacklisted word and was not sent.',
            type = 'error',
            duration = 5000
        })
        return
    end

    local senderName = GetPlayerName(source)
    local targetName = GetPlayerName(targetId)
    local webhookURL = Config.DiscordWebhookURLs["msg"]

    if webhookURL then
        PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
            embeds = {
                {
                    title = "Private Message",
                    description = string.format("**Sender:** %s (ID: %d)\n**Recipient:** %s (ID: %d)\n**Message:** %s", senderName, source, targetName, targetId, message),
                    color = 3447003
                }
            }
        }), { ['Content-Type'] = 'application/json' })
    end

    TriggerClientEvent('rpchat:sendPrivateMessage', targetId, source, message)
end)
-- CHAT
RegisterServerEvent('rpchat:chat')
AddEventHandler('rpchat:chat', function(job, msg)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local firstname = Player.getJob().grade.name .. " " .. Player.get('firstname')
    local lastname = Player.get('lastname')
    local jobName = string.upper(job)
    local messageFull = {
        template = '<div style="font-weight:bold;font-size: 1.35vh;color: #54E0FF; margin: 0.05vw;"><i class="fas fa-headset"></i> [Interna SAPD] {1} {2} : <b style=color:#ffffff;font-weight:normal>{3}</font></i></b></div>',
        args = { jobName, firstname, lastname, msg }
    }
    TriggerClientEvent('rpchat:Send', -1, messageFull, job)
end)