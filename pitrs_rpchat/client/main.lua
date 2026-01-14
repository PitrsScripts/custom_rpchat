local ESX = nil
local textOffset = 0
local playerLicense = nil
local Config = {}
local function getChatBackground()
    return 'rgba(' .. (Config.ChatBackgroundColor and Config.ChatBackgroundColor[1] or 10) .. ', ' .. (Config.ChatBackgroundColor and Config.ChatBackgroundColor[2] or 10) .. ', ' .. (Config.ChatBackgroundColor and Config.ChatBackgroundColor[3] or 10) .. ', ' .. (Config.ChatBackgroundColor and Config.ChatBackgroundColor[4] or 0.5) .. ')'
end
local Locales = {}
local currentLocale = "cs"

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

function _U(key)
    if Locales[key] then
        return Locales[key]
    else
        return key
    end
end
------------------------------------------------------------------------------------------------
--------------ESX-------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
function debugPrint(msg)
    if Config.Debug then
        print(msg)
    end
end
Citizen.CreateThread(function()
    while ESX == nil do 
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end
    debugPrint("DEBUG: RpChat Loaded")
    loadLocale()
    
    ESX.TriggerServerCallback('rpchat:getConfig', function(config)
        Config.Debug = config.Debug
        Config.VIPSystem = config.VIPSystem
        Config.VIPLicenses = config.VIPLicenses
        Config.CommandsDistance = config.CommandsDistance
        Config.DrawTextDistance = config.DrawTextDistance
        Config.ShowTimeInChat = config.ShowTimeInChat
        Config.ChatBackgroundColor = config.ChatBackgroundColor
        Config.MeDrawText = config.MeDrawText
        Config.DoDrawText = config.DoDrawText
        Config.MeDrawTextColor = config.MeDrawTextColor
        Config.DoDrawTextColor = config.DoDrawTextColor
        Config.MeDrawTextBgColor = config.MeDrawTextBgColor
        Config.DoDrawTextBgColor = config.DoDrawTextBgColor
        Config.DocDrawTextBgColor = config.DocDrawTextBgColor
        Config.StavDrawTextColor = config.StavDrawTextColor
        Config.ZdeDrawTextColor = config.ZdeDrawTextColor
        Config.DocDrawTextColor = config.DocDrawTextColor
        Config.ZdeCommand = config.ZdeCommand
        Config.StavCommand = config.StavCommand
        Config.ZdeMaxMessages = config.ZdeMaxMessages
        Config.ZdeDistance = config.ZdeDistance
        Config.StavDistance = config.StavDistance
        Config.CommandZde = config.CommandZde
        Config.MeColor = config.MeColor
        Config.DoColor = config.DoColor
        Config.SheriffColor = config.SheriffColor
        Config.PoliceColor = config.PoliceColor
        Config.AmbulanceColor = config.AmbulanceColor
        Config.AdColor = config.AdColor
        Config.AnnouncementColor = config.AnnouncementColor
        Config.TwtColor = config.TwtColor
        Config.DocColor = config.DocColor
        Config.StaffColor = config.StaffColor
        Config.OocStaffColor = config.OocStaffColor
        Config.TrySuccessColor = config.TrySuccessColor
        Config.TryFailColor = config.TryFailColor
        Config.MeDrawTextOffset = config.MeDrawTextOffset
        Config.MeDrawTextOffsetVehicle = config.MeDrawTextOffsetVehicle
        Config.DoDrawTextOffset = config.DoDrawTextOffset
        Config.DoDrawTextOffsetVehicle = config.DoDrawTextOffsetVehicle
        Config.DocDrawTextOffset = config.DocDrawTextOffset
    end)
    
    -- Počáteční získání reálného času
    TriggerServerEvent('rpchat:requestRealTime')
end)
AddEventHandler('onClientResourceStart', function (resourceName)
    if(GetCurrentResourceName() ~= resourceName) then
      return
    end
end)  
------------------------------------------------------------------------------------------------
--------------OFFSET----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        textOffset = 0
    end
