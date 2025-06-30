Config = {}


Config.Locale = "en" -- en,cs

-- [Blacklisted World]
Config.Blacklisted = { 
 "negr"
}

-- Other config settings can be added here as needed

-- [Discord Logs]
Config.DiscordWebhookURLs = {
    ["me"] = 'WEBHOOK',
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
Config.MeCommand = true            -- true/false /me
Config.DoCommand = true            -- true/false /do
Config.DocCommand = true           -- true/false /doc
Config.TryCommand = true           -- true/false /try 
Config.StaffCommand = true         -- true/false /staff
Config.AnnouncementsCommand = true -- true/false /annoucement
Config.MsgCommand = true           -- true/false /msg
Config.PoliceCommand = true        -- true/false /lspd
Config.SheriffCommand = true       -- true/false /lssd
Config.AmbulanceCommand = true     -- true/false /ems
Config.OocStaffCommand = true      -- true/false /oocstaff

-- [Jobs]
Config.ambulance = 'ambulance' -- /ems
Config.sheriff = 'sheriff' -- /lssd
Config.police = 'police' -- /lspd

-- [VIP System]
Config.VIPSystem = false -- If false, VIP system is disabled
Config.VIPLicenses = {
   -- "license", -- Example license
   -- "license" 
}
