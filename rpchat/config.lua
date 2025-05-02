Config = {}

Config.EmbedConfig = {
    username = "PITRS RPCHAT BOT",
    color = {
        ["me"] = 3447003, -- Blue
        ["do"] = 16776960, -- Yellow
        ["ooc"] = 8421504, -- Gray
        ["try"] = {
            success = 65280, -- Green
            failure = 16711680 -- Red
        },
        ["doc"] = 16777215 -- White
    },
    translation = {
        player = "👤Player",
        discordNickname = "🎮Discord",
        time = "🕒Time",
        todayAt = "📅Today at",
        message = "💬Message"
    }
}


Config.DiscordWebhookURLs = {
    ["me"] = 'https://discord.com/api/webhooks/1367677678978859050/-OMRvaKqBSeQTz8Jm53m37lzh42UzvjuDD4XPbKou9YticvDMBGlWJVq2MyWbTLrhQHr',
    ["do"] = 'https://discord.com/api/webhooks/1319444993294864394/nnxFQJqaYKdSbD0y9HxtwXMJ_a72ohaHeqzS7QS3qF3NjInWxKOhoMybVnNWdtXDz5Ch',
    ["ooc"] = 'https://discord.com/api/webhooks/1309288002714865725/FTP7-1Vy_U4rreOoDzFGW8CVh3y7KyjuC2xdrx6G1mlh3VUIPBWBaPnctZ7-FTeh23ll',
    ["try"] = 'https://discord.com/api/webhooks/1319445206893989920/gOs9OZCKzBJBsVt5l2a9Ewd2BFYQJfO3vr-UfcGZ21FacWCN8JlaQpAqlGgFQzQuQFCP',
    ["doc"] = 'https://discord.com/api/webhooks/1319445152015581335/0O2mZqoDv9hnbfNIzWylMO2BQbXGK8eT7Ax5NU38-C_yB-sCCWsyPd_92cOA8-rAY7hA',
    ["msg"] = 'https://discordapp.com/api/webhooks/1322049028094951544/be7a2SvMciz9HJn8TMG7UYTZ5jPl5i56D_AB_JELkBWeBaQL5A_W7b9HkpJKTpflktin'
}


--GROUPS
Config.AllowedGroups = {
    admin = true,
    moderator = true,
    superadmin = true
}
--CHAT CONFIG
Config.OocCommand = true --true / false
Config.MeCommand = true --true / false
Config.DoCommand = true --true / false
Config.AnnouncementsCommand = true --true / false
Config.MsgCommand = true --true / false
Config.SheriffCommand = true --true / false
Config.firstname = false -- use only first name
Config.lastname = false -- use only last name
Config.job = false -- use only job label
--JOBS
Config.ambulance = 'ambulance' -- job name for ambulance
Config.sheriff = 'sheriff' -- job name for sheriff 
Config.police = 'police' -- job name for police 