Config = {}

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
        ["doc"] = 16777215 -- ⚪ White for /doc
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
    ["me"] = 'https://discord.com/api/webhooks/1367677678978859050/-OMRvaKqBSeQTz8Jm53m37lzh42UzvjuDD4XPbKou9YticvDMBGlWJVq2MyWbTLrhQHr',
    ["do"] = 'https://discord.com/api/webhooks/1319444993294864394/nnxFQJqaYKdSbD0y9HxtwXMJ_a72ohaHeqzS7QS3qF3NjInWxKOhoMybVnNWdtXDz5Ch',
    ["ooc"] = 'https://discord.com/api/webhooks/1309288002714865725/FTP7-1Vy_U4rreOoDzFGW8CVh3y7KyjuC2xdrx6G1mlh3VUIPBWBaPnctZ7-FTeh23ll',
    ["try"] = 'https://discord.com/api/webhooks/1367687968940363826/eRY4xY_va6b2xBrNb_RUXcXp0U5Sghf8Ark-au7JStxXudUWo9UKM7Zt3_7-m-GhZ06L',
    ["doc"] = 'https://discord.com/api/webhooks/1319445152015581335/0O2mZqoDv9hnbfNIzWylMO2BQbXGK8eT7Ax5NU38-C_yB-sCCWsyPd_92cOA8-rAY7hA',
    ["msg"] = 'https://discordapp.com/api/webhooks/1322049028094951544/be7a2SvMciz9HJn8TMG7UYTZ5jPl5i56D_AB_JELkBWeBaQL5A_W7b9HkpJKTpflktin'
}

-- 👥 PERMISSIONS - ALLOWED GROUPS
Config.AllowedGroups = {
    admin = true,
    moderator = true,
    superadmin = true
}

-- 💬 CHAT COMMANDS TOGGLE
Config.OocCommand = true           -- Enables /ooc
Config.MeCommand = true            -- Enables /me
Config.DoCommand = true            -- Enables /do
Config.AnnouncementsCommand = true -- Enables /announcements
Config.MsgCommand = true           -- Enables /msg
Config.SheriffCommand = true       -- Enables /sheriff

-- 🧾 CHAT DISPLAY OPTIONS
Config.firstname = false -- Show only first name
Config.lastname = false  -- Show only last name
Config.job = false       -- Show only job name (label)

-- 🚓 JOB NAMES (for job-specific features)
Config.ambulance = 'ambulance'
Config.sheriff = 'sheriff'
Config.police = 'police'
