fx_version 'bodacious'
game 'gta5'

name "__.seerrgiioo.__"
description "quasar university - leason 8"
author "__.seerrgiioo.__"
version "1.0.0"

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js'
}

client_scripts {
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
}

shared_scripts {
    'config/config.lua',
    'locales/*.lua'
}
