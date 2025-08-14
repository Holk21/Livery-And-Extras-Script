fx_version 'cerulean'
game 'gta5'

name 'qb-livery'
author 'ChatGPT'
description 'Simple /livery command to change current vehicle livery (supports native liveries and mod type 48).'
version '1.0.0'

client_scripts {
    'config.lua',
    'client/main.lua'
}

shared_scripts {
    '@qb-core/shared/locale.lua'
}

lua54 'yes'
