local ESX = nil
local textOffset = 0
------------------------------------------------------------------------------------------------
--------------ESX-------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end

    print("DEBUG: Pitrs Rpchat Loaded")
end)
AddEventHandler('onClientResourceStart', function (resourceName)
    if(GetCurrentResourceName() ~= resourceName) then
      return
    end
   --print('The resource ' .. resourceName .. ' has been started on the client.')
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
function DrawText3D(x, y, z, text, color, offset)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z + offset)
    if onScreen then
        local textLength = string.len(text)
        local bgWidth = 0.02 + (textLength / 250) 
        local bgHeight = 0.028 
        local bgX = _x
        local bgY = _y + (bgHeight / 2) 
        DrawRect(bgX, bgY, bgWidth, bgHeight, 0, 0, 0, 150)
        SetTextScale(0.35, 0.35)
        SetTextFont(16) 
        SetTextProportional(1)
        SetTextColour(color[1], color[2], color[3], color[4]) 
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
RegisterNetEvent('rpchat:sendMe', function(playerId, title, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)
        if targetPed == source or #(sourceCoords - targetCoords) < 20 then
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
                    DrawText3D(x, y, z, message, {0, 151, 255, 255}, offset)
                    if GetGameTimer() - startTime > displayDuration then
                        break
                    end
                end
            end)
            local playerName = GetPlayerName(source)
            TriggerEvent('chat:addMessage', { 
                template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 0px; color: white;"> <span style="background-color: rgba(0, 151, 255, 0.4); border-radius: 0px; padding: 2px 4px;">ME</span> ' .. playerName .. ' - <span style="color: white;">'.. message ..'</span></div>',
                args = { "[ME] - " .. playerName, message }
            })

            TriggerServerEvent('rpchat:sendToDiscord', "me", playerName .. " - " .. message, 3447003)
            textOffset = textOffset + 0.3
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
        if targetPed == source or #(sourceCoords - targetCoords) < 20 then
            local isInVehicle = IsPedInAnyVehicle(sourcePed, false)
            local baseOffset = isInVehicle and 0.7 or 1.2 -- výš nad hlavou
            local textOffset = 0.0 -- inicializace
            local offset = baseOffset + textOffset

            Citizen.CreateThread(function()
                local startTime = GetGameTimer()
                local displayDuration = 5000

                while true do
                    Citizen.Wait(0)

                    local targetPedCoords = GetEntityCoords(targetPed)
                    local x, y, z = targetPedCoords.x, targetPedCoords.y, targetPedCoords.z

                    DrawText3D(x, y, z, message, {255, 255, 0, 255}, offset)

                    if GetGameTimer() - startTime > displayDuration then
                        break
                    end
                end
            end)

            local playerName = GetPlayerName(target)
            TriggerEvent('chat:addMessage', {
                template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 0px; color: white;"> <span style="background-color: rgba(255, 255, 0, 0.4); border-radius: 0px; padding: 2px 4px;">DO</span> ' .. playerName .. ' - <span style="color: white;">'.. message ..'</span></div>',
                args = { "[DO] - " .. playerName, message }
            })
            TriggerServerEvent('rpchat:sendToDiscord', "do", playerName .. " - " .. message, 16776960)

            textOffset = textOffset + 0.3
        end
    end
end)
function DrawText3D(x, y, z, text, color, offset)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z + offset)
    if onScreen then
        local textLength = string.len(text)
        local bgWidth = 0.02 + (textLength / 250) 
        local bgHeight = 0.028 
        local bgX = _x
        local bgY = _y + (bgHeight / 2) 
        DrawRect(bgX, bgY, bgWidth, bgHeight, 0, 0, 0, 150)
        SetTextScale(0.35, 0.35) 
        SetTextFont(16) 
        SetTextProportional(1)
        SetTextColour(color[1], color[2], color[3], color[4]) 
        SetTextEntry("STRING")
        SetTextCentre(1) 
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
------------------------------------------------------------------------------------------------
---------------OOC------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendLocalOOC', function(playerId, title, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    if target ~= -1 then
        local sourcePed, targetPed = PlayerPedId(), GetPlayerPed(target)
        local sourceCoords, targetCoords = GetEntityCoords(sourcePed), GetEntityCoords(targetPed)

        if targetPed == source or #(sourceCoords - targetCoords) < 20 then
            local playerName = GetPlayerName(target)

            TriggerEvent('chat:addMessage', {
                template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 0px; color: white;"> <span style="background-color: rgba(255, 255, 0, 0.48); border-radius: 0px; padding: 2px 4px;">L-OOC</span> ' .. playerName .. ' - <span style="color: white;">' .. message .. '</span></div>',
                args = { "L-OOC - " .. playerName, message }
            })
            TriggerServerEvent('rpchat:sendToDiscord', "ooc", playerName .. "- " .. message, 8421504) 
        end
    end
