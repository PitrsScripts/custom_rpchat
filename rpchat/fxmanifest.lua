fx_version 'cerulean'
game 'gta5'
author 'Pitrs'
description 'ESX RPCHAT'
version '1.0'

lua54 'yes' 

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'@ox_lib/init.lua', 
}

server_scripts {
	'@async/async.lua',
	'server/*.lua',
}

client_scripts {
	'client/*.lua',
}

despencies {
    'ox_lib',
    'oxmysql',
    'es_extended',
    'async',
}






