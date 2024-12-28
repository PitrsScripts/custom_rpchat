local ESX = nil

ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('chatMessage', function(source, name, message)
  if string.sub(message, 1, string.len('/')) ~= '/' then
    CancelEvent()
    TriggerClientEvent('rpchat:sendLocalOOC', -1, source, name, message, {30, 144, 255})
  end
end)
--OOC
RegisterCommand('ooc', function(source, args, raw)
  if source == 0 then
    print('rpchat: you can\'t use this command from rcon!')
    return
  end
  args = table.concat(args, ' ')
  local name = GetCharacterName(source)

  TriggerClientEvent('rpchat:sendLocalOOC', -1, source, name, args, {196, 33, 246})
end)
--ME
RegisterCommand('me', function(source, args, raw)
  if source == 0 then
    print('rpchat: you can\'t use this command from rcon!')
    return
  end
  args = table.concat(args, ' ')
  local name = GetCharacterName(source)

  TriggerClientEvent('rpchat:sendMe', -1, source, name, args, {196, 33, 246})
end)
--DO
RegisterCommand('do', function(source, args, raw)
  if source == 0 then
    print('rpchat: you can\'t use this command from rcon!')
    return
  end

  args = table.concat(args, ' ')
  local name = GetCharacterName(source)

  TriggerClientEvent('rpchat:sendDo', -1, source, name, args, {255, 198, 0})
end)
--Sheriff
RegisterCommand('lssd', function(source, args, rawCommand)
  if not Config.EnableSheriffCommand then
      print('rpchat: The /lssd command is disabled in the config.')
      return
  end
  local xPlayer = ESX.GetPlayerFromId(source)
  local toSay = table.concat(args, ' ')
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
--OZNAMENI
RegisterCommand('oznameni', function(source, args, raw)
  if not Config.EnableAnnouncementsCommand then
      print('rpchat: The /oznameni command is disabled in the config.')
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
  args = table.concat(args, ' ')
  TriggerClientEvent('rpchat:sendOznameni', -1, source, "", args, {255, 0, 0})
end)
--MSG
RegisterCommand('msg', function(source, args, raw)
  if not Config.EnableMsgCommand then
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
  local senderName = GetPlayerName(source)
  local targetName = GetPlayerName(targetId)
  local webhookURL = Config.DiscordWebhookURLs["msg"] 
  if webhookURL then
      PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
          embeds = {
              {
                  title = "Soukromá zpráva",
                  description = string.format("**Odesílatel:** %s (ID: %d)\n**Příjemce:** %s (ID: %d)\n**Zpráva:** %s", senderName, source, targetName, targetId, message),
                  color = 3447003
              }
          }
      }), { ['Content-Type'] = 'application/json' })
  end
  TriggerClientEvent('rpchat:sendPrivateMessage', targetId, source, message)
end)
--CHAT
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

