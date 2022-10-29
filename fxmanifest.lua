-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666"
description "fight club created for Ace by Andy"
version "1.0.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

files {
	"source/index.html",
	"source/script.js",
	"source/style.css"
}
ui_page "source/index.html"

shared_script "@ox_lib/init.lua"

server_scripts {
    "config.lua",
    "source/server.lua"
}
client_script "source/client.lua"