end)

------------------------------------------------------------------------------------------------
--------------VIPSystem-------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    TriggerServerEvent('rpchat:requestPlayerLicense')
end)

RegisterNetEvent('rpchat:receivePlayerLicense', function(license)
    playerLicense = license
end)

function IsPlayerVIP()
    if not Config.VIPSystem then return false end
    if not playerLicense then return false end
    for _, vip in ipairs(Config.VIPLicenses) do
        if vip == playerLicense then
            return true
        end
    end
    return false
end

function GetDisplayName(playerId)
    return GetPlayerName(playerId)
end
------------------------------------------------------------------------------------------------
--------------TIME------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
local cachedRealTime = '[00:00]'
local lastTimeUpdate = 0

local isWaitingForTime = false
local pendingTimeCallback = nil

RegisterNetEvent('rpchat:receiveRealTime')
AddEventHandler('rpchat:receiveRealTime', function(timeString)
    cachedRealTime = timeString
    lastTimeUpdate = GetGameTimer()
    isWaitingForTime = false
    if pendingTimeCallback then
        pendingTimeCallback(timeString)
        pendingTimeCallback = nil
    end
end)

function GetCurrentTime()
    if not Config.ShowTimeInChat then return '' end
    TriggerServerEvent('rpchat:requestRealTime')
    return cachedRealTime
end

function GetTimeSpan()
    if not Config.ShowTimeInChat then return '' end
    if not isWaitingForTime then
        isWaitingForTime = true
        TriggerServerEvent('rpchat:requestRealTime')
        local startTime = GetGameTimer()
        while isWaitingForTime and (GetGameTimer() - startTime) < 100 do
            Citizen.Wait(0)
        end
    end
    
    return '<span style="float: right; color: rgba(255, 255, 255, 0.6); font-size: 12px; font-family: Poppins, sans-serif;">' .. cachedRealTime .. '</span>'
end
------------------------------------------------------------------------------------------------
--------------ME--------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendMe', function(playerId, playerName, message, color, isVIP)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        if targetPed == source or #(sourceCoords - targetCoords) < Config.CommandsDistance then  
            local isInVehicle = IsPedInAnyVehicle(targetPed, false)
            local offset = isInVehicle and Config.MeDrawTextOffsetVehicle or Config.MeDrawTextOffset

            Citizen.CreateThread(function()
                local startTime = GetGameTimer()
                local displayDuration = 5000
                while true do
                    Citizen.Wait(0)
                    local targetPedCoords = GetEntityCoords(targetPed)
                    local x, y, z = targetPedCoords.x, targetPedCoords.y, targetPedCoords.z
                    if Config.MeDrawText then
                        DrawText3DMe(x, y, z, message, Config.MeDrawTextColor)
                    end
                    if GetGameTimer() - startTime > displayDuration then
                        break
                    end
                end
            end)

            local meLabel = '<span style="font-weight: 600; font-family: Poppins, sans-serif !important;">ME</span>'
            if isVIP then
                meLabel = '<span style="font-weight: 600; font-family: Poppins, sans-serif !important;">ME</span><span style="color: gold; font-size: 16px; margin-left: 3px; font-family: Poppins, sans-serif !important;">⭐</span>'
            end
            local timeSpan = GetTimeSpan()
            TriggerEvent('chat:addMessage', { 
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><style>* { font-family: Poppins, sans-serif !important; }</style><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif !important; position: relative;"> <span style="background-color: rgb(' .. Config.MeColor[1] .. ', ' .. Config.MeColor[2] .. ', ' .. Config.MeColor[3] .. '); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif !important;">' .. meLabel .. '</span> ' .. playerName .. ' - <span style="color: white; font-family: Poppins, sans-serif !important; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "[ME] - " .. playerName, message },
                isCommand = true
            })
        end
    end
end)

