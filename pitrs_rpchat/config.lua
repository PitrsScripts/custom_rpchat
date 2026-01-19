Config = {}

-- [Locales]
Config.Locale = "cs" -- en,cs,de,en,fr

-- [Notifications]
Config.Notifications = true   -- true/false ox_lib notifications for errors (cooldown, permissions, etc.)


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

-- [AUTO MESSAGES]
Config.AutoMessages = false
Config.AutoMessageInterval = 1 -- In minutes (for testing)
Config.AutoMessagesList = { -- List of messages that will be sent randomly
    "Make sure to join our discord! discord.gg/invite",
   -- "You can use the /report command to report any problems!",
}




-- [Chat Commands]
Config.CommandsDistance = 10      -- Distance Show commands
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
Config.AdJobs = {"police", "mechanic"} -- Jobs allowed to use /ad (empty = all jobs)

-- [Doc Command]
Config.DocMaxCount = 50         -- Maximum count for /doc command

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

-- [Communication Commands]
Config.CommandMsg = 'msg'                  -- /msg - private message
Config.CommandAd = 'ad'                    -- /ad - advertisement
Config.CommandTwt = 'twt'                  -- /twt - twitter
Config.CommandAnnouncement = 'announcement' -- /announcement - server announcement

-- [Job Commands]
Config.CommandLspd = 'lspd'                -- /lspd - police chat
Config.CommandLssd = 'lssd'                -- /lssd - sheriff chat
Config.CommandEms = 'ems'                  -- /ems - ambulance chat

-- [Staff Commands]
Config.CommandStaff = 'staff'              -- /staff - staff chat
Config.CommandOocstaff = 'oocstaff'        -- /oocstaff - OOC staff chat

-- [DrawText Settings]
Config.DrawTextDistance = 20       -- Distance for DrawText visibility
Config.MeDrawText = true           -- true/false DrawText for /me
Config.DoDrawText = true           -- true/false DrawText for /do


-- [DrawText Colors] 
Config.MeDrawTextColor   = {168, 96, 202, 255}    -- Purple
Config.DoDrawTextColor   = {0, 169, 211, 255}    -- Light Blue / Cyan
Config.StavDrawTextColor = {255, 230, 0, 255}    -- Yellow
Config.ZdeDrawTextColor  = {255, 230, 0, 255}    -- Yellow
Config.DocDrawTextColor  = {255, 255, 255, 255}    -- White

-- [DrawText Background Colors]
Config.MeDrawTextBgColor = {0, 0, 0, 100}         -- Background for /me 
Config.DoDrawTextBgColor = {0, 0, 0, 100}         -- Background for /do 
Config.DocDrawTextBgColor = {0, 0, 0, 100}        -- Background for /doc 

-- [Chat Message Colors]
Config.ChatBackgroundColor = {10, 10, 10, 0.4} -- Chat background color 
Config.MeColor = {168, 96, 202}              -- Purple
Config.DoColor = {0, 169, 211}               -- Light Blue / Cyan
Config.SheriffColor = {255, 165, 0}          -- Orange
Config.PoliceColor = {0, 102, 255}           -- Blue
Config.AmbulanceColor = {255, 0, 0}          -- Red
Config.AdColor = {255, 215, 0}               -- Gold
Config.AnnouncementColor = {255, 0, 0}       -- Red
Config.TwtColor = {29, 161, 242}             -- Twitter Blue
Config.StaffColor = {255, 165, 0}            -- Orange
Config.OocStaffColor = {128, 128, 128}       -- Gray
Config.TrySuccessColor = {0, 180, 0} -- Darker Green
Config.TryFailColor = {180, 0, 0} -- Darker Red

-- [DrawText Offsets]
Config.MeDrawTextOffset = 1.1        -- Z offset for /me DrawText (on foot)
Config.MeDrawTextOffsetVehicle = 0.7 -- Z offset for /me DrawText (in vehicle)
Config.DoDrawTextOffset = 1.1       -- Z offset for /do DrawText (on foot)
Config.DoDrawTextOffsetVehicle = 0.7 -- Z offset for /do DrawText (in vehicle)
Config.DocDrawTextOffset = 1.1       -- Z offset for /doc DrawText

-- [VIP System]
Config.VIPSystem = false -- If false, VIP system is disabled
Config.VIPLicenses = {
    "license", -- Example license
   -- "license" 
}

