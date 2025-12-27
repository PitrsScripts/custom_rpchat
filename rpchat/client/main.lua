local ESX = nil
local textOffset = 0
local playerLicense = nil
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
                    DrawText3DMe(x, y, z, message, {255, 255, 255, 255})
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
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><style>* { font-family: Poppins, sans-serif !important; }</style><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif !important; position: relative;"> <span style="background-color: rgb(168, 96, 202); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif !important;">' .. meLabel .. '</span> ' .. playerName .. ' - <span style="color: white; font-family: Poppins, sans-serif !important; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "[ME] - " .. playerName, message }
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
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(0, 100, 150); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">LSPD</span> <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "[LSPD]", message }
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
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(255, 165, 0); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">LSSD</span> <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "[LSSD]", message }
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
                    DrawText3DDo(x, y, z, message, {255, 255, 255, 255})
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
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(0, 169, 211); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">' .. doLabel .. '</span> ' .. playerName .. ' - <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "[DO] - " .. playerName, message }
            })
        end
    end
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
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: rgb(255, 255, 255); border-radius: 10px; padding: 2px 4px; color: black; font-weight: 600; font-family: Poppins, sans-serif;">EMS</span> <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "[EMS]", message }
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
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;"> <span style="background-color: #737373; border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">' .. oocLabel .. '</span> ' .. playerName .. ' - <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "L-OOC - " .. playerName, message }
            })
        end
    end
end)

