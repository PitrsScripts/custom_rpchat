local ESX = nil
local MySQL = exports.oxmysql
local lastCommand = {}

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

-- ============================================================
-- Startup Check & Logging
-- ============================================================
local function PrintStartup()
    local esxLoaded = false
    local oxmysqlLoaded = false
    local oxLibLoaded = false
    local asyncLoaded = false
    
    -- Check ESX
    pcall(function()
        ESX = exports["es_extended"]:getSharedObject()
        if ESX then esxLoaded = true end
    end)
    
    -- Check oxmysql
    pcall(function()
        if exports.oxmysql then oxmysqlLoaded = true end
    end)
    
    -- Check ox_lib
    pcall(function()
        if exports.ox_lib then oxLibLoaded = true end
    end)
    
    -- Check async
    pcall(function()
        if GetResourceState('async') == 'started' then asyncLoaded = true end
    end)
    
    -- Check Discord Webhooks
    local webhooksConfigured = false
    local webhookCount = 0
    if Config.DiscordWebhookURLs then
        for key, url in pairs(Config.DiscordWebhookURLs) do
            if url and url ~= '' and url ~= 'WEBHOOK' and string.find(url, 'discord.com/api/webhooks') then
                webhookCount = webhookCount + 1
            end
        end
        if webhookCount > 0 then
            webhooksConfigured = true
        end
    end
    
    print("^4============================================================^0")
    print("^4 RP Chat System - Pitrs^0")
    print("^4============================================================^0")
    
    if esxLoaded then
        print("^2 [✓] ESX Framework loaded successfully!^0")
    else
        print("^1 [✗] ESX Framework failed to load!^0")
    end
    
    if oxmysqlLoaded then
        print("^2 [✓] oxmysql Database loaded successfully!^0")
    else
        print("^1 [✗] oxmysql Database failed to load!^0")
    end
    
    if oxLibLoaded then
        print("^2 [✓] ox_lib loaded successfully!^0")
    else
        print("^3 [!] ox_lib not detected (optional)^0")
    end
    
    if asyncLoaded then
        print("^2 [✓] async loaded successfully!^0")
    else
        print("^3 [!] async not detected (optional)^0")
    end
    
    print("^4------------------------------------------------------------^0")
    
    if webhooksConfigured then
        print("^2 [✓] Discord Webhooks configured (" .. webhookCount .. " webhooks)^0")
    else
        print("^3 [!] Discord Webhooks not configured^0")
    end
    
    print("^4------------------------------------------------------------^0")
    print("^2 Script successfully started!^0")
    print("^5 Support Discord: https://discord.gg/vhJkJbGpMy^0")
    print("^4============================================================^0")
end

PrintStartup()

