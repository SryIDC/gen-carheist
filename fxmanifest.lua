fx_version 'cerulean'
game 'gta5' 
lua54 'yes'

author 'Gigo'
description 'NPC Hostage'
version '1.0.0'

shared_scripts {
    "config.lua",
    "@ox_lib/init.lua",
    "@qbx_core/modules/lib.lua"
}

client_scripts {
    'client.lua',
}

server_script 'server.lua'

dependencies {
    "qbx_core",
    "ox_lib"
}