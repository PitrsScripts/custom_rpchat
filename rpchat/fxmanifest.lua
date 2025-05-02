fx_version 'cerulean'
game 'gta5'
author 'Pitrs'
description 'ESX RPCHAT'
version '1.0'

lua54 'yes' 

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua', 
}

server_scripts {
	'server/*.lua',
}

client_scripts {
	'client/*.lua',
}