ESX.RegisterServerCallback('rpchat:getConfig', function(source, cb)
    cb({
        Debug = Config.Debug,
        VIPSystem = Config.VIPSystem,
        VIPLicenses = Config.VIPLicenses,
        CommandsDistance = Config.CommandsDistance,
        DrawTextDistance = Config.DrawTextDistance,
        ShowTimeInChat = Config.ShowTimeInChat,
        ChatBackgroundColor = Config.ChatBackgroundColor,
        MeDrawText = Config.MeDrawText,
        DoDrawText = Config.DoDrawText,
        MeDrawTextColor = Config.MeDrawTextColor,
        DoDrawTextColor = Config.DoDrawTextColor,
        MeDrawTextBgColor = Config.MeDrawTextBgColor,
        DoDrawTextBgColor = Config.DoDrawTextBgColor,
        StavDrawTextColor = Config.StavDrawTextColor,
        ZdeDrawTextColor = Config.ZdeDrawTextColor,
        DocDrawTextColor = Config.DocDrawTextColor,
        ZdeCommand = Config.ZdeCommand,
        StavCommand = Config.StavCommand,
        ZdeMaxMessages = Config.ZdeMaxMessages,
        ZdeDistance = Config.ZdeDistance,
        StavDistance = Config.StavDistance,
        CommandZde = Config.CommandZde,
        MeColor = Config.MeColor,
        DoColor = Config.DoColor,
        SheriffColor = Config.SheriffColor,
        PoliceColor = Config.PoliceColor,
        AmbulanceColor = Config.AmbulanceColor,
        AdColor = Config.AdColor,
        AnnouncementColor = Config.AnnouncementColor,
        TwtColor = Config.TwtColor,
        DocColor = Config.DocColor,
        StaffColor = Config.StaffColor,
        OocStaffColor = Config.OocStaffColor,
        TrySuccessColor = Config.TrySuccessColor,
        TryFailColor = Config.TryFailColor,
        MeDrawTextOffset = Config.MeDrawTextOffset,
        MeDrawTextOffsetVehicle = Config.MeDrawTextOffsetVehicle,
        DoDrawTextOffset = Config.DoDrawTextOffset,
        DoDrawTextOffsetVehicle = Config.DoDrawTextOffsetVehicle,
        DocDrawTextOffset = Config.DocDrawTextOffset
    })
end)

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
        
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, data)
        end
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
            local validCommands = {"me", "do", "lssd", "lspd", "ems", "announcement", "msg", "try", "doc", "staff", "oocstaff", "ad", "twt"}
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
                    template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(255, 0, 0); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">Chyba</span>  Neplatný Příkaz' .. timeSpan .. '</div>',
                    args = {},
                    isCommand = true
                })
            end
        end
        CancelEvent()
    else
        CancelEvent()
        if containsBlacklistedWord(message) then
            if Config.Notifications then
                TriggerClientEvent('ox_lib:notify', source, {
                    title = _U('blacklisted_word_title'),
                    description = _U('blacklisted_word_description'),
                    type = 'error',
                    duration = 5000
                })
            end
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
                player = _U('chat_label_player'),
                discordNickname = _U('chat_label_discord'),
                time = _U('chat_label_time'),
                message = _U('chat_label_message')
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
RegisterCommand(Config.CommandMe or 'me', function(source, args, raw)
    if source == 0 then
        return
    end
    if not Config.MeCommand then
        return
    end
    local message = table.concat(args, ' ')

    if containsBlacklistedWord(message) then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('blacklisted_word_title'),
                description = _U('blacklisted_word_description'),
                type = 'error',
                duration = 5000
            })
        end
        return
    end
    if not handleCooldown(source, '/me') then
        return
    end
    local playerName = GetPlayerNameWithVIP(source)
    local isVIP = IsPlayerVIP(source)
    local coords = GetEntityCoords(GetPlayerPed(source))
    local players = {}
    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(ped)
        local dist = math.sqrt((coords.x - playerCoords.x)^2 + (coords.y - playerCoords.y)^2 + (coords.z - playerCoords.z)^2)
        if dist <= Config.DrawTextDistance then
            table.insert(players, playerId)
        end
    end
    for i = 1, #players do
        TriggerClientEvent('pitrs_rpchat:sendMeMessage', players[i], source, playerName, message, Config.MeDrawTextColor)
    end

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
            player = _U('chat_label_player'),
            discordNickname = _U('chat_label_discord'),
            time = _U('chat_label_time'),
            message = _U('chat_label_message')
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
RegisterCommand(Config.CommandDo or 'do', function(source, args, raw)
    if source == 0 then
        return
    end

    if not Config.DoCommand then
        return
    end

    local message = table.concat(args, ' ')
    if containsBlacklistedWord(message) then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('blacklisted_word_title'),
                description = _U('blacklisted_word_description'),
                type = 'error',
                duration = 5000
            })
        end
        return
    end

    if not handleCooldown(source, '/do') then
        return
    end
    local playerName = GetPlayerNameWithVIP(source)
    local isVIP = IsPlayerVIP(source)
    local coords = GetEntityCoords(GetPlayerPed(source))
    local players = {}
    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(ped)
        local dist = math.sqrt((coords.x - playerCoords.x)^2 + (coords.y - playerCoords.y)^2 + (coords.z - playerCoords.z)^2)
        if dist <= Config.DrawTextDistance then
            table.insert(players, playerId)
        end
    end
    for i = 1, #players do
        TriggerClientEvent('pitrs_rpchat:sendDoMessage', players[i], source, playerName, message, Config.DoDrawTextColor)
    end

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
            player = _U('chat_label_player'),
            discordNickname = _U('chat_label_discord'),
            time = _U('chat_label_time'),
            message = _U('chat_label_message')
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
RegisterCommand(Config.CommandLssd or 'lssd', function(source, args, rawCommand)
    if not Config.SheriffCommand then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('command_disabled_title'),
                description = string.format(_U('command_disabled_description'), "/lssd"),
                type = 'error',
                duration = 5000
            })
        end
        return
    end

    if not handleCooldown(source, '/lssd') then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local toSay = table.concat(args, ' ')
    
    if containsBlacklistedWord(toSay) then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('blacklisted_word_title'),
                description = _U('blacklisted_word_description'),
                type = 'error',
                duration = 5000 
            })
        end
        return
    end

