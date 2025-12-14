local ESX = nil
local MySQL = exports.oxmysql
local lastCommand = {} 

local Config = {}

local Locales = {}
local currentLocale = "en" 

local function loadLocale()
    local localeFile = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. currentLocale .. '.lua')
    if localeFile then
        local env = {}
        env.Locales = {}
        local chunk, err = load(localeFile, 'locale', 't', env)
        if not chunk then
            print("Failed to load locale chunk: " .. tostring(err))
            return
        end
        local ok, result = pcall(chunk)
        if not ok then
            print("Failed to execute locale chunk: " .. tostring(result))
            return
        end
        if result then
            Locales = result
        else
            print("Locale table not found in locale file")
        end
    else
        print("Locale file not found: " .. currentLocale)
    end
end

local function loadConfig()
    local configFile = LoadResourceFile(GetCurrentResourceName(), 'config.lua')
    if configFile then
        local env = {Config = {}}
        local chunk, err = load(configFile, 'config', 't', env)
        if chunk then
            local ok, result = pcall(chunk)
            if ok and env.Config then
                for k, v in pairs(env.Config) do
                    Config[k] = v
                end
                currentLocale = Config.Locale or currentLocale
                print("[RPCHAT] Config loaded. CharacterName: " .. tostring(Config.CharacterName))
            else
                print("Failed to execute config chunk: " .. tostring(result))
            end
        else
            print("Failed to load config chunk: " .. tostring(err))
        end
    else
        print("Config file not found")
    end
end

loadConfig()

loadLocale()

function _U(key)
    if Locales[key] then
        return Locales[key]
    else
        return key
    end
end

ESX = exports["es_extended"]:getSharedObject()

-- Cooldown Commands
local function handleCooldown(source, commandName)
    local currentTime = os.time()  
    if lastCommand[source] and (currentTime - lastCommand[source] < Config.CommandCooldown) then
        local remainingTime = Config.CommandCooldown - (currentTime - lastCommand[source])
        
        local data = {
            title = _U('cooldown_title'),
            description = string.format(_U('cooldown_description'), remainingTime, commandName),
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
        local pattern = "%f[%a]" .. word .. "%f[%A]"
        if string.find(string.lower(message), pattern) then
            return true
        end
    end
    return false
end

-- GetPlayerNameWithVIP
function GetPlayerNameWithVIP(source)
    if Config.CharacterName then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local identifier = xPlayer.identifier
            local result = exports.oxmysql:executeSync('SELECT firstname, lastname FROM users WHERE identifier = ?', {identifier})
            if result and result[1] then
                result = result[1]
            end
            if result and result.firstname and result.lastname and result.firstname ~= "" and result.lastname ~= "" then
                local firstInitial = string.sub(result.firstname, 1, 1):upper()
                local lastInitial = string.sub(result.lastname, 1, 1):upper()
                return firstInitial .. "." .. lastInitial
            end
        end
    end
    return GetPlayerName(source) or ("ID: " .. tostring(source))
end

AddEventHandler('chatMessage', function(source, name, message)
    if string.sub(message, 1, 1) == '/' then
        local command = string.match(message, "^/(%w+)")
        if command then
            local validCommands = {"me", "do", "lssd", "lspd", "ems", "announcement", "msg", "try", "doc", "staff", "oocstaff"}
            local isValid = false
            for _, cmd in ipairs(validCommands) do
                if cmd == command then
                    isValid = true
                    break
                end
            end
            if not isValid then
                local timeSpan = '<span style="float: right; color: rgba(255, 255, 255, 0.6); font-size: 12px; font-family: Poppins, sans-serif;">[' .. os.date('%H:%M') .. ']</span>'
                TriggerClientEvent('chat:addMessage', source, {
                    template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(255, 0, 0); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">' .. _U('invalid_command') .. '</span>' .. timeSpan .. '</div>',
                    args = {}
                })
            end
        end
        CancelEvent()
    else
        CancelEvent()
        if containsBlacklistedWord(message) then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('blacklisted_word_title'),
                description = _U('blacklisted_word_description'),
                type = 'error',
                duration = 5000
            })
            return
        end
        if not handleCooldown(source, 'local chat') then
            return
        end
        local playerName = GetPlayerNameWithVIP(source)
        local isVIP = IsPlayerVIP(source)
        TriggerClientEvent('rpchat:sendLocalOOC', -1, source, playerName, message, {30, 144, 255}, isVIP)

        local webhookURL = Config.DiscordWebhookURLs["local_chat"]
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
                ["local_chat"] = 16776960, 
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
                ["color"] = embedConfig.color["local_chat"],
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S"),
                ["fields"] = {
                    {
                        ["name"] = embedConfig.translation.player,
                        ["value"] = name
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
                username = "Pitrs RP CHAT",
                avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png",
                embeds = embed
            }), { ['Content-Type'] = 'application/json' })
        end
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
            title = _U('blacklisted_word_title'),
            description = _U('blacklisted_word_description'),
            type = 'error',
            duration = 5000
        })
        return
    end
    if not handleCooldown(source, '/me') then
        return
    end
    local playerName = GetPlayerNameWithVIP(source)
    local isVIP = IsPlayerVIP(source)
    TriggerClientEvent('rpchat:sendMe', -1, source, playerName, message, {168, 96, 202}, isVIP)

    local webhookURL = Config.DiscordWebhookURLs["me"]
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
            ["me"] = 10181046
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
            ["color"] = embedConfig.color["me"],
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
            username = "PITRS RPCHAT BOT",
            avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png?ex=6816caa1&is=68157921&hm=9157e009449d8dd42d1c8f0203ef5f0921038ca2430708cc237821d0e921875e",
            embeds = embed
        }), { ['Content-Type'] = 'application/json' })
    end
