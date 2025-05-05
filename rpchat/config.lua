Config = {}

Config.Debug = false -- true/false

Config.Blacklisted = { 

}


-- 🔗 DISCORD WEBHOOK URLS
Config.DiscordWebhookURLs = {
    ["me"] = 'https://discord.com/api/webhooks/1368209826269630495/BFR-HLwpi92cqxqDZLsEHsi4qO8t7eG6lTbMbZx5uWeCR2Mbv6VDHBWUYIgE0YLstILo',
    ["do"] = 'https://discord.com/api/webhooks/1368209780383944734/0OWZrk5rLq9tRaIaxp9AlrMQfaylH8Mf8am3ZJjmGTLK-QyQ1bSMf5018iBRGV6-HffG',
    ["local_chat"] = 'https://discord.com/api/webhooks/1368209643548971008/saYD_Fle0eX-LXl3jePaQczjs9FSW1RU-wm6DXt3OPW_SHbGSIhgmPlI1HxoK_JPkhNv',
    ["try"] = 'https://discord.com/api/webhooks/1368209742140538982/Jazq90X2fT82lWF6v9ImqtPsU6pQo6ROtIbwKFD_tt1E7yLQQs6CkWFV6mi6poFYyP7x',
    ["doc"] = 'https://discord.com/api/webhooks/1319445152015581335/0O2mZqoDv9hnbfNIzWylMO2BQbXGK8eT7Ax5NU38-C_yB-sCCWsyPd_92cOA8-rAY7hA',
    ["msg"] = 'https://discord.com/api/webhooks/1368209703527776320/DjDJ5sG6cEKDvhrFeBNUg4EO82hUUrxb_oV7G3yYDr_UhSMoKmeIorn3DWtYvx5HKX-h',
    ["announcement"] = 'https://discord.com/api/webhooks/1368213424684793886/U-cwKAfMstasc3n-PtTKqxyLCb0e77nyQJ3zwSOu9GmF_8iuOe-mb-Pb_aOfYQHA1uWZ',
    ["lssd"] = 'WEBHOOK',
    ["doc"] = 'https://discord.com/api/webhooks/1368984791973888030/RT5Th6MLOlJKqA9ar7w6GdT-__WzXNWQkFy-RR39RZMJYYPmkrvacRmRrncdEJqNYqI8'
}

-- 🕒 **AUTO MESSAGES** - Automatic messages settings
Config.AutoMessages = false
Config.AutoMessageInterval = 1 -- In minutes (for testing)
Config.AutoMessagesList = { -- List of messages that will be sent randomly
    "Make sure to join our discord! discord.gg/invite",
   -- "You can use the /report command to report any problems!",
}


-- 👥 PERMISSIONS - ALLOWED GROUPS
Config.AllowedGroups = {
    admin = true,
    moderator = true,
    superadmin = true
}

-- 💬 CHAT COMMANDS TOGGLE
Config.CommandCooldown = 0         -- Cooldown Commands
Config.OocCommand = true           -- Enables /ooc
Config.MeCommand = true            -- Enables /me
Config.DoCommand = true            -- Enables /do
Config.DocCommand = true           -- Enables /doc
Config.AnnouncementsCommand = true -- Enables /announcements
Config.MsgCommand = true           -- Enables /msg
Config.SheriffCommand = true       -- Enables /sheriff

-- 🧾 CHAT DISPLAY OPTIONS
--Config.firstname = false -- Show only first name
--Config.lastname = false  -- Show only last name
--Config.job = false       -- Show only job name (label)

-- 🚓 JOB NAMES (for job-specific features)
Config.ambulance = 'ambulance'
Config.sheriff = 'sheriff'
Config.police = 'police'
