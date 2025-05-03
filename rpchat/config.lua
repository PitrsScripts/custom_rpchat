Config = {}

Config.Debug = false -- true/false

Config.Blacklisted = { 
    "negr", 
    "negrik", 
    "negricek", 
    "negrice", 
    "negrum", 
    "negrove", 
    "negri", 
    "negro", 
    "negros", 
    "neg3r", 
    "n3gr", 
    "n3gro", 
    "n3gros", 
    "n3gri", 
    "n3grik", 
    "n3gricek", 
    "n3grice", 
    "n3grum", 
    "n3grove", 
    "neg*r", 
    "ne*gri", 
    "n*gro", 
    "n*grum", 
    "n3g*r", 
    "ne-gr", 
    "ne_gro", 
    "n-e-g-r", 
    "n_e_g_r", 
    "n.e.g.r", 
    "n3-g-r", 
    "n3_g_r", 
    "discord.gg", 
    "discord.com", 
    "discordapp.com", 
    "discord", 
    "d1scord", 
    "d1sc0rd", 
    "d1sc0rd.gg", 
    "d1sc-app", 
    "d!scord", 
    "d!scord.gg", 
    "d!sc-app", 
    "d.iscord", 
    "d-i-s-c-o-r-d", 
    "d_i_s_c_o_r_d", 
    "d.i.s.c.o.r.d", 
    "d1s-c0rd", 
    "d1s_c0rd", 
    "disc0rd", 
    "disc-ord", 
    "disc_ord", 
    "discordgg", 
    "discord-gg", 
    "discord_gg", 
    "dsc.gg", 
    "dscgg", 
    "d.sc.gg", 
    "ds-c.gg", 
    "ds_c.gg", 
    "ds-c_g_g", 
    "examplebadword", 
    "anotherbadword"
}

-- 🌐 DISCORD EMBED SETTINGS
Config.EmbedConfig = {
    username = "PITRS RPCHAT BOT",
    color = {
        ["me"] = 3447003, --  Blue for /me
        ["do"] = 16776960, --  Yellow for /do
        ["ooc"] = 8421504, --  Gray for /ooc
        ["try"] = {
            success = 65280,     --  Green for /try success
            failure = 16711680   --  Red for /try failure
        },
        ["doc"] = 16777215 --  White for /doc
    },
    translation = {
        player = "👤Player",
        discordNickname = "🎮Discord",
        time = "🕒Time",
        todayAt = "📅Today at",
        message = "💬Message"
    }
}


-- 🔗 DISCORD WEBHOOK URLS
Config.DiscordWebhookURLs = {
    ["me"] = 'https://discord.com/api/webhooks/1368209826269630495/BFR-HLwpi92cqxqDZLsEHsi4qO8t7eG6lTbMbZx5uWeCR2Mbv6VDHBWUYIgE0YLstILo',
    ["do"] = 'https://discord.com/api/webhooks/1368209780383944734/0OWZrk5rLq9tRaIaxp9AlrMQfaylH8Mf8am3ZJjmGTLK-QyQ1bSMf5018iBRGV6-HffG',
    ["ooc"] = 'https://discord.com/api/webhooks/1368209643548971008/saYD_Fle0eX-LXl3jePaQczjs9FSW1RU-wm6DXt3OPW_SHbGSIhgmPlI1HxoK_JPkhNv',
    ["try"] = 'https://discord.com/api/webhooks/1368209742140538982/Jazq90X2fT82lWF6v9ImqtPsU6pQo6ROtIbwKFD_tt1E7yLQQs6CkWFV6mi6poFYyP7x',
    ["doc"] = 'https://discord.com/api/webhooks/1319445152015581335/0O2mZqoDv9hnbfNIzWylMO2BQbXGK8eT7Ax5NU38-C_yB-sCCWsyPd_92cOA8-rAY7hA',
    ["msg"] = 'https://discord.com/api/webhooks/1368209703527776320/DjDJ5sG6cEKDvhrFeBNUg4EO82hUUrxb_oV7G3yYDr_UhSMoKmeIorn3DWtYvx5HKX-h',
    ["announcement"] = 'https://discord.com/api/webhooks/1368213424684793886/U-cwKAfMstasc3n-PtTKqxyLCb0e77nyQJ3zwSOu9GmF_8iuOe-mb-Pb_aOfYQHA1uWZ'
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