end, false)

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
            title = _U('blacklisted_word_title'),
            description = _U('blacklisted_word_description'),
            type = 'error',
            duration = 5000
        })
        return
    end

    if not handleCooldown(source, '/do') then
        return
    end
    local playerName = GetPlayerNameWithVIP(source)
    local isVIP = IsPlayerVIP(source)
    TriggerClientEvent('rpchat:sendDo', -1, source, playerName, message, {0, 169, 211}, isVIP)

    local webhookURL = Config.DiscordWebhookURLs["do"]

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
            ["do"] = 3447003
 
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
            ["color"] = embedConfig.color["do"],
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
            username = "PITRS RPCHAT BOT",
            avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png?ex=6816caa1&is=68157921&hm=9157e009449d8dd42d1c8f0203ef5f0921038ca2430708cc237821d0e921875e",
            embeds = embed
        }), { ['Content-Type'] = 'application/json' })
    end
end, false)

-- Sheriff
RegisterCommand('lssd', function(source, args, rawCommand)
    if not Config.SheriffCommand then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('command_disabled_title'),
            description = string.format(_U('command_disabled_description'), "/lssd"),
            type = 'error',
            duration = 5000
        })
        return
    end

    if not handleCooldown(source, '/lssd') then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local toSay = table.concat(args, ' ')
    
    if containsBlacklistedWord(toSay) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('blacklisted_word_title'),
            description = _U('blacklisted_word_description'),
            type = 'error',
            duration = 5000 
        })
        return
    end

if xPlayer.getJob().name == Config.sheriff then
    TriggerClientEvent('rpchat:sendSheriff', -1, source, GetPlayerNameWithVIP(source), toSay, {0, 169, 211})
    local playerName = GetPlayerNameWithVIP(source)
        local discordId = "Not connected"
        local identifiers = GetPlayerIdentifiers(source)
        for _, identifier in ipairs(identifiers) do
            if string.match(identifier, "discord:") then
                discordId = string.sub(identifier, 9)
                break
            end
        end

        local embed = {{
            ["color"] = 16753920,  -- Changed to orange color
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S"),
            ["fields"] = {
                { ["name"] = "Player", ["value"] = playerName },
                { ["name"] = "Discord Nickname", ["value"] = (discordId ~= "Not connected") and ("<@" .. discordId .. ">") or "Not connected" },
                { ["name"] = "Time", ["value"] = os.date("%H:%M:%S") },
                { ["name"] = "LSSD Message", ["value"] = toSay }
            }
        }}

        local webhookURL = Config.DiscordWebhookURLs["lssd"]
        if webhookURL then
            PerformHttpRequest(webhookURL, function(err, text, headers)
                if err ~= 200 and err ~= 204 then
                end
            end, 'POST', json.encode({
                username = "PITRS RPCHAT BOT",
                avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png?ex=6816caa1&is=68157921&hm=9157e009449d8dd42d1c8f0203ef5f0921038ca2430708cc237821d0e921875e",
                embeds = embed
            }), { ['Content-Type'] = 'application/json' })
        end
    else 
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('permission_denied_title'),
            description = _U('permission_denied_description_sheriff'),
            type = 'error',
            duration = 5000
        })
    end