end)
------------------------------------------------------------------------------------------------
---------------TRY------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterCommand('try', function()
    local result = math.random(1, 2)
    local playerName = GetPlayerName(PlayerId())

    if result == 1 then
        TriggerEvent('chat:addMessage', {
            template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 0px; color: white;"> <span style="background-color: rgba(0, 255, 0, 0.4); border-radius: 0px; padding: 2px 4px;">TRY</span> ' .. playerName .. ' <span style="color: white;">- Ano</span></div>',
            args = {}
        })
        TriggerServerEvent('rpchat:sendToDiscord', "try", playerName .. ": Ano", 65280)
    else
        TriggerEvent('chat:addMessage', {
            template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 0px; color: white;"> <span style="background-color: rgba(255, 0, 0, 0.4); border-radius: 0px; padding: 2px 4px;">TRY</span> ' .. playerName .. ' <span style="color: white;">- Ne</span></div>',
            args = {}
        })
        TriggerServerEvent('rpchat:sendToDiscord', "try", playerName .. ": Ne", 16711680) -- Červená barva
    end
end, false)
------------------------------------------------------------------------------------------------
---------------DOC------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterCommand('doc', function(source, args, rawCommand)
    local count = 1
    local targetPed = PlayerPedId()
    local target = 20

    if args[1] then
        target = tonumber(args[1])
        if target > 50 then
            lib.notify({
                title = 'Chyba',
                description = 'Maximální povolené číslo je 50.',
                type = 'error'
            })
            return
        end
    end
    function DrawText3D(x, y, z, text, color)
        local onScreen, _x, _y = World3dToScreen2d(x, y, z)
        if onScreen then
            local textLength = string.len(text)
            local bgWidth = 0.02 + (textLength / 250)
            local bgHeight = 0.027
    
            local offsetX = 0.005 -- posun doprava
    
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
    Citizen.CreateThread(function()
        local startTime = GetGameTimer()
        local updateInterval = 1000
        local lastUpdate = 0

        while count <= target do
            Citizen.Wait(0)
        
            local targetCoords = GetEntityCoords(targetPed)
            local x, y, z = targetCoords.x, targetCoords.y, targetCoords.z + 1.2 
        
            local currentTime = GetGameTimer()
            if currentTime - lastUpdate >= updateInterval then
                lastUpdate = currentTime
                count = count + 1
            end
            DrawText3D(x, y, z, "" .. count .. " / " .. target, {255, 255, 255, 255}) 
        
            if count > target then
                break
            end
        end        
    end)
    TriggerServerEvent('rpchat:sendToDiscord', "doc", "Příkaz vykonán s cílem: " .. target, 16777215) 
end, false)
------------------------------------------------------------------------------------------------
--------------ADMIN-----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendOznameni', function(playerId, title, message, color)
    local source = PlayerId()
    local target = GetPlayerFromServerId(playerId)
    
    if target ~= -1 then
        TriggerEvent('chat:addMessage', {
            template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 0px; color: white;">' ..
                        '<span style="background-color: rgba(255, 0, 0, 0.8); border-radius: 0px; padding: 2px 4px;">OZNÁMENÍ</span> ' ..
                        '<span style="color: white;">' .. message .. '</span></div>',
            args = { message }
        })
        TriggerServerEvent('rpchat:sendToDiscord', "oznameni", message, 16711680) 
    end
end)

RegisterNetEvent('rpchat:sendPrivateMessage', function(senderId, message)
    local senderName = GetPlayerName(GetPlayerFromServerId(senderId))
    TriggerEvent('chat:addMessage', {
        template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 0px; color: white;">' ..
                    '<span style="background-color: rgba(0, 255, 0, 0.8); border-radius: 0px; padding: 2px 4px;">MSG</span> ' ..
                    '<span style="color: white;">' .. senderName .. '- ' .. message .. '</span></div>',
        args = { senderName, message }
    })
end)
------------------------------------------------------------------------------------------------
--------------JOBS------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--RegisterCommand('police', function(source, args, rawCommand)
   -- local msg = rawCommand:sub(6)
   -- local job = PlayerData.job.name
   -- if PlayerData.job.name == "police" and PlayerData.job.onduty then
    --    TriggerServerEvent('esx_rpchat:chat', job, msg)
   -- end						
--end, false)

--RegisterNetEvent('esx_rpchat:Send')
--AddEventHandler('esx_rpchat:Send', function(messageFull, job)
    --local PlayerData = ESX.GetPlayerData()
    --if PlayerData.job.name == job and PlayerData.job.onduty then
       -- TriggerEvent('chat:addMessage', messageFull)
  --  end
--end)
------------------------------------------------------------------------------------------------
--------------AUTO MESSAGE----------------------------------------------------------------------
------------------------------------------------------------------------------------------------
RegisterNetEvent('rpchat:sendAutoMessage', function(message)
    TriggerEvent('chat:addMessage', {
        template = '<div style="margin-bottom: 5px; padding: 10px; background-color: rgba(10, 10, 10, 0.7); border-radius: 0px; color: white;">' ..
                    '<span style="background-color: rgba(0, 151, 255, 0.4); border-radius: 0px; padding: 2px 4px;">CHAT</span> ' .. 
                    '<span style="color: white;">' .. message .. '</span></div>',
        args = { "[Chat]", message }
    })
end)
