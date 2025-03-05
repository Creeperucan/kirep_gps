fx_version 'cerulean'
game 'gta5'
lua54 'on'

name 'kirep-gps'
author 'Creeperucan'
description 'The most advanced GPS script! By Creeperucan :)'
version '1.0.1'

client_scripts {
  'client/*',
  'functions.lua'
}
server_scripts {
  'server/*',
  'functions.lua'
}

dependencies {
  'ox_lib',
  'screenshot-basic',
  'ox_inventory',
  'fmsdk'
}

ui_page 'html/index.html'

shared_scripts {
  'config.lua',
  'blipConfig.lua'
}

files {
    'html/*',
    'locales/*'
}