end, false)


-- Police
RegisterCommand('lspd', function(source, args, rawCommand)
    if not Config.PoliceCommand then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('command_disabled_title'),
            description = string.format(_U('command_disabled_description'), "/lspd"),
            type = 'error',
            duration = 5000
        })
        return
    end

    if not handleCooldown(source, '/lspd') then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local toSay = table.concat(args, ' ')

    if containsBlacklistedWord(toSay) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('blacklisted_word_title'),
            description = _U('blacklisted_word_description'),
            type = 'error',
            duration = 5000
        })
        return
    end

    if xPlayer.getJob().name == Config.police then
        local playerName = GetPlayerNameWithVIP(source)
        TriggerClientEvent('rpchat:sendPolice', -1, source, "LSPD", toSay, {0, 100, 150})

        local discordId = "Not connected"
        local identifiers = GetPlayerIdentifiers(source)
        for _, identifier in ipairs(identifiers) do
            if string.match(identifier, "discord:") then
                discordId = string.sub(identifier, 9)
                break
            end
        end

        local embed = {
            ["color"] = 3447003,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S"),
            ["fields"] = {
                { ["name"] = "Player", ["value"] = playerName },
                { ["name"] = "Discord Nickname", ["value"] = (discordId ~= "Not connected") and ("<@" .. discordId .. ">") or "Not connected" },
                { ["name"] = "Time", ["value"] = os.date("%H:%M:%S") },
                { ["name"] = "LSPD Message", ["value"] = toSay }
            }
        }

        local webhookURL = Config.DiscordWebhookURLs["police"]
        if webhookURL then
            PerformHttpRequest(webhookURL, function(err, text, headers)
                if err ~= 200 and err ~= 204 then
                end
            end, 'POST', json.encode({
                username = "PITRS RPCHAT BOT",
                avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png?ex=6816caa1&is=68157921&hm=9157e009449d8dd42d1c8f0203ef5f0921038ca2430708cc237821d0e921875e",
                embeds = {embed}
            }), { ['Content-Type'] = 'application/json' })
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('permission_denied_title'),
            description = _U('permission_denied_description_police'),
            type = 'error',
            duration = 5000
        })
    end
end, false)


-- Ambulance
RegisterCommand('ems', function(source, args, rawCommand)
    if not Config.AmbulanceCommand then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('command_disabled_title'),
            description = string.format(_U('command_disabled_description'), "/ems"),
            type = 'error',
            duration = 5000
        })
        return
    end

    if not handleCooldown(source, '/ems') then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local toSay = table.concat(args, ' ')

    if containsBlacklistedWord(toSay) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('blacklisted_word_title'),
            description = _U('blacklisted_word_description'),
            type = 'error',
            duration = 5000
        })
        return
    end

if xPlayer.getJob().name == Config.ambulance then
    TriggerClientEvent('rpchat:sendAmbulance', -1, source, GetPlayerNameWithVIP(source), toSay, {255, 255, 255})
    local playerName = GetPlayerNameWithVIP(source)
        local discordId = "Not connected"
        local identifiers = GetPlayerIdentifiers(source)
        for _, identifier in ipairs(identifiers) do
            if string.match(identifier, "discord:") then
                discordId = string.sub(identifier, 9)
                break
            end
        end

        local embed = {{
            ["color"] = 16777215,  -- White color
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S"),
            ["fields"] = {
                { ["name"] = "Player", ["value"] = playerName },
                { ["name"] = "Discord Nickname", ["value"] = (discordId ~= "Not connected") and ("<@" .. discordId .. ">") or "Not connected" },
                { ["name"] = "Time", ["value"] = os.date("%H:%M:%S") },
                { ["name"] = "Ambulance Message", ["value"] = toSay }
            }
        }}

        local webhookURL = Config.DiscordWebhookURLs["ambulance"]
        if webhookURL then
            PerformHttpRequest(webhookURL, function(err, text, headers)
                if err ~= 200 and err ~= 204 then
                end
            end, 'POST', json.encode({
                username = "PITRS RPCHAT BOT",
                avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png?ex=6816caa1&is=68157921&hm=9157e009449d8dd42d1c8f0203ef5f0921038ca2430708cc237821d0e921875e",
                embeds = embed
            }), { ['Content-Type'] = 'application/json' })
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('permission_denied_title'),
            description = _U('permission_denied_description_ambulance'),
            type = 'error',
            duration = 5000
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
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('permission_denied_title'),
            description = _U('permission_denied_description_announcement'),
            type = 'error',
            duration = 5000
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
            title = _U('blacklisted_word_title'),
            description = _U('blacklisted_word_description'),
            type = 'error',
            duration = 5000 
        })
        return
    end

