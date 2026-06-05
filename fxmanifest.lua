fx_version 'cerulean'

games { 'gta5' }

author 'WhereiamL'
description 'Framework-agnostic NPC creator (ESX / QBCore / QBox) with SQL persistence'
version '2.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/bridge.lua',
}

client_scripts {
    'client/bridge.lua',
    'client/utils.lua',
    'client/npc.lua',
    'client/placement.lua',
    'client/menu.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/bridge.lua',
    'server/database.lua',
    'server/main.lua',
}

dependencies {
    'ox_lib',
    'oxmysql',
}

provide 'wNpcCreator'