if xPlayer.getJob().name == Config.JobSheriff then
    TriggerClientEvent('rpchat:sendSheriff', -1, source, GetPlayerNameWithVIP(source), toSay, Config.SheriffColor)
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
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('permission_denied_title'),
                description = _U('permission_denied_description_sheriff'),
                type = 'error',
                duration = 5000
            })
        end
    end
end, false)


-- Police
RegisterCommand(Config.CommandLspd or 'lspd', function(source, args, rawCommand)
    if not Config.PoliceCommand then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('command_disabled_title'),
                description = string.format(_U('command_disabled_description'), "/lspd"),
                type = 'error',
                duration = 5000
            })
        end
        return
    end

    if not handleCooldown(source, '/lspd') then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local toSay = table.concat(args, ' ')

    if containsBlacklistedWord(toSay) then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('blacklisted_word_title'),
                description = _U('blacklisted_word_description'),
                type = 'error',
                duration = 5000
            })
        end
        return
    end

    if xPlayer.getJob().name == Config.JobPolice then
        local playerName = GetPlayerNameWithVIP(source)
        TriggerClientEvent('rpchat:sendPolice', -1, source, "LSPD", toSay, Config.PoliceColor)

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
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('permission_denied_title'),
                description = _U('permission_denied_description_police'),
                type = 'error',
                duration = 5000
            })
        end
    end
end, false)


-- Ambulance
RegisterCommand(Config.CommandEms or 'ems', function(source, args, rawCommand)
    if not Config.AmbulanceCommand then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('command_disabled_title'),
                description = string.format(_U('command_disabled_description'), "/ems"),
                type = 'error',
                duration = 5000
            })
        end
        return
    end

    if not handleCooldown(source, '/ems') then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local toSay = table.concat(args, ' ')

    if containsBlacklistedWord(toSay) then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('blacklisted_word_title'),
                description = _U('blacklisted_word_description'),
                type = 'error',
                duration = 5000
            })
        end
        return
    end

if xPlayer.getJob().name == Config.JobAmbulance then
    TriggerClientEvent('rpchat:sendAmbulance', -1, source, GetPlayerNameWithVIP(source), toSay, Config.AmbulanceColor)
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
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('permission_denied_title'),
                description = _U('permission_denied_description_ambulance'),
                type = 'error',
                duration = 5000
            })
        end
    end
end, false)
-- Announcement
RegisterCommand(Config.CommandAnnouncement or 'announcement', function(source, args, raw)
    if not Config.AnnouncementsCommand then
        return
    end
    if source == 0 then
        return
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()

    if not Config.AllowedGroups[playerGroup] then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('permission_denied_title'),
                description = _U('permission_denied_description_announcement'),
                type = 'error',
                duration = 5000
            })
        end
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
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('blacklisted_word_title'),
                description = _U('blacklisted_word_description'),
                type = 'error',
                duration = 5000 
            })
        end
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
            player = _U('chat_label_player'),
            discordNickname = _U('chat_label_discord'),
            time = _U('chat_label_time'),
            message = _U('chat_label_message')
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

    TriggerClientEvent('rpchat:sendAnnouncement', -1, source, "Announcement", message, Config.AnnouncementColor)