local playerName = GetPlayerNameWithVIP(source)
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
            username = "PITRS RPCHAT BOT",
            avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png?ex=6816caa1&is=68157921&hm=9157e009449d8dd42d1c8f0203ef5f0921038ca2430708cc237821d0e921875e",
            embeds = embed
        }), { ['Content-Type'] = 'application/json' })
    end

    TriggerClientEvent('rpchat:sendAnnouncement', -1, source, "Announcement", message, {255, 0, 0})
end, false)

-- MSG
RegisterCommand('msg', function(source, args, raw)
    if not Config.MsgCommand then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('command_disabled_title'),
            description = string.format(_U('command_disabled_description'), "/msg"),
            type = 'error',
            duration = 5000
        })
        return
    end
    if source == 0 then
        print('rpchat: you can\'t use this command from rcon!')
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()

    if not Config.AllowedGroups[playerGroup] then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('permission_denied_title'),
            description = _U('permission_denied_description_generic'),
            type = 'error',
            duration = 5000
        })
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('invalid_player_id_title'),
            description = _U('invalid_player_id_description'),
            type = 'error',
            duration = 5000
        })
        return
    end

    table.remove(args, 1)
    local message = table.concat(args, ' ')
    if containsBlacklistedWord(message) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('blacklisted_word_title'),
            description = _U('blacklisted_word_description'),
            type = 'error',
            duration = 5000
        })
        return
    end

local senderName = GetPlayerNameWithVIP(source)
local targetName = GetPlayerNameWithVIP(targetId)
    local webhookURL = Config.DiscordWebhookURLs["msg"]

    if webhookURL then
        PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
            username = "PITRS RP CHAT",  
            avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png",  
            embeds = {
                {
                    title = "Admin Private Message",
                    description = string.format("**Sender:** %s (ID: %d)\n**Recipient:** %s (ID: %d)\n**Message:** %s", senderName, source, targetName, targetId, message),
                    color = 2067276  
                }
            }
        }), { ['Content-Type'] = 'application/json' })
    end

    TriggerClientEvent('rpchat:sendPrivateMessage', targetId, source, message)
end, false)

-- TRY
RegisterCommand('try', function(source, args, rawCommand)
    if not Config.TryCommand then return end  -- Pokud je příkaz vypnutý v configu, nepokračuje

    local result = math.random(1, 2)
    local playerName = GetPlayerNameWithVIP(source)
    local isVIP = IsPlayerVIP(source)
    local response = (result == 1) and "Ano" or "Ne"
    local color = (result == 1) and "rgba(0, 255, 0, 0.4)" or "rgba(255, 0, 0, 0.4)"
    local discordColor = (result == 1) and 65280 or 16711680

    TriggerClientEvent('rpchat:showTryMessage', source, playerName, response, color, isVIP)

    local discordId
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, "discord:") then
            discordId = string.sub(identifier, 9)
            break
        end
    end
    if not discordId then discordId = "Not connected" end

    local embed = {{
        ["color"] = discordColor,
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S"),
        ["fields"] = {
            { ["name"] = "Player", ["value"] = playerName },
            { ["name"] = "Discord Nickname", ["value"] = (discordId ~= "Not connected") and ("<@" .. discordId .. ">") or "Not connected" },
            { ["name"] = "Time", ["value"] = os.date("%H:%M:%S") },
            { ["name"] = "Try Result", ["value"] = response }
        }
    }}
    local webhookURL = Config.DiscordWebhookURLs["try"]
    if webhookURL then
        PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
            username = "PITRS RPCHAT BOT",
            avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png",
            embeds = embed
        }), { ['Content-Type'] = 'application/json' })
    end
