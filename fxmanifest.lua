fx_version 'cerulean'
game 'gta5'
lua54 'on'

name 'kirep-gps'
author 'Creeperucan'
description 'The most advanced GPS script! By Creeperucan :)'
version '1.0.0'

client_scripts {
  'client/main.lua',
  'functions.lua'
}
server_scripts {
  'server/main.lua',
  'functions.lua'
}

dependencies {
  'ox_lib',
  'screenshot-basic',
  'ox_inventory'
}

ui_page 'html/index.html'

shared_scripts {
  'config.lua',
  'blipConfig.lua'
}

files {

  -- HTML
    'html/index.html',
    'html/style.css',
    'html/app.js',

    -- Language
    'locales/az-AZ.lua',
    'locales/tr-TR.lua',
    'locales/en-US.lua',
    'locales/it-IT.lua',
    'locales/fr-FR.lua',
    'locales/es-ES.lua',
    'locales/el-GR.lua',
    'locales/de-DE.lua',
    'locales/ar-SA.lua',
    'locales/nl-NL.lua',
    'locales/pl-PL.lua',
    'locales/th-TH.lua',
    'locales/pt-PT.lua'
}