end, false)

-- MSG
RegisterCommand(Config.CommandMsg or 'msg', function(source, args, raw)
    if not Config.MsgCommand then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('command_disabled_title'),
                description = string.format(_U('command_disabled_description'), "/msg"),
                type = 'error',
                duration = 5000
            })
        end
        return
    end
    if source == 0 then
        print('rpchat: you can\'t use this command from rcon!')
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()

    if not Config.AllowedGroups[playerGroup] then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('permission_denied_title'),
                description = _U('permission_denied_description_generic'),
                type = 'error',
                duration = 5000
            })
        end
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('invalid_player_id_title'),
                description = _U('invalid_player_id_description'),
                type = 'error',
                duration = 5000
            })
        end
        return
    end

    table.remove(args, 1)
    local message = table.concat(args, ' ')
    if containsBlacklistedWord(message) then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('blacklisted_word_title'),
                description = _U('blacklisted_word_description'),
                type = 'error',
                duration = 5000
            })
        end
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
RegisterCommand(Config.CommandTry or 'try', function(source, args, rawCommand)
    if not Config.TryCommand then return end  -- Pokud je příkaz vypnutý v configu, nepokračuje

    local result = math.random(1, 2)
    local playerName = GetPlayerNameWithVIP(source)
    local isVIP = IsPlayerVIP(source)
    local response = (result == 1) and "Ano" or "Ne"
    local color = (result == 1) and string.format('rgb(%d, %d, %d)', Config.TrySuccessColor[1], Config.TrySuccessColor[2], Config.TrySuccessColor[3]) or string.format('rgb(%d, %d, %d)', Config.TryFailColor[1], Config.TryFailColor[2], Config.TryFailColor[3])
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
RegisterCommand(Config.CommandDoc or 'doc', function(source, args, rawCommand)
    if not Config.DocCommand then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                title = _U('doc_command_disabled_title'),
                description = _U('doc_command_disabled_description'),
                type = 'error',
                duration = 5000
            })
        end
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
        if target > Config.DocMaxCount then
            if Config.Notifications then
                TriggerClientEvent('ox_lib:notify', source, {
                    title = _U('doc_max_allowed_title'),
                    description = _U('doc_max_allowed_description'),
                    type = 'error'
                })
            end
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
    local coords = GetEntityCoords(GetPlayerPed(source))
    local players = {}
    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(ped)
        local dist = math.sqrt((coords.x - playerCoords.x)^2 + (coords.y - playerCoords.y)^2 + (coords.z - playerCoords.z)^2)
        if dist <= Config.DrawTextDistance then
            table.insert(players, playerId)
        end
    end
    for i = 1, #players do
        TriggerClientEvent('pitrs_rpchat:sendDocMessage', players[i], source, count, target, Config.DocDrawTextColor)
    end
end, false)

