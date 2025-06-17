local ESX = nil
local textOffset = 0
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
--------------ME--------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendMe', function(playerId, title, message, color)
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
                    DrawText3DMe(x, y, z, message, {168, 96, 202, 255}, offset)
                    if GetGameTimer() - startTime > displayDuration then
                        break
                    end
                end
            end)
            

            local playerName = GetPlayerName(target) 
            TriggerEvent('chat:addMessage', { 
                template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 5px; color: white;"> <span style="background-color: rgb(168, 96, 202); border-radius: 5px; padding: 2px 4px; color: black;">ME</span> ' .. playerName .. ' - <span style="color: white;">'.. message ..'</span></div>',
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
            TriggerEvent('chat:addMessage', { 
                template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 5px; color: white;"> <span style="background-color: rgb(0, 100, 150); border-radius: 5px; padding: 2px 4px; color: black;">LSPD</span> <span style="color: white;">'.. message ..'</span></div>',
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
            TriggerEvent('chat:addMessage', { 
                template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 5px; color: white;"> <span style="background-color: rgb(255, 165, 0); border-radius: 5px; padding: 2px 4px; color: black;">LSSD</span> <span style="color: white;">'.. message ..'</span></div>',
                args = { "[LSSD]", message }
            })
        end
    end
end)
------------------------------------------------------------------------------------------------
----------------DO------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendDo', function(playerId, title, message, color)
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
                    DrawText3DDo(x, y, z, message, {0, 169, 211, 255}, offset)
                    if GetGameTimer() - startTime > displayDuration then
                        break
                    end
                end
            end)
            local playerName = GetPlayerName(target)
            TriggerEvent('chat:addMessage', {
                template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 5px; color: white;"> <span style="background-color: rgb(0, 169, 211); border-radius: 5px; padding: 2px 4px; color: black;">DO</span> ' .. playerName .. ' - <span style="color: white;">'.. message ..'</span></div>',
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
            TriggerEvent('chat:addMessage', { 
                template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 5px; color: white;"> <span style="background-color: rgb(255, 255, 255); border-radius: 5px; padding: 2px 4px; color: black;">EMS</span> <span style="color: white;">'.. message ..'</span></div>',
                args = { "[EMS]", message }
            })
        end
    end
end)
------------------------------------------------------------------------------------------------
---------------OOC------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendLocalOOC', function(playerId, title, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        if targetPed == source or #(sourceCoords - targetCoords) < Config.CommandsDistance then
            local playerName = GetPlayerName(target)
            TriggerEvent('chat:addMessage', {
                template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 5px; color: white;"> <span style="background-color: rgb(243, 243, 53); border-radius: 5px; padding: 2px 4px; color: black;">L-OOC</span> ' .. playerName .. ' - <span style="color: white;">' .. message .. '</span></div>',
                args = { "L-OOC - " .. playerName, message }
            })
        end
    end
end)

------------------------------------------------------------------------------------------------
---------------TRY------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:showTryMessage', function(playerName, response, bgColor)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local targetPed = PlayerPedId() 
    local targetCoords = GetEntityCoords(targetPed)
    if #(playerCoords - targetCoords) < Config.CommandsDistance then
        TriggerEvent('chat:addMessage', {
            template = string.format(
                '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 5px; color: white;">' ..
                ' <span style="background-color: %s; border-radius: 5px; padding: 2px 4px; color: black;">TRY</span> %s <span style="color: white;">- %s</span></div>',
                bgColor, playerName, response
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
    TriggerEvent('chat:addMessage', {
        template = [[
            <div style="
                margin-bottom: 5px;
                padding: 10px;
                background-color:  rgba(10, 10, 10, 0.7);
                border-radius: 5px;
                color: white;
            ">
                <span style="
                    background-color: orange;
                    border-radius: 5px;
                    padding: 2px 6px;
                    color: black;
                    font-weight: bold;
                ">STAFF</span> {0}: <span style="color: white;">{1}</span>
            </div>
        ]],
        args = { senderName, message }
    })
end)
RegisterNetEvent('rpchat:sendAnnouncement', function(playerId, title, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    
    if target ~= -1 then
        TriggerEvent('chat:addMessage', {
            template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 5px; color: white;">' ..
                        '<span style="background-color: rgba(255, 0, 0, 0.8); border-radius: 5px; padding: 2px 4px; color: black;">Announcement</span> ' ..
                        '<span style="color: white;">' .. message .. '</span></div>',
            args = { message }
        })
    end
end)
RegisterNetEvent('rpchat:sendPrivateMessage', function(senderId, message)
    local senderName = GetPlayerName(GetPlayerFromServerId(senderId))
    TriggerEvent('chat:addMessage', {
        template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 5px; color: white;">' ..
                    '<span style="background-color: rgba(0, 255, 0, 0.8); border-radius: 5px; padding: 2px 4px; color: black;">MSG</span> ' ..
                    '<span style="color: white;">' .. senderName .. '- ' .. message .. '</span></div>',
        args = { senderName, message }
    })
end)
------------------------------------------------------------------------------------------------
--------------AUTO MESSAGE----------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendAutoMessage', function(message)
    TriggerEvent('chat:addMessage', {
        template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 5px; color: white;">' ..
                    '<span style="background-color: rgba(0, 151, 255, 0.4); border-radius: 5px; padding: 2px 4px; color: black;">CHAT</span> ' .. 
                    '<span style="color: white;">' .. message .. '</span></div>',
        args = { "[Chat]", message }
    })
end)
------------------------------------------------------------------------------------------------
--------------DRAW TEXT-------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
function DrawText3DMe(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z + 1.2) 
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(16)
        SetTextProportional(1)
        SetTextCentre(1)

        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local textWidth = EndTextCommandGetWidth(1) 

        local bgWidth = textWidth + 0.010
        local bgHeight = 0.027
        SetTextEntry("STRING")
        AddTextComponentString(text)
        SetTextColour(color[1], color[2], color[3], color[4])
        DrawText(_x, _y)
        DrawRect(_x, _y + 0.012, bgWidth, bgHeight, 0, 0, 0, 150)
    end
end

function DrawText3DDo(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z + 1.2)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(16)
        SetTextProportional(1)
        SetTextCentre(true)

        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local textWidth = EndTextCommandGetWidth(1)
        local bgWidth = textWidth + 0.010
        local bgHeight = 0.027
        SetTextEntry("STRING")
        AddTextComponentString(text)
        SetTextColour(color[1], color[2], color[3], color[4])
        DrawText(_x, _y)
        DrawRect(_x, _y + 0.012, bgWidth, bgHeight, 0, 0, 0, 150)
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
        SetTextProportional(1)
        SetTextColour(color[1], color[2], color[3], color[4])
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x + offsetX, _y)
        DrawRect(_x + offsetX, _y + 0.012, bgWidth, bgHeight, 0, 0, 0, 150)
    end
end
