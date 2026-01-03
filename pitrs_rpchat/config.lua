Config = {}

-- [Locales]
Config.Locale = "cs" -- en,cs,de,en,fr

-- [Notifications]
Config.Notifications = true       -- true/false ox_lib notifications for errors (cooldown, permissions, etc.)


-- [Character Name Display]
Config.CharacterName = true -- true = show character name initials (R.E), false = show full name

-- [Blacklisted World]
Config.Blacklisted = { 
 "negr"
}

-- [Time Display]
Config.ShowTimeInChat = true -- true/false - Show time in chat

-- [Staff Groups]
Config.AllowedGroups = {
    admin = true,
    developer = true,
   -- superadmin = true
}

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
    ["staff"] = 'WEBHOOK',
    ["ad"] = 'WEBHOOK',
    ["twt"] = 'WEBHOOK',
    ["stav"] = 'WEBHOOK', 
    ["zde"] = 'WEBHOOK', 
}

-- 🕒 **AUTO MESSAGES** - Automatic messages settings
Config.AutoMessages = false
Config.AutoMessageInterval = 1 -- In minutes (for testing)
Config.AutoMessagesList = { -- List of messages that will be sent randomly
    "Make sure to join our discord! discord.gg/invite",
   -- "You can use the /report command to report any problems!",
}




-- [Chat Commands]
Config.CommandsDistance = 20       -- Distance Show commands
Config.CommandCooldown = 0         -- Cooldown Commands seconds
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
Config.AdCommand = true            -- true/false /ad
Config.TwtCommand = true           -- true/false /twt
Config.StavCommand = true          -- true/false /stav 
Config.ZdeCommand = true           -- true/false /zde 

-- [Stav/Zde Commands]
Config.ZdeMaxMessages = 5          -- Maximum /zde messages per player
Config.ZdeDistance = 5.5           -- Distance to see /zde messages
Config.StavDistance = 8.0          -- Distance to see /stav status

-- [Ad Command] 
Config.AdPrice = 0             -- Price for /ad command

-- [Jobs] 
Config.JobAmbulance = 'ambulance' -- Job for the /ems command
Config.JobSheriff = 'sheriff'     -- Job for /lssd command
Config.JobPolice = 'police'       -- Job for /lspd command


-- [Command Names] 
Config.CommandMe = 'me'                    -- /me - action description
Config.CommandDo = 'do'                    -- /do - environment description
Config.CommandTry = 'try'                  -- /try - random success/fail
Config.CommandDoc = 'doc'                  -- /doc - document command
Config.CommandStav = 'stav'                -- /stav - status above head
Config.CommandZde = 'zde'                  -- /zde - text at location

-- Communication Commands
Config.CommandMsg = 'msg'                  -- /msg - private message
Config.CommandAd = 'ad'                    -- /ad - advertisement
Config.CommandTwt = 'twt'                  -- /twt - twitter
Config.CommandAnnouncement = 'announcement' -- /announcement - server announcement

-- Job Commands
Config.CommandLspd = 'lspd'                -- /lspd - police chat
Config.CommandLssd = 'lssd'                -- /lssd - sheriff chat
Config.CommandEms = 'ems'                  -- /ems - ambulance chat

-- Staff Commands
Config.CommandStaff = 'staff'              -- /staff - staff chat
Config.CommandOocstaff = 'oocstaff'        -- /oocstaff - OOC staff chat


-- [DrawText Colors] 
Config.MeDrawTextColor   = {168, 96, 202, 255}   -- Purple
Config.DoDrawTextColor   = {0, 169, 211, 255}    -- Light Blue / Cyan
Config.StavDrawTextColor = {255, 230, 0, 255}    -- Yellow
Config.ZdeDrawTextColor  = {255, 230, 0, 255}    -- (Yellow


-- [DrawText]
Config.MeDrawText = true -- true/false 
Config.DoDrawText = true -- true/false

-- [VIP System]
Config.VIPSystem = true -- If false, VIP system is disabled
Config.VIPLicenses = {
    "license", -- Example license
   -- "license" 
}

