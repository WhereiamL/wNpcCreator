fx_version 'cerulean'

games {"gta5", "rdr3"}

author "WhereiamL"
version '1.0.1'

lua54 'yes'

client_script "client/*.lua"
server_script "server/*.lua"
shared_scripts 	{'@es_extended/imports.lua', '@ox_lib/init.lua'}