RegisterNetEvent('pitrs_rpchat:sendMeMessage', function(playerId, playerName, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        if targetPed == source or #(sourceCoords - targetCoords) < Config.DrawTextDistance then  
            local isInVehicle = IsPedInAnyVehicle(targetPed, false)
            local baseOffset = isInVehicle and 0.7 or 1.2
            local textOffset = 0.5
            local offset = baseOffset + textOffset

            Citizen.CreateThread(function()
                local startTime = GetGameTimer()
                local displayDuration = 5000
                while true do
                    Citizen.Wait(0)
                    local targetPedCoords = GetEntityCoords(targetPed)
                    local x, y, z = targetPedCoords.x, targetPedCoords.y, targetPedCoords.z
                    if Config.MeDrawText then
                        local offset = isInVehicle and Config.MeDrawTextOffsetVehicle or Config.MeDrawTextOffset
                        DrawText3DMe(x, y, z + offset, message, color)
                    end
                    if GetGameTimer() - startTime > displayDuration then
                        break
                    end
                end
            end)

            local isVIP = IsPlayerVIP(playerId)
            local meLabel = '<span style="font-weight: 600; font-family: Poppins, sans-serif !important;">ME</span>'
            if isVIP then
                meLabel = '<span style="font-weight: 600; font-family: Poppins, sans-serif !important;">ME</span><span style="color: gold; font-size: 16px; margin-left: 3px; font-family: Poppins, sans-serif !important;">⭐</span>'
            end
            local timeSpan = GetTimeSpan()
            TriggerEvent('chat:addMessage', { 
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><style>* { font-family: Poppins, sans-serif !important; }</style><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif !important; position: relative;"> <span style="background-color: rgb(' .. Config.MeColor[1] .. ', ' .. Config.MeColor[2] .. ', ' .. Config.MeColor[3] .. '); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif !important;">' .. meLabel .. '</span> ' .. playerName .. ' - <span style="color: white; font-family: Poppins, sans-serif !important; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "[ME] - " .. playerName, message },
                isCommand = true
            })
        end
    end
end)
------------------------------------------------------------------------------------------------
--------------POLICE----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendPolice', function(playerId, title, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        if targetPed == source or #(sourceCoords - targetCoords) < Config.CommandsDistance then  
            local playerName = GetPlayerName(target)
            local timeSpan = GetTimeSpan()
            TriggerEvent('chat:addMessage', { 
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(' .. Config.PoliceColor[1] .. ', ' .. Config.PoliceColor[2] .. ', ' .. Config.PoliceColor[3] .. '); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">LSPD</span> <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "[LSPD]", message },
                isCommand = true
            })
        end
    end
end)
------------------------------------------------------------------------------------------------
--------------SHERIFF---------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendSheriff', function(playerId, title, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        if targetPed == source or #(sourceCoords - targetCoords) < Config.CommandsDistance then  
            local playerName = GetPlayerName(target)
            local timeSpan = GetTimeSpan()
            TriggerEvent('chat:addMessage', { 
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(' .. Config.SheriffColor[1] .. ', ' .. Config.SheriffColor[2] .. ', ' .. Config.SheriffColor[3] .. '); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">LSSD</span> <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "[LSSD]", message },
                isCommand = true
            })
        end
    end
