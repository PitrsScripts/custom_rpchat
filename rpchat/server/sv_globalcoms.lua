local ESX = nil

ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('chatMessage', function(source, name, message)
  if string.sub(message, 1, string.len('/')) ~= '/' then
    CancelEvent()
    TriggerClientEvent('rpchat:sendLocalOOC', -1, source, name, message, {30, 144, 255})
  end
end)

ESX.RegisterCommand('clear', 'user', function(xPlayer, args, rawCommand)
  TriggerClientEvent('chat:clear', xPlayer.source)
end, false, {help = "Clear Chat"})

ESX.RegisterCommand('clearall', 'admin', function(xPlayer, args, rawCommand)
  TriggerClientEvent('chat:clear', -1)
end, false, {help = "Clear All Chat (Admin Only)"})

RegisterCommand('msg', function(source, args, rawCommand)
  if source == 0 then
    return
  end
  
  if tonumber(args[1]) and args[2] then
    local id = tonumber(args[1])
    local msg = table.concat(args, ' ', 2)
    local name = GetPlayerName(source)
    
    local target = ESX.GetPlayerFromId(id)

    if target then
      TriggerClientEvent('chat:addMessage', id, {
        template = '<div style="font-weight:bold;font-size: 1.35vh; border-radius: 3px;"> <b> <b style=color:#5dc91e>MSG |<b style=color:#5dc91e> ID {1}:<b style=color:#ffffff;font-weight:normal> {2}  </br></div>',
        args = { name, msg }
      })
      TriggerClientEvent('chat:addMessage', source, {
        template = '<div style="font-weight:bold;font-size: 1.35vh; border-radius: 3px;"> <b> <b style=color:#5dc91e>MSG |<b style=color:#5dc91e> ID {1}:<b style=color:#ffffff;font-weight:normal> {2}  </br></div>',
        args = { name, msg }
      })
    else
      TriggerClientEvent('esx:showNotification', source, "This ID does not correspond to any active player.", "error")
    end
  else
    TriggerClientEvent('esx:showNotification', source, "You are not using the command correctly: /msg id message.", "error")
  end
end, false)

RegisterCommand('dados', function(source, args, user)
  local name = GetCharacterName(source)
  num = math.random(1, 10)
  TriggerClientEvent("esx_rpchat:sendDados", -1, source, name, num, table.concat(args, " "))
end, false)


RegisterCommand('ooc', function(source, args, raw)
  if source == 0 then
    print('rpchat: you can\'t use this command from rcon!')
    return
  end
  args = table.concat(args, ' ')
  local name = GetCharacterName(source)

  TriggerClientEvent('rpchat:sendLocalOOC', -1, source, name, args, {196, 33, 246})
end)

RegisterCommand('me', function(source, args, raw)
  if source == 0 then
    print('rpchat: you can\'t use this command from rcon!')
    return
  end
  args = table.concat(args, ' ')
  local name = GetCharacterName(source)

  TriggerClientEvent('rpchat:sendMe', -1, source, name, args, {196, 33, 246})
end)

RegisterCommand('do', function(source, args, raw)
  if source == 0 then
    print('rpchat: you can\'t use this command from rcon!')
    return
  end

  args = table.concat(args, ' ')
  local name = GetCharacterName(source)

  TriggerClientEvent('rpchat:sendDo', -1, source, name, args, {255, 198, 0})
end)

RegisterCommand('sapd', function(source, args, rawCommand)
  local xPlayer = ESX.GetPlayerFromId(source)
  local toSay = table.concat(args, ' ')

  if xPlayer.getJob().name == Config.police then 
    TriggerClientEvent('chat:addMessage', -1, {
      template = '<div style="font-weight:bold;font-size:1.35vh;color: #54E0FF; margin: 0.05vw;">👮 SAPD Announcement: <b style=color:#ffffff;font-weight:normal>{0}</div>',
      args = { toSay }
    })
  else 
    TriggerClientEvent('chat:addMessage', source, {
      template = '<div style="color: #FF3E32; margin: 0.05vw;"><i class="fas fa-exclamation"></i>  You need to be a police officer to use this command. <i class="fas fa-exclamation"></i></div>',
      args = {}
    })
  end
end, false)

RegisterCommand('lssd', function(source, args, rawCommand)
  local xPlayer = ESX.GetPlayerFromId(source)
  local toSay = table.concat(args, ' ')

  if xPlayer.getJob().name == Config.sheriff then 
    TriggerClientEvent('chat:addMessage', -1, {
      template = '<div style="font-weight:bold;font-size:1.35vh;color: #54E0FF; margin: 0.05vw;">👮 LSSD Announcement: <b style=color:#ffffff;font-weight:normal>{0}</div>',
      args = { toSay }
    })
  else 
    TriggerClientEvent('chat:addMessage', source, {
      template = '<div style="color: #FF3E32; margin: 0.05vw;"><i class="fas fa-exclamation"></i>  You need to be a sheriff officer to use this command. <i class="fas fa-exclamation"></i></div>',
      args = {}
    })
  end
end, false)



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