-- STAFF
RegisterCommand(Config.CommandStaff or 'staff', function(source, args, rawCommand)
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
local senderName = GetPlayerName(source)
local isVIP = IsPlayerVIP(source)
for _, playerId in ipairs(GetPlayers()) do
        local target = ESX.GetPlayerFromId(tonumber(playerId))
        if target and Config.AllowedGroups[target.getGroup()] then
            TriggerClientEvent("rpchat:receiveStaffMessage", target.source, senderName, message, isVIP, Config.StaffColor)
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
RegisterCommand(Config.CommandOocstaff or 'oocstaff', function(source, args, rawCommand)
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
    TriggerClientEvent('rpchat:sendLocalOOCStaff', -1, source, playerName, message, Config.OocStaffColor)
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
            player = _U('chat_label_player'),
            discordNickname = _U('chat_label_discord'),
            time = _U('chat_label_time'),
            message = _U('chat_label_message')
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

-- AD
RegisterCommand(Config.CommandAd or 'ad', function(source, args, raw)
    if source == 0 then
        return
    end
    if not Config.AdCommand then
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
    if not handleCooldown(source, '/ad') then
        return
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    if #Config.AdJobs > 0 then
        local hasJob = false
        for _, job in ipairs(Config.AdJobs) do
            if xPlayer.job.name == job then
                hasJob = true
                break
            end
        end
        if not hasJob then
            return
        end
    end
    if Config.AdPrice > 0 then
        if xPlayer.getMoney() < Config.AdPrice then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Nedostatek peněz',
                description = 'Nemáte dostatek peněz na reklamu. Cena: $' .. Config.AdPrice,
                type = 'error',
                duration = 5000
            })
            return
        end
        xPlayer.removeMoney(Config.AdPrice)
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Reklama odeslána',
            description = 'Vaše reklama byla odeslána za $' .. Config.AdPrice,
            type = 'success',
            duration = 5000
        })
    end
    local playerName = GetPlayerNameWithVIP(source)
    TriggerClientEvent('rpchat:sendAd', -1, source, playerName, message, Config.AdColor)

    local webhookURL = Config.DiscordWebhookURLs["ad"]
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
        translation = {
            title = _U('ad_title'),
            player = _U('chat_label_player'),
            discordNickname = _U('chat_label_discord'),
            time = _U('chat_label_time'),
            message = _U('chat_label_message')
        }
    }
    local embed = {
        {
            ["color"] = 16776960,
            ["title"] = embedConfig.translation.title,
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
    if webhookURL and webhookURL ~= 'HOOK' then
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

-- TWT
RegisterCommand(Config.CommandTwt or 'twt', function(source, args, raw)
    if not Config.TwtCommand then
        return
    end
    local message = table.concat(args, ' ')
    if containsBlacklistedWord(message) then
        TriggerClientEvent('esx:showNotification', source, _U('blacklisted_word'))
        return
    end
    if not handleCooldown(source, '/twt') then
        return
    end
    local playerName = GetPlayerNameWithVIP(source)
    local webhookURL = Config.DiscordWebhookURLs["twt"] -- Using same webhook as ad
    local discordId
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.sub(identifier, 1, 8) == 'discord:' then
            discordId = string.sub(identifier, 9)
            break
        end
    end
    if not discordId then
        discordId = 'Not connected'
    end
    local embedConfig = {
        translation = {
            title = _U('twt_title'),
            player = _U('chat_label_player'),
            discordNickname = _U('chat_label_discord'),
            time = _U('chat_label_time'),
            message = _U('chat_label_message')
        }
    }
    local embed = {
        {
            ["color"] = 3447003,
            ["title"] = embedConfig.translation.title,
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
            username = 'Pitrs RP CHAT',
            avatar_url = 'https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png',
            embeds = embed
        }), { ['Content-Type'] = 'application/json' })
    end
    TriggerClientEvent('rpchat:sendTwt', -1, source, playerName, message, Config.TwtColor)
end, false)

------------------------------------------------------------------------------------------------
--------------ZDE (HERE)------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
local displayedMessages = {}

RegisterNetEvent('rpchat:SyncMessage')
AddEventHandler('rpchat:SyncMessage', function(message, coords)
    if not Config.ZdeCommand then
        return
    end
    displayedMessages[coords] = message
    TriggerClientEvent('rpchat:SetMessage', -1, message, coords)

    local playerName = GetPlayerName(source)
    local webhookURL = Config.DiscordWebhookURLs["zde"]
    local discordId
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.sub(identifier, 1, 8) == 'discord:' then
            discordId = string.sub(identifier, 9)
            break
        end
    end
    if not discordId then
        discordId = 'Not connected'
    end
    local embedConfig = {
        translation = {
            title = 'ZDE',
            player = _U('chat_label_player'),
            discordNickname = _U('chat_label_discord'),
            time = _U('chat_label_time'),
            message = _U('chat_label_message')
        }
    }
    local embed = {
        {
            ["color"] = 16776960,
            ["title"] = embedConfig.translation.title,
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
                    ["value"] = message.message
                }
            }
        }
    }
    if webhookURL then
        PerformHttpRequest(webhookURL, function(err, text, headers)
            if err ~= 200 and err ~= 204 then
            end
        end, 'POST', json.encode({
            username = 'Pitrs RP CHAT',
            avatar_url = 'https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png',
            embeds = embed
        }), { ['Content-Type'] = 'application/json' })
    end