RegisterNetEvent('rpchat:sendLocalOOCStaff', function(playerId, playerName, message)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        if targetPed == source or #(sourceCoords - targetCoords) < Config.CommandsDistance then
            local timeSpan = GetTimeSpan()
            TriggerEvent('chat:addMessage', {
                template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;">'
                    .. '<span style="background-color: red; border-radius: 10px; padding: 2px 4px; color: white; margin-right: 5px; font-weight: 600; font-family: Poppins, sans-serif;">ADMIN</span>'
                    .. '<span style="background-color: #737373; border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">L-OOC</span> '
                    .. playerName .. ' - <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
                args = { "L-OOC - " .. playerName, message }
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
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local targetPed = PlayerPedId() 
    local targetCoords = GetEntityCoords(targetPed)
    if #(playerCoords - targetCoords) < Config.CommandsDistance then
        local timeSpan = GetTimeSpan()
        TriggerEvent('chat:addMessage', {
            template = string.format(
                '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;">' ..
                ' <span style="background-color: %s; border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">%s</span> %s <span style="color: white; font-family: Poppins, sans-serif;">- %s</span>%s</div>',
                bgColor, tryLabel, playerName, response, timeSpan
            ),
            args = {}
        })
    end
end)
------------------------------------------------------------------------------------------------
---------------DOC------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendDocMessage')
AddEventHandler('rpchat:sendDocMessage', function(count, target)
    Citizen.CreateThread(function()
        local startTime = GetGameTimer()
        local updateInterval = 1000
        local lastUpdate = 0
        local targetPed = PlayerPedId()
        while count <= target do
            Citizen.Wait(0)
            local targetCoords = GetEntityCoords(targetPed)
            local x, y, z = targetCoords.x, targetCoords.y, targetCoords.z + 1.2 
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            if #(playerCoords - targetCoords) < Config.CommandsDistance then
                local currentTime = GetGameTimer()
                if currentTime - lastUpdate >= updateInterval then
                    lastUpdate = currentTime
                    count = count + 1
                end
                DrawText3DDoc(x, y, z, "" .. count .. " / " .. target, {255, 255, 255, 255}) 
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
RegisterNetEvent("rpchat:receiveStaffMessage", function(senderName, message)
    local timeSpan = GetTimeSpan()
    TriggerEvent('chat:addMessage', {
        template = [[
            <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
            <div style="
                margin-bottom: 5px;
                padding: 10px;
                background-color: rgba(10, 10, 10, 0.5);
                border-radius: 10px;
                color: white;
                font-family: Poppins, sans-serif;
                position: relative;
            ">
                <span style="
                    background-color: orange;
                    border-radius: 10px;
                    padding: 2px 6px;
                    color: white;
                    font-weight: 600;
                    font-family: Poppins, sans-serif;
                ">STAFF</span> {0} - <span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>]] .. timeSpan .. [[
            </div>
        ]],
        args = { senderName, message }
    })
end)
RegisterNetEvent('rpchat:sendAnnouncement', function(playerId, title, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    
    if target ~= -1 then
        local timeSpan = GetTimeSpan()
        TriggerEvent('chat:addMessage', {
            template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;">' ..
                        '<span style="background-color: rgba(255, 0, 0, 0.8); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">Announcement</span> ' ..
                        '<span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
            args = { message }
        })
    end
end)
RegisterNetEvent('rpchat:sendPrivateMessage', function(senderId, message)
    local senderName = GetPlayerName(GetPlayerFromServerId(senderId))
    local timeSpan = GetTimeSpan()
    TriggerEvent('chat:addMessage', {
        template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;">' ..
                    '<span style="background-color: rgba(0, 255, 0, 0.8); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">MSG</span> ' ..
                    '<span style="color: white; font-family: Poppins, sans-serif;">' .. senderName .. '- <span style="word-wrap: break-word; white-space: pre-wrap;">{1}</span></span>' .. timeSpan .. '</div>',
        args = { senderName, message }
    })
end)
------------------------------------------------------------------------------------------------
--------------AUTO MESSAGE----------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendAutoMessage', function(message)
    local timeSpan = GetTimeSpan()
    TriggerEvent('chat:addMessage', {
        template = '<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet"><div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.5); border-radius: 10px; color: white; font-family: Poppins, sans-serif; position: relative;">' ..
                    '<span style="background-color: rgba(0, 151, 255, 0.4); border-radius: 10px; padding: 2px 4px; color: white; font-weight: 600; font-family: Poppins, sans-serif;">CHAT</span> ' .. 
                    '<span style="color: white; font-family: Poppins, sans-serif; word-wrap: break-word; white-space: pre-wrap;">{1}</span>' .. timeSpan .. '</div>',
        args = { "[Chat]", message }
    })
end)
------------------------------------------------------------------------------------------------
--------------DRAW TEXT-------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
function DrawText3DMe(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z + 1.0) 
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(16)
        SetTextProportional(true)
        SetTextCentre(true)

        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local textWidth = EndTextCommandGetWidth(true)

        local bgWidth = textWidth + 0.010
        local bgHeight = 0.027
        SetTextEntry("STRING")
        AddTextComponentString(text)
        SetTextColour(color[1], color[2], color[3], color[4])
        DrawText(_x, _y)
        DrawRect(_x, _y + 0.012, bgWidth, bgHeight, 0, 0, 0, 100)
    end
end

function DrawText3DDo(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z + 1.0)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(16)
        SetTextProportional(true)
        SetTextCentre(true)

        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local textWidth = EndTextCommandGetWidth(true)
        local bgWidth = textWidth + 0.010
        local bgHeight = 0.027
        SetTextEntry("STRING")
        AddTextComponentString(text)
        SetTextColour(color[1], color[2], color[3], color[4])
        DrawText(_x, _y)
        DrawRect(_x, _y + 0.012, bgWidth, bgHeight, 0, 0, 0, 100)
    end
end

function DrawText3DDoc(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        local textLength = string.len(text)
        local bgWidth = 0.02 + (textLength / 250)
        local bgHeight = 0.027
        local offsetX = 0.005 
        SetTextScale(0.35, 0.35)
        SetTextFont(16)
        SetTextProportional(true)
        SetTextColour(color[1], color[2], color[3], color[4])
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x + offsetX, _y)
        DrawRect(_x + offsetX, _y + 0.012, bgWidth, bgHeight, 0, 0, 0, 150)
    end
end
