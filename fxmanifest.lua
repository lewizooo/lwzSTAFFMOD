fx_version 'adamant'
game 'gta5'

client_scripts {
    "src/RMenu.lua",
    "src/components/*.lua",
    "src/menu/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
}

client_scripts {
    'client/*.lua',
    'client/class/*.lua',
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "server/*.lua",
}