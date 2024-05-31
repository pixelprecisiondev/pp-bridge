fx_version 'cerulean'
lua54 'yes'
game 'gta5'

name 'pp-bridge'
author 'PixelPrecision'
version '1.0.1'

dependencies {
    '/server:7290',
    '/onesync',
    'ox_lib',
    'oxmysql'
}

isBridge 'true'

files {
    'client/**/*.lua',
    'server/**/*.lua',
    'init.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    --'server/events.lua',
    'server/database.lua'
}
--client_script 'client/events.lua'
shared_script 'init.lua'