end)
------------------------------------------------------------------------------------------------
----------------DO------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendDo', function(playerId, playerName, message, color, isVIP)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        if targetPed == source or #(sourceCoords - targetCoords) < Config.CommandsDistance then
            local isInVehicle = IsPedInAnyVehicle(sourcePed, false)
            local offset = isInVehicle and Config.DoDrawTextOffsetVehicle or Config.DoDrawTextOffset
            Citizen.CreateThread(function()
                local startTime = GetGameTimer()
                local displayDuration = 5000
                while true do
                    Citizen.Wait(0)
                    local targetPedCoords = GetEntityCoords(targetPed)
                    local x, y, z = targetPedCoords.x, targetPedCoords.y, targetPedCoords.z
                    if Config.DoDrawText then
                        DrawText3DDo(x, y, z, message, Config.DoDrawTextColor)
                    end
                    if GetGameTimer() - startTime > displayDuration then
                        break
                    end
                end
            end)
            local doLabel = 'DO'
            if isVIP then
                doLabel = 'DO<span style="color: gold; font-size: 16px; margin-left: 3px;">⭐</span>'
            end
            local timeSpan = GetTimeSpan()
            TriggerEvent('chat:addMessage', {
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(' .. Config.DoColor[1] .. ', ' .. Config.DoColor[2] .. ', ' .. Config.DoColor[3] .. '); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">' .. doLabel .. '</span> ' .. playerName .. ' - <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "[DO] - " .. playerName, message },
                isCommand = true
            })
        end
    end
end)

RegisterNetEvent('pitrs_rpchat:sendDoMessage', function(playerId, playerName, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        if targetPed == source or #(sourceCoords - targetCoords) < Config.DrawTextDistance then
            local isInVehicle = IsPedInAnyVehicle(sourcePed, false)
            local baseOffset = isInVehicle and 0.7 or 1.2
            local textOffset = 0.0 
            local offset = baseOffset + textOffset
            Citizen.CreateThread(function()
                local startTime = GetGameTimer()
                local displayDuration = 5000
                while true do
                    Citizen.Wait(0)
                    local targetPedCoords = GetEntityCoords(targetPed)
                    local x, y, z = targetPedCoords.x, targetPedCoords.y, targetPedCoords.z
                    if Config.DoDrawText then
                        local offset = isInVehicle and Config.DoDrawTextOffsetVehicle or Config.DoDrawTextOffset
                        DrawText3DDo(x, y, z + offset, message, color)
                    end
                    if GetGameTimer() - startTime > displayDuration then
                        break
                    end
                end
            end)
            local isVIP = IsPlayerVIP(playerId)
            local doLabel = 'DO'
            if isVIP then
                doLabel = 'DO<span style="color: gold; font-size: 16px; margin-left: 3px;">⭐</span>'
            end
            local timeSpan = GetTimeSpan()
            TriggerEvent('chat:addMessage', {
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(' .. Config.DoColor[1] .. ', ' .. Config.DoColor[2] .. ', ' .. Config.DoColor[3] .. '); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">' .. doLabel .. '</span> ' .. playerName .. ' - <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "[DO] - " .. playerName, message },
                isCommand = true
            })
        end
    end
end)
------------------------------------------------------------------------------------------------
--------------AD--------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendAd', function(playerId, playerName, message, color)
    local timeSpan = GetTimeSpan()
    local escapedMessage = message:gsub("'", "&#39;"):gsub('"', "&quot;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    TriggerEvent('chat:addMessage', {
        template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(' .. Config.AdColor[1] .. ', ' .. Config.AdColor[2] .. ', ' .. Config.AdColor[3] .. '); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">REKLAMA</span> <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">' .. escapedMessage .. '</span>' .. timeSpan .. '</div>',
        args = {},
        isCommand = true
    })
end)
------------------------------------------------------------------------------------------------
--------------AMBULANCE-------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendAmbulance', function(playerId, title, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        if targetPed == source or #(sourceCoords - targetCoords) < Config.CommandsDistance then  
            local playerName = GetPlayerName(target)
            local timeSpan = GetTimeSpan()
            TriggerEvent('chat:addMessage', { 
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(' .. Config.AmbulanceColor[1] .. ', ' .. Config.AmbulanceColor[2] .. ', ' .. Config.AmbulanceColor[3] .. '); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">EMS</span> <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "[EMS]", message },
                isCommand = true
            })
        end
    end
