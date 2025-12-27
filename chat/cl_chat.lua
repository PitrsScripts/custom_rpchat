local chatInputActive = false
local chatInputActivating = false
local chatHidden = true
local chatLoaded = false
local chatVisible = true
s = 100
_s = 2000
RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:addTemplate')
RegisterNetEvent('chat:addMessage')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:addSuggestions')
RegisterNetEvent('chat:removeSuggestion')
RegisterNetEvent('chat:clear')

-- internal events
RegisterNetEvent('__cfx_internal:serverPrint')

RegisterNetEvent('_chat:messageEntered')

--deprecated, use chat:addMessage
AddEventHandler('chatMessage', function(author, color, text)
  local args = { text }
  if author ~= "" then
    table.insert(args, 1, author)
  end
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = {
      color = color,
      multiline = true,
      args = args
    }
  })
end)

AddEventHandler('__cfx_internal:serverPrint', function(msg)
  print(msg)

  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = {
      templateId = 'print',
      multiline = true,
      args = { msg }
    }
  })
end)

AddEventHandler('chat:addMessage', function(message)
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = message
  })
end)

AddEventHandler('chat:addSuggestion', function(name, help, params)
  SendNUIMessage({
    type = 'ON_SUGGESTION_ADD',
    suggestion = {
      name = name,
      help = help,
      params = params or nil
    }
  })
end)

AddEventHandler('chat:addSuggestions', function(suggestions)
  for _, suggestion in ipairs(suggestions) do
    SendNUIMessage({
      type = 'ON_SUGGESTION_ADD',
      suggestion = suggestion
    })
  end
end)

AddEventHandler('chat:removeSuggestion', function(name)
  SendNUIMessage({
    type = 'ON_SUGGESTION_REMOVE',
    name = name
  })
end)

AddEventHandler('chat:addTemplate', function(id, html)
  SendNUIMessage({
    type = 'ON_TEMPLATE_ADD',
    template = {
      id = id,
      html = html
    }
  })
end)

AddEventHandler('chat:clear', function(name)
  SendNUIMessage({
    type = 'ON_CLEAR'
  })
end)



RegisterNUICallback('chatResult', function(data, cb)
  chatInputActive = false
  SetNuiFocus(false)

  if not data.canceled then
    local id = PlayerId()

    --deprecated
    local r, g, b = 0, 0x99, 255

    if data.message:sub(1, 1) == '/' then
      ExecuteCommand(data.message:sub(2))
    else
      TriggerServerEvent('_chat:messageEntered', GetPlayerName(id), { r, g, b }, data.message)
    end
  end

  cb('ok')
end)

local function refreshCommands()
  if GetRegisteredCommands then
    local registeredCommands = GetRegisteredCommands()

    local suggestions = {}

    for _, command in ipairs(registeredCommands) do
        if IsAceAllowed(('command.%s'):format(command.name)) then
            table.insert(suggestions, {
                name = '/' .. command.name,
                help = ''
            })
        end
    end

    TriggerEvent('chat:addSuggestions', suggestions)
  end
end

local function refreshThemes()
  local themes = {}

  for resIdx = 0, GetNumResources() - 1 do
    local resource = GetResourceByFindIndex(resIdx)

    if GetResourceState(resource) == 'started' then
      local numThemes = GetNumResourceMetadata(resource, 'chat_theme')

      if numThemes > 0 then
        local themeName = GetResourceMetadata(resource, 'chat_theme')
        local themeData = json.decode(GetResourceMetadata(resource, 'chat_theme_extra') or 'null')

        if themeName and themeData then
          themeData.baseUrl = 'nui://' .. resource .. '/'
          themes[themeName] = themeData
        end
      end
    end
  end

  SendNUIMessage({
    type = 'ON_UPDATE_THEMES',
    themes = themes
  })
end

-- Debounced refresh - prevents spam when multiple resources start/stop
local refreshPending = false

local function scheduleRefresh()
  if refreshPending then return end
  refreshPending = true
  
  SetTimeout(2000, function()
    refreshPending = false
    if chatLoaded then
      refreshCommands()
      refreshThemes()
    end
  end)
end

AddEventHandler('onClientResourceStart', function(resName)
  scheduleRefresh()
end)

AddEventHandler('onClientResourceStop', function(resName)
  scheduleRefresh()
end)

RegisterNUICallback('loaded', function(data, cb)
  TriggerServerEvent('chat:init');

  refreshCommands()
  refreshThemes()

  chatLoaded = true

  cb('ok')
end)

-- Chat input using keymapping instead of polling
RegisterCommand('_openChat', function()
  if not chatInputActive then
    chatInputActive = true
    chatInputActivating = true
    
    SendNUIMessage({
      type = 'ON_OPEN'
    })
    
    -- Wait for key release then focus
    CreateThread(function()
      while IsControlPressed(0, 245) do
        Wait(0)
      end
      SetNuiFocus(true, true)
      chatInputActivating = false
    end)
  end
end, false)

RegisterKeyMapping('_openChat', 'Open Chat', 'keyboard', 't')

CreateThread(function()
  SetTextChatEnabled(false)
  SetNuiFocus(false)
  TriggerEvent('chat:addSuggestion', '/_openChat', 'Open chat (internal)', {})
    TriggerEvent('chat:addSuggestion', '/chat', 'Toggle chat visibility', {})
end)

RegisterCommand('chat', function()
    chatVisible = not chatVisible
end, false)

RegisterKeyMapping('chat', 'Toggle Chat Visibility', 'keyboard', 'n')


CreateThread(function()
  while true do
    Wait(500)
    
    if chatLoaded then
      local shouldBeHidden = IsScreenFadedOut() or IsPauseMenuActive() or not chatVisible

      if shouldBeHidden ~= chatHidden then
        chatHidden = shouldBeHidden

        SendNUIMessage({
          type = 'ON_SCREEN_STATE_CHANGE',
          shouldHide = shouldBeHidden
        })
      end
    end
  end
end)

function AderNotify(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local factor = #text / 370
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    DrawRect(_x,_y + 0.0125, 0.060 + factor, 0.035, 0, 0, 0, 190)
end