end)

RegisterNetEvent('rpchat:removeDisplayedMessage')
AddEventHandler('rpchat:removeDisplayedMessage', function(coords)
    displayedMessages[coords] = nil
    TriggerClientEvent('rpchat:removeMessage', -1, coords)
end)

------------------------------------------------------------------------------------------------
--------------STAV (STATUS)---------------------------------------------------------------------
------------------------------------------------------------------------------------------------
local playerStatus = {}

RegisterCommand(Config.CommandStav or 'stav', function(source, args, rawCommand)
    if not Config.StavCommand then
        if Config.Notifications then
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'error',
                title = _U('command_disabled_title'),
                description = _U('stav_disabled')
            })
        end
        return
    end
    
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer then
        if playerStatus[_source] then
            playerStatus[_source] = nil
            TriggerClientEvent('rpchat:RemovePlayerStatus', -1, _source)
            if Config.Notifications then
                TriggerClientEvent('ox_lib:notify', _source, {
                    type = 'inform',
                    description = _U('stav_removed')
                })
            end
        else
            local message = rawCommand:sub(6)
            if message == '' then
                return
            end
            
            if containsBlacklistedWord(message) then
                if Config.Notifications then
                    TriggerClientEvent('ox_lib:notify', _source, {
                        type = 'error',
                        title = _U('blacklisted_word_title'),
                        description = _U('blacklisted_word_description')
                    })
                end
                return
            end
            
            playerStatus[_source] = message
            TriggerClientEvent('rpchat:SetPlayerStatus', -1, _source, message)

            local playerName = GetPlayerName(_source)
            local webhookURL = Config.DiscordWebhookURLs["stav"]
            local discordId
            local identifiers = GetPlayerIdentifiers(_source)
            for _, identifier in ipairs(identifiers) do
                if string.sub(identifier, 1, 8) == 'discord:' then
                    discordId = string.sub(identifier, 9)
                    break
                end
            end
            if not discordId then
                discordId = 'Not connected'
            end
            local embedConfig = {
                translation = {
                    title = 'STAV',
                    player = _U('chat_label_player'),
                    discordNickname = _U('chat_label_discord'),
                    time = _U('chat_label_time'),
                    message = _U('chat_label_message')
                }
            }
            local embed = {
                {
                    ["color"] = 16776960,
                    ["title"] = embedConfig.translation.title,
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
                    username = 'Pitrs RP CHAT',
                    avatar_url = 'https://cdn.discordapp.com/attachments/1367682516244369508/1367682545948557312/150464632.png',
                    embeds = embed
                }), { ['Content-Type'] = 'application/json' })
            end
        end
    end
end, false)

RegisterNetEvent('rpchat:RequestMessages')
AddEventHandler('rpchat:RequestMessages', function()
    TriggerClientEvent('rpchat:SetMessages', source, displayedMessages, playerStatus)
end)

-- Cleanup on player disconnect for zde/stav
AddEventHandler('playerDropped', function(reason)
    for k, v in pairs(displayedMessages) do
        if v.owner == source then
            displayedMessages[k] = nil
            TriggerClientEvent('rpchat:removeMessage', -1, k)
        end
    end
    if playerStatus[source] then
        playerStatus[source] = nil
        TriggerClientEvent('rpchat:RemovePlayerStatus', -1, source)
    end
end)