end)
------------------------------------------------------------------------------------------------
---------------OOC------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendLocalOOC', function(playerId, title, message, color, isVIP)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        if targetPed == source or #(sourceCoords - targetCoords) < Config.CommandsDistance then
            local playerName = GetDisplayName(target)
            local oocLabel = 'L-OOC'
            if isVIP then
                oocLabel = 'L-OOC<span style="color: gold; font-size: 16px; margin-left: 3px;">⭐</span>'
            end
            local timeSpan = GetTimeSpan()
            TriggerEvent('chat:addMessage', {
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: #737373; border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">' .. oocLabel .. '</span> ' .. playerName .. ' - <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "L-OOC - " .. playerName, message },
                isCommand = true
            })
        end
    end
end)

RegisterNetEvent('rpchat:sendLocalOOCStaff', function(playerId, playerName, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        if targetPed == source or #(sourceCoords - targetCoords) < Config.CommandsDistance then
            local timeSpan = GetTimeSpan()
            TriggerEvent('chat:addMessage', {
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;">'
                    .. '<span style="background-color: red; border-radius: 10px; padding: 2px 4px; color: white; margin-right: 5px; font-weight: 600; font-family: Poppins, sans-serif;">ADMIN</span>'
                    .. '<span style="background-color: rgb(' .. color[1] .. ', ' .. color[2] .. ', ' .. color[3] .. '); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">L-OOC</span> '
                    .. playerName .. ' - <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "L-OOC - " .. playerName, message },
                isCommand = true
            })
        end
    end
end)
------------------------------------------------------------------------------------------------
---------------TRY------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:showTryMessage', function(playerName, response, bgColor, isVIP)
    local tryLabel = 'TRY'
    if isVIP then
        tryLabel = 'TRY<span style="color: gold; font-size: 16px; margin-left: 3px;">⭐</span>'
    end
    local timeSpan = GetTimeSpan()
    TriggerEvent('chat:addMessage', {
        template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;">' ..
            ' <span style="background-color: ' .. bgColor .. '; border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">' .. tryLabel .. '</span> ' .. playerName .. ' <span style="color: white; font-family: Poppins, sans-serif;">- ' .. response .. '</span>' .. timeSpan .. '</div>',
        args = {},
        isCommand = true
    })
end)
------------------------------------------------------------------------------------------------
---------------DOC------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('pitrs_rpchat:sendDocMessage', function(playerId, count, target, color)
    Citizen.CreateThread(function()
        local startTime = GetGameTimer()
        local updateInterval = 1000
        local lastUpdate = 0
        local targetPlayer = GetPlayerFromServerId(playerId)
        local targetPed = GetPlayerPed(targetPlayer)
        while count <= target do
            Citizen.Wait(0)
            local targetCoords = GetEntityCoords(targetPed)
            local x, y, z = targetCoords.x, targetCoords.y, targetCoords.z + Config.DocDrawTextOffset 
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            if #(playerCoords - targetCoords) < Config.DrawTextDistance then
                local currentTime = GetGameTimer()
                if currentTime - lastUpdate >= updateInterval then
                    lastUpdate = currentTime
                    count = count + 1
                end
                DrawText3DDoc(x, y, z, "" .. count .. " / " .. target, color) 
            end
            if count > target then
                break
            end
        end        
    end)
end)
------------------------------------------------------------------------------------------------
--------------ADMIN-----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent("rpchat:receiveStaffMessage", function(senderName, message, isVIP, color)
    local staffLabel = 'STAFF'
    if isVIP then
        staffLabel = 'STAFF<span style="color: gold; font-size: 16px; margin-left: 3px;">⭐</span>'
    end
    local timeSpan = GetTimeSpan()
    TriggerEvent('chat:addMessage', {
        template = [[
            <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
            <div style="
                margin-bottom: 5px;
                padding: 10px;
                background-color: ]] .. getChatBackground() .. [[;
                border-radius: 10px;
                color: white;
                font-family: Poppins, sans-serif;
                position: relative;
            ">
                <span style="
                    background-color: rgb(]] .. color[1] .. [[, ]] .. color[2] .. [[, ]] .. color[3] .. [[);
                    border-radius: 10px;
                    padding: 2px 6px;
                    color: white;
                    font-weight: 600;
                    font-family: Poppins, sans-serif;
                ">]] .. staffLabel .. [[</span> {0} - <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>]] .. timeSpan .. [[
            </div>
        ]],
        args = { senderName, message },
        isCommand = true
    })
end)
RegisterNetEvent('rpchat:sendAnnouncement', function(playerId, title, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    
    if target ~= -1 then
        local timeSpan = GetTimeSpan()
        TriggerEvent('chat:addMessage', {
            template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;">' ..
                        '<span style="background-color: rgb(' .. Config.AnnouncementColor[1] .. ', ' .. Config.AnnouncementColor[2] .. ', ' .. Config.AnnouncementColor[3] .. '); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">Announcement</span> ' ..
                        '<span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
            args = { message },
            isCommand = true
        })
    end
end)
RegisterNetEvent('rpchat:sendPrivateMessage', function(senderId, message)
    local senderName = GetPlayerName(GetPlayerFromServerId(senderId))
    local timeSpan = GetTimeSpan()
    TriggerEvent('chat:addMessage', {
        template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;">' ..
                    '<span style="background-color: rgba(0, 255, 0, 0.8); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">MSG</span> ' ..
                    '<span style="color: white; font-family: Poppins, sans-serif;">' .. senderName .. '- <span style="word-wrap: break-word; white-space: pre-wrap;">{1}</span></span>' .. timeSpan .. '</div>',
        args = { senderName, message },
        isCommand = true
    })
end)
------------------------------------------------------------------------------------------------
--------------AUTO MESSAGE----------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendAutoMessage', function(message)
    local timeSpan = GetTimeSpan()
    TriggerEvent('chat:addMessage', {
        template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;">' ..
                    '<span style="background-color: rgba(0, 151, 255, 0.4); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">CHAT</span> ' .. 
                    '<span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
        args = { "[Chat]", message }
    })
end)
------------------------------------------------------------------------------------------------
--------------DRAW TEXT-------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
local function GetResolutionScale()
    local _, screenY = GetActiveScreenResolution()
    return screenY / 1080.0
