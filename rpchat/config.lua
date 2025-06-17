Config = {}


Config.Locale = "en" -- en,cs

-- [Blacklisted World]
Config.Blacklisted = { 
 "negr"
}

-- Other config settings can be added here as needed

-- [Discord Logs]
Config.DiscordWebhookURLs = {
    ["me"] = WEBHOOK',
    ["do"] = 'WEBHOOK',
    ["local_chat"] = 'WEBHOOK',
    ["try"] = 'WEBHOOK',
    ["msg"] = 'WEBHOOK',
    ["announcement"] = 'WEBHOOK',
    ["lssd"] = 'WEBHOOK',
    ["police"] = 'WEBHOOK',
    ["ambulance"] = 'WEBHOOK',
    ["doc"] = 'WEBHOOK',
    ["staff"] = 'WEBHOOK'
}

-- 🕒 **AUTO MESSAGES** - Automatic messages settings
Config.AutoMessages = false
Config.AutoMessageInterval = 1 -- In minutes (for testing)
Config.AutoMessagesList = { -- List of messages that will be sent randomly
    "Make sure to join our discord! discord.gg/invite",
   -- "You can use the /report command to report any problems!",
}


-- [Staff Groups]
Config.AllowedGroups = {
    admin = true,
   -- moderator = true,
   -- superadmin = true
}



-- [Chat Commands]
Config.CommandsDistance = 20       -- Distance Show commands
Config.CommandCooldown = 5         -- Cooldown Commands seconds
Config.OocCommand = true           -- true/false
Config.MeCommand = true            -- true/false
Config.DoCommand = true            -- true/false
Config.DocCommand = true           -- true/false
Config.TryCommand = true           -- true/false
Config.StaffCommand = true         -- true/false
Config.AnnouncementsCommand = true -- true/false
Config.MsgCommand = true           -- true/false
Config.PoliceCommand = true        -- true/false
Config.SheriffCommand = true       -- true/false
Config.AmbulanceCommand = true     -- true/false

-- [Jobs]
Config.ambulance = 'ambulance' -- /ems
Config.sheriff = 'sheriff' -- /lssd
Config.police = 'police' -- /lspd
