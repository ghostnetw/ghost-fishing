fx_version 'cerulean'
game 'gta5'
lua54 'yes'

version '1.0.0'
author 'azotea-fishing (based on wasabi_fishing)'
description 'QBCore Skill Based Fishing for ox_inventory (old)'

shared_scripts { '@ox_lib/init.lua', 'configuration/*.lua' }

client_scripts { 'client/*.lua' }

server_scripts { 'server/*.lua' }

dependencies { 'ox_lib', 'qb-core', 'ox_inventory' }
