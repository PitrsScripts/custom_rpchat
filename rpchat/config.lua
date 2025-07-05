Config = {}


Config.Locale = "cs" -- en,cs

-- [Blacklisted World]
Config.Blacklisted = { 
 "negr"
}

-- Other config settings can be added here as needed

-- [Discord Logs]
Config.DiscordWebhookURLs = {
    ["me"] = 'https://discord.com/api/webhooks/1367677678978859050/-OMRvaKqBSeQTz8Jm53m37lzh42UzvjuDD4XPbKou9YticvDMBGlWJVq2MyWbTLrhQHr',
    ["do"] = 'https://discord.com/api/webhooks/1368206384310779975/QV7AgNbc0UnHrXrj75cD7QLpIakKHVlW3Ofxt40pUMnkqDnCZH8YlyQk9HQAA2Vxut0v',
    ["local_chat"] = 'https://discord.com/api/webhooks/1368206496512606443/6RfY6ta7xe_9rBVkGNh8fyxuGukd8YJEWGFzPHhMenfVaTt8gUejHiORYjeonA5iUZuM',
    ["try"] = 'https://discord.com/api/webhooks/1367687968940363826/eRY4xY_va6b2xBrNb_RUXcXp0U5Sghf8Ark-au7JStxXudUWo9UKM7Zt3_7-m-GhZ06L',
    ["msg"] = 'https://discord.com/api/webhooks/1384520373453852702/XssTSgnJT-KtXpYP7xWOz8d2dO04W5Uahu0nzRXVuMF50XifThX_zcO1CwyuP1UAA0b9',
    ["announcement"] = 'https://discord.com/api/webhooks/1384520457574944808/52r2_jmvRNGyW3SQWRQbwbFs1N_MlwtVVwQVTtkgLuUMMeHmqmoOR2Q8lqShZraVKgWo',
    ["lssd"] = 'https://discord.com/api/webhooks/1384526246678892544/275Z-mCfLxTUa8EaAnKsXnxe2GCjm3aXlqWWbAEDEVjie1xlOeEnraByLfnGgDNYgbdy',
    ["police"] = 'https://discord.com/api/webhooks/1384524737362919534/p9WGYw5jReUGTiLOlp6c5m55GUpwwvR-QVL8dUa60y9zxvedDELxfMU3VBdMGcFScg-S',
    ["ambulance"] = 'https://discord.com/api/webhooks/1384532942667382824/trlRtGfFxBGd9tcq0ihLJ77EniA5J45N3VYFvhLk_5T-kiMlbyyOELebjUfs6P_whMnz',
    ["doc"] = 'https://discord.com/api/webhooks/1384520523932766298/uhcL3n34tTS7Bi0j4aqweGq17MntImlguUJuW0k3v9O40PDr8sagR5iJeZhmXgQ4eOiy',
    ["staff"] = 'https://discord.com/api/webhooks/1384520590412480673/apCJN1pdgCjYCMSupMA_ksxW3nbnwQ6Si7L7F3yofPNcSQfUhiKRvlEq_VfCZMU1Ti1_'
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
Config.VIPSystem = true -- If false, VIP system is disabled
Config.VIPLicenses = {
    "c71fb5a960492ca93db1229ee72d4bedff6de23c", -- Example license
   -- "license" 
}