end

function DrawText3DMe(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z) 
    if onScreen then
        local scale = GetResolutionScale()
        local textScale = 0.35 * scale
        
        SetTextScale(textScale, textScale)
        SetTextFont(16)
        SetTextProportional(true)
        SetTextCentre(true)

        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local textWidth = EndTextCommandGetWidth(true)

        local bgWidth = textWidth + (0.010 * scale)
        local bgHeight = 0.027 * scale
        local rectOffset = 0.012 * scale
        
        SetTextEntry("STRING")
        AddTextComponentString(text)
        SetTextColour(color[1], color[2], color[3], color[4])
        DrawText(_x, _y)
        DrawRect(_x, _y + rectOffset, bgWidth, bgHeight, Config.MeDrawTextBgColor[1], Config.MeDrawTextBgColor[2], Config.MeDrawTextBgColor[3], Config.MeDrawTextBgColor[4])
    end
end

function DrawText3DDo(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        local scale = GetResolutionScale()
        local textScale = 0.35 * scale
        
        SetTextScale(textScale, textScale)
        SetTextFont(16)
        SetTextProportional(true)
        SetTextCentre(true)

        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local textWidth = EndTextCommandGetWidth(true)
        
        local bgWidth = textWidth + (0.010 * scale)
        local bgHeight = 0.027 * scale
        local rectOffset = 0.012 * scale
        
        SetTextEntry("STRING")
        AddTextComponentString(text)
        SetTextColour(color[1], color[2], color[3], color[4])
        DrawText(_x, _y)
        DrawRect(_x, _y + rectOffset, bgWidth, bgHeight, Config.DoDrawTextBgColor[1], Config.DoDrawTextBgColor[2], Config.DoDrawTextBgColor[3], Config.DoDrawTextBgColor[4])
    end
end

function DrawText3DDoc(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        local scale = GetResolutionScale()
        local textScale = 0.35 * scale
        local textLength = string.len(text)
        local bgWidth = (0.02 + (textLength / 250)) * scale
        local bgHeight = 0.027 * scale
        local offsetX = 0.005 * scale
        local rectOffset = 0.012 * scale
        
        SetTextScale(textScale, textScale)
        SetTextFont(16)
        SetTextProportional(true)
        SetTextColour(color[1], color[2], color[3], color[4])
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x + offsetX, _y)
        DrawRect(_x + offsetX, _y + rectOffset, bgWidth, bgHeight, Config.DocDrawTextBgColor[1], Config.DocDrawTextBgColor[2], Config.DocDrawTextBgColor[3], Config.DocDrawTextBgColor[4])
    end
end

------------------------------------------------------------------------------------------------
--------------TWT--------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendTwt', function(playerId, playerName, message, color)
    local timeSpan = GetTimeSpan()
    local twtLabel = _U('twt_title')
    TriggerEvent('chat:addMessage', {
        template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: ' .. getChatBackground() .. '; border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(' .. Config.TwtColor[1] .. ', ' .. Config.TwtColor[2] .. ', ' .. Config.TwtColor[3] .. '); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">' .. twtLabel .. '</span> <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{0}</span>' .. timeSpan .. '</div>',
        args = { message },
        isCommand = true
    })
end)