end, false)

-- DOC
RegisterCommand('doc', function(source, args, rawCommand)
    if not Config.DocCommand then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('doc_command_disabled_title'),
            description = _U('doc_command_disabled_description'),
            type = 'error',
            duration = 5000
        })
        return
    end
    if source == 0 then
        print('rpchat: you can\'t use this command from rcon!')
        return
    end

    local count = 1
    local target = 20

    if args[1] then
        local num = tonumber(args[1])
        if num then
            target = num
        end
        if target > 50 then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('doc_max_allowed_title'),
                description = _U('doc_max_allowed_description'),
                type = 'error'
            })
            return
        end
    end

    local senderName = GetPlayerName(source)
    local webhookURL = Config.DiscordWebhookURLs["doc"]

    if webhookURL then
        PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
            username = "PITRS RPCHAT BOT",
            avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png",
            embeds = {
                {
                    title = "Doc Bot",
                    description = string.format("**Sender:** %s (ID: %d)\n**Target Count:** %d", senderName, source, target),
                    color = 0x000000 
                }
            }
        }), { ['Content-Type'] = 'application/json' })
    end
    TriggerClientEvent('rpchat:sendDocMessage', source, count, target)
end, false)

-- STAFF
RegisterCommand("staff", function(source, args, rawCommand)
    if not Config.StaffCommand then
        return
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    if not Config.AllowedGroups[playerGroup] then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('permission_denied_title'),
            description = _U('permission_denied_description_generic'),
            type = 'error',
            duration = 5000
        })
        return
    end

    local message = table.concat(args, " ")
local senderName = GetPlayerNameWithVIP(source)
for _, playerId in ipairs(GetPlayers()) do
        local target = ESX.GetPlayerFromId(tonumber(playerId))
        if target and Config.AllowedGroups[target.getGroup()] then
            TriggerClientEvent("rpchat:receiveStaffMessage", target.source, senderName, message)
        end
    end
    local discordId = "Not connected"
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if string.match(identifier, "discord:") then
            discordId = "<@" .. string.sub(identifier, 9) .. ">"
            break
        end
    end
    local embed = {
        {
            ["color"] = 16760576, 
            ["title"] = "Staff Chat Message",
            ["fields"] = {
                { name = "Player", value = senderName, inline = true },
                { name = "Discord", value = discordId, inline = true },
                { name = "Group", value = playerGroup, inline = true },
                { name = "Message", value = message, inline = false }
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    local webhookURL = Config.DiscordWebhookURLs["staff"]
    if webhookURL then
        PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
            username = "PITRS RPCHAT BOT",
            avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png",
            embeds = embed
        }), { ['Content-Type'] = 'application/json' })
    end
end, false)

-- AUTO MESSAGE CHAT
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

-- OOC STAFF
RegisterCommand('oocstaff', function(source, args, rawCommand)
    if not Config.OocStaffCommand then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('command_disabled_title'),
            description = _U('command_disabled_description_oocstaff'),
            type = 'error',
            duration = 5000
        })
        return
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer and xPlayer.getGroup and xPlayer:getGroup() or nil
    if not playerGroup or not Config.AllowedGroups[playerGroup] then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('permission_denied_title'),
            description = _U('permission_denied_description_oocstaff'),
            type = 'error',
            duration = 5000
        })
        return
    end
    local message = table.concat(args, ' ')
    if message == '' then return end
    local playerName = GetPlayerNameWithVIP(source)
    TriggerClientEvent('rpchat:sendLocalOOCStaff', -1, source, playerName, message)
    local webhookURL = Config.DiscordWebhookURLs["local_chat"]
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
            ["local_chat"] = 16776960,
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
            ["color"] = embedConfig.color["local_chat"],
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
            username = "Pitrs RP CHAT",
            avatar_url = "https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png",
            embeds = embed
        }), { ['Content-Type'] = 'application/json' })
    end
end, false)

