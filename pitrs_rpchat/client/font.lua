Citizen.CreateThread(function()
    RegisterFontFile('pangolin')
    local fontId = RegisterFontId('Pangolin')
    print(string.format('[SvejdaScripts] Registred new font: %s',fontId))
end)
Citizen.CreateThread(function()
    RegisterFontFile('Signika')
    local fontId = RegisterFontId('Signika')
    print(string.format('[SvejdaScripts] Registred new font: %s',fontId))
end)
Citizen.CreateThread(function()
    RegisterFontFile('PermanentMarker')
    local fontId = RegisterFontId('PermanentMarker')
    print(string.format('[SvejdaScripts] Registred new font: %s',fontId))
end)
Citizen.CreateThread(function()
    RegisterFontFile('firesans') -- filename gfx without extension gfx
    fontId = RegisterFontId('Fire Sans') -- the name we put in in.xml
    print(string.format('[gdx_font] setting up font Fire Sans as ID: %s',fontId))
end)