------------------------------------------------------------------------------------------------
--------------ZDE (HERE)------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
local displayedMessages = {}
local playerStatuses = {}
local playerLoaded = false
local zdeCommandRegistered = false

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
    end
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    playerLoaded = true
    TriggerServerEvent('rpchat:RequestMessages')
    
    -- Register /zde command after config is loaded
    if not zdeCommandRegistered then
        zdeCommandRegistered = true
        RegisterCommand(Config.CommandZde or 'zde', function(source, args, rawCommand)
            if not Config.ZdeCommand then
                exports.ox_lib:notify({type = 'error', description = _U('zde_disabled')})
                return
            end
            
            if playerLoaded then
                local ped = PlayerPedId()
                local pedCoords = GetEntityCoords(ped)
                local roundedCoords = vector3(ESX.Math.Round(pedCoords.x), ESX.Math.Round(pedCoords.y), ESX.Math.Round(pedCoords.z))

                if not displayedMessages[roundedCoords] then
                    local playerMessages = 0
                    local maxMessages = Config.ZdeMaxMessages or 5
                    for k, v in pairs(displayedMessages) do
                        if v.owner == GetPlayerServerId(PlayerId()) then
                            playerMessages = playerMessages + 1
                        end
                    end

                    if playerMessages >= maxMessages then
                        exports.ox_lib:notify({type = 'inform', description = _U('zde_limit')})
                    else
                        local msg = ''
                        for i = 1, #args do
                            msg = msg .. ' ' .. args[i]
                        end
                        if msg ~= '' then
                            local currentMessage = {
                                owner = GetPlayerServerId(PlayerId()),
                                coords = pedCoords,
                                message = msg
                            }
                            TriggerServerEvent('rpchat:SyncMessage', currentMessage, roundedCoords)
                        end
                    end
                elseif displayedMessages[roundedCoords].owner == GetPlayerServerId(PlayerId()) then
                    TriggerServerEvent('rpchat:removeDisplayedMessage', roundedCoords)
                    exports.ox_lib:notify({type = 'inform', description = _U('zde_removed')})
                else
                    exports.ox_lib:notify({type = 'inform', description = _U('zde_exists')})
                end
            else
                exports.ox_lib:notify({type = 'inform', description = _U('zde_not_spawned')})
            end
        end, false)
    end
end)

RegisterNetEvent('rpchat:SetMessage')
AddEventHandler('rpchat:SetMessage', function(message, coords)
    displayedMessages[coords] = message
end)

RegisterNetEvent('rpchat:removeMessage')
AddEventHandler('rpchat:removeMessage', function(coords)
    displayedMessages[coords] = nil
end)

RegisterNetEvent('rpchat:SetMessages')
AddEventHandler('rpchat:SetMessages', function(heres, statuses)
    playerStatuses = statuses
    displayedMessages = heres
end)

RegisterNetEvent('rpchat:SetPlayerStatus')
AddEventHandler('rpchat:SetPlayerStatus', function(playerId, message)
    playerStatuses[playerId] = message
end)

RegisterNetEvent('rpchat:RemovePlayerStatus')
AddEventHandler('rpchat:RemovePlayerStatus', function(playerId)
    playerStatuses[playerId] = nil
end)

-- Draw /stav status at player middle (waist level)
Citizen.CreateThread(function()
    local myServerId = GetPlayerServerId(PlayerId())
    while true do
        Wait(0)
        local letSleep = true
        local pedCoords = GetEntityCoords(PlayerPedId())
        local stavDistance = Config.StavDistance or 8.0
        
        -- Draw own status
        if playerStatuses[myServerId] then
            DrawText3DStav(pedCoords.x, pedCoords.y, pedCoords.z + 0.2, playerStatuses[myServerId])
            letSleep = false
        end
        
        -- Draw other players' status
        for k, v in pairs(playerStatuses) do
            if k ~= myServerId then
                local player = GetPlayerFromServerId(k)
                if player ~= -1 then
                    local targetCoords = GetEntityCoords(GetPlayerPed(player))
                    local dist = #(targetCoords - pedCoords)
                    if dist < stavDistance then
                        DrawText3DStav(targetCoords.x, targetCoords.y, targetCoords.z + 0.2, v)
                        letSleep = false
                    end
                end
            end
        end
        
        if letSleep then
            Wait(500)
        end
    end
end)

-- Draw /zde messages at locations
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local letSleep = true
        local pedCoords = GetEntityCoords(PlayerPedId())
        local zdeDistance = Config.ZdeDistance or 5.5
        
        for k, v in pairs(displayedMessages) do
            local dist = #(v.coords - pedCoords)
            if dist < zdeDistance then
                letSleep = false
                DrawText3DZde(v.coords.x, v.coords.y, v.coords.z, v.message)
            end
        end
        
        if letSleep then
            Wait(135)
        end
    end
end)

function DrawText3DZde(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        local scale = GetResolutionScale()
        local textScale = 0.35 * scale
        local color = Config.ZdeDrawTextColor or {255, 230, 0, 255}
        
        SetTextScale(textScale, textScale)
        SetTextFont(16)
        SetTextProportional(true)
        SetTextCentre(true)

        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local textWidth = EndTextCommandGetWidth(true)

        local bgWidth = textWidth + (0.010 * scale)
        local bgHeight = 0.027 * scale
        local rectOffset = 0.012 * scale
        
        SetTextEntry("STRING")
        AddTextComponentString(text)
        SetTextColour(color[1], color[2], color[3], color[4])
        DrawText(_x, _y)
        DrawRect(_x, _y + rectOffset, bgWidth, bgHeight, 0, 0, 0, 100)
    end
end

function DrawText3DStav(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        local scale = GetResolutionScale()
        local textScale = 0.35 * scale
        local color = Config.StavDrawTextColor or {255, 230, 0, 255}
        
        SetTextScale(textScale, textScale)
        SetTextFont(16)
        SetTextProportional(true)
        SetTextCentre(true)

        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local textWidth = EndTextCommandGetWidth(true)

        local bgWidth = textWidth + (0.010 * scale)
        local bgHeight = 0.027 * scale
        local rectOffset = 0.012 * scale
        
        SetTextEntry("STRING")
        AddTextComponentString(text)
        SetTextColour(color[1], color[2], color[3], color[4])
        DrawText(_x, _y)
        DrawRect(_x, _y + rectOffset, bgWidth, bgHeight, 0, 0, 0, 100)
    end
end

