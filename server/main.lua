ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local logstext = "Staffmod | Logs"
local logslogo = "https://i.imgur.com/" 

local logsms2 = "https://discord.com/api/webhooks/"
local logsms3 = "https://discord.com/api/webhooks/"
local logsrevive = "https://discord.com/api/webhooks/"
local logsbring = "https://discord.com/api/webhooks/"
local logsgoto = "https://discord.com/api/webhooks/"
local logssetjob = "https://discord.com/api/webhooks/"
local logswarns = "https://discord.com/api/webhooks/"
local logskick = "https://discord.com/api/webhooks/"
local logsvehspawn = "https://discord.com/api/webhooks/" 
local logsvehrepair = "https://discord.com/api/webhooks/"
local logsvehdel = "https://discord.com/api/webhooks/"
local logsgiveweapon = "https://discord.com/api/webhooks/"
local logsgiveitems = "https://discord.com/api/webhooks/"

-- Fonction pour avoir le group du joueur (savoir s'il est staff)
ESX.RegisterServerCallback('lwz-staffmod:getUsergroup', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local group = xPlayer.getGroup()
	print(GetPlayerName(source).." - "..group) -- Print non obligatoire (possible de l'enlever)
    cb(group)
end)

-- Message staff -> joueur
RegisterNetEvent("lwz-staffmod:SendMsgToPlayer")
AddEventHandler("lwz-staffmod:SendMsgToPlayer", function(id, msg)
    TriggerClientEvent('esx:showNotification', id, "~b~MESSAGE STAFF\n~w~"..msg)
end) 

--
-- Developped by lwz#2051
--

-- Give armes
RegisterServerEvent('lwz-staffmod:giveweapon')
AddEventHandler('lwz-staffmod:giveweapon', function(id, weapon)
	local xPlayer = ESX.GetPlayerFromId(id)
    xPlayer.addWeapon(weapon, 350)
end)

-- Give items
RegisterServerEvent('lwz-staffmod:giveitems')
AddEventHandler('lwz-staffmod:giveitems', function(id, items, quantit)
	local xPlayer = ESX.GetPlayerFromId(id)
    xPlayer.addInventoryItem(items, quantit)
end)

-- Setjob
RegisterNetEvent("STAFFMOD:SetJob")
AddEventHandler("STAFFMOD:SetJob", function(id, job, grade)
	local xPlayer = ESX.GetPlayerFromId(id)
	xPlayer.setJob(job, grade)

end)

-- Kick
RegisterNetEvent("STAFFMOD:Kick")
AddEventHandler("STAFFMOD:Kick", function(id, raison)
	DropPlayer(id, raison)
end)

RegisterNetEvent("STAFFMOD:Kick2")
AddEventHandler("STAFFMOD:Kick2", function(id, v)
	DropPlayer(id, v)
end)

-- Système de warns
local warns = {}

RegisterNetEvent("STAFFMOD:RegisterWarn")
AddEventHandler("STAFFMOD:RegisterWarn", function(id, type)
	local steam = GetPlayerIdentifier(id, 0)
	local warnsGet = 0
	local found = false
	for k,v in pairs(warns) do
		if v.id == steam then
			found = true
			warnsGet = v.warns
			table.remove(warns, k)
			break
		end
	end
	if not found then
		table.insert(warns, {
			id = steam,
			warns = 1
		})
	else
		table.insert(warns, {
			id = steam,
			warns = warnsGet + 1
		})
	end
	print(warnsGet+1)

    -- Cette partie permet de ban le joueur au bout de 3 warns, je vous laisse la décommenter si beesoin
    -- Le ban est "natif" : c'est un ban session ! Quand le serveur va reboot, il sera déban.

	-- if warnsGet+1 >= 3 then
	-- 	SessionBanPlayer(id, steam, source, type)
	-- 	DropPlayer(id, "Vous avez dépassé la limite de warn. Vous avez été kick du serveur. Merci de lire le règlement.")
	-- else
	-- 	TriggerClientEvent("STAFFMOD:RegisterWarn", id, type)
	-- end
    TriggerClientEvent("STAFFMOD:RegisterWarn", id, type) -- Et commenter celle là pour éviter les bugs
end)

local SessionBanned = {}
local SessionBanMsg = "Vous avez été banni de la session de jeux pour une accumulation de warn. Merci de lire le règlement de nouveau et d'attendre la prochaine session de jeux pour jouer de nouveau. (Nouvelle session de jeux: 6h, 12h, 20h)"

function SessionBanPlayer(id, steam, source, type)
	table.insert(SessionBanned, steam)
	WarnsLog(id, source, type, true)
	DropPlayer(id, SessionBanMsg)
end

--
-- Developped by lwz#2051
--

-- Logs staffmod (menu actif)
RegisterServerEvent('lwz-staffmod:logsms2')
AddEventHandler('lwz-staffmod:logsms2', function()
    local name = GetPlayerName(source)
    local steamhex = GetPlayerIdentifier(source)
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Mode staff activé : Menu**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logsms2, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Staffmod utilisation", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

-- Logs staffmod (menu désactivé)
RegisterServerEvent('lwz-staffmod:logsms3')
AddEventHandler('lwz-staffmod:logsms3', function()
    local name = GetPlayerName(source)
    local steamhex = GetPlayerIdentifier(source)
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Mode staff désactivé : Menu**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logsms3, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Staffmod utilisation", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

-- Logs revive
RegisterServerEvent('lwz-staffmod:logrevive')
AddEventHandler('lwz-staffmod:logrevive', function(id)
    local name = GetPlayerName(source)
	local idsource = GetPlayerIdentifier(source)
    local steamhex = GetPlayerIdentifier(source)
	local steamhex2 = GetPlayerIdentifier(id)
    local name2 = GetPlayerName(id)
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Réanimations**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."** \n\nJoueur : **("..id..")** **"..name2.."** \nSteam HEX : **"..steamhex2.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logsrevive, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Réanimations", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

-- Logs bring (téléporter sur moi)
RegisterServerEvent('lwz-staffmod:logtptome')
AddEventHandler('lwz-staffmod:logtptome', function(id)
    local name = GetPlayerName(source)
	local idsource = GetPlayerIdentifier(source)
    local steamhex = GetPlayerIdentifier(source)
	local steamhex2 = GetPlayerIdentifier(id)
    local name2 = GetPlayerName(id)
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Bring**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."** \n\nJoueur : **("..id..")** **"..name2.."** \nSteam HEX : **"..steamhex2.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logsbring, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Bring", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

-- Logs goto (téléporter sur lui)
RegisterServerEvent('lwz-staffmod:loggoto')
AddEventHandler('lwz-staffmod:loggoto', function(id)
    local name = GetPlayerName(source)
	local idsource = GetPlayerIdentifier(source)
    local steamhex = GetPlayerIdentifier(source)
	local steamhex2 = GetPlayerIdentifier(id)
    local name2 = GetPlayerName(id)
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Goto**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."** \n\nJoueur : **("..id..")** **"..name2.."** \nSteam HEX : **"..steamhex2.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logsgoto, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Goto", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

-- Logs setjob (choisir le job)
RegisterServerEvent('lwz-staffmod:logsetjob')
AddEventHandler('lwz-staffmod:logsetjob', function(id, job, grade)
    local name = GetPlayerName(source)
	local idsource = GetPlayerIdentifier(source)
    local steamhex = GetPlayerIdentifier(source)
	local steamhex2 = GetPlayerIdentifier(id)
    local name2 = GetPlayerName(id)
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Setjob**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."** \n\nJoueur : **("..id..")** **"..name2.."** \nSteam HEX : **"..steamhex2.."** \n\nJob : **"..job.."** \nGrade : **"..grade.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logssetjob, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Setjob", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

--
-- Developped by lwz#2051
--

-- Logs warns (sanctions)
RegisterServerEvent('lwz-staffmod:logwarns')
AddEventHandler('lwz-staffmod:logwarns', function(id, type)
    local name = GetPlayerName(source)
	local idsource = GetPlayerIdentifier(source)
    local steamhex = GetPlayerIdentifier(source)
	local steamhex2 = GetPlayerIdentifier(id)
    local name2 = GetPlayerName(id)
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Sanction**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."** \n\nJoueur : **("..id..")** **"..name2.."** \nSteam HEX : **"..steamhex2.."** \n\nRaison : **"..type.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logswarns, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Sanction", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

-- Logs kick (expulser)
RegisterServerEvent('lwz-staffmod:logkick')
AddEventHandler('lwz-staffmod:logkick', function(id, type)
    local name = GetPlayerName(source)
	local idsource = GetPlayerIdentifier(source)
    local steamhex = GetPlayerIdentifier(source)
	local steamhex2 = GetPlayerIdentifier(id)
    local name2 = GetPlayerName(id)
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Kick**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."** \n\nJoueur : **("..id..")** **"..name2.."** \nSteam HEX : **"..steamhex2.."** \n\nRaison : **"..type.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logskick, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Kick", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

-- Logs spawn véhicule
RegisterServerEvent('lwz-staffmod:logspawnveh')
AddEventHandler('lwz-staffmod:logspawnveh', function(vehicle)
    local name = GetPlayerName(source)
	local idsource = GetPlayerIdentifier(source)
    local steamhex = GetPlayerIdentifier(source)
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Spawn véhicule**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."**\n\nVéhicule : **"..vehicle.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logsvehspawn, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Spawn véhicule", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

--
-- Developped by lwz#2051
--

-- Logs réparation véhicule
RegisterServerEvent('lwz-staffmod:logrepairveh')
AddEventHandler('lwz-staffmod:logrepairveh', function(veh2)
    local name = GetPlayerName(source)
	local idsource = GetPlayerIdentifier(source)
    local steamhex = GetPlayerIdentifier(source)
	local car = veh2
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Réparation véhicule**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."**\n\nVéhicule : **"..car.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logsvehrepair, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Réparation véhicule", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

-- Logs suppression véhicule
RegisterServerEvent('lwz-staffmod:logdelveh')
AddEventHandler('lwz-staffmod:logdelveh', function(veh2)
    local name = GetPlayerName(source)
	local idsource = GetPlayerIdentifier(source)
    local steamhex = GetPlayerIdentifier(source)
	local car = veh2
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Suppression véhicule**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."**\n\nVéhicule : **"..car.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logsvehdel, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Suppression véhicule", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

-- Logs give armes
AddEventHandler('lwz-staffmod:giveweapon', function(id, weapon)
    local name = GetPlayerName(source)
	local idsource = GetPlayerIdentifier(source)
    local steamhex = GetPlayerIdentifier(source)
	local steamhex2 = GetPlayerIdentifier(id)
    local name2 = GetPlayerName(id)
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Give armes**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."** \n\nJoueur : **("..id..")** **"..name2.."** \nSteam HEX : **"..steamhex2.."** \n\nArme: **"..weapon.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logsgiveweapon, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Give weapon", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

-- Logs give items
AddEventHandler('lwz-staffmod:giveitems', function(id, items, quantit)
    local name = GetPlayerName(source)
	local idsource = GetPlayerIdentifier(source)
    local steamhex = GetPlayerIdentifier(source)
	local steamhex2 = GetPlayerIdentifier(id)
    local name2 = GetPlayerName(id)
    local admin = {
            {
                ["color"] = "15158332",
                ["title"] = "**Staffmod | Give items**",
                ["description"] = "Staff : **"..name.."** \nSteam HEX : **"..steamhex.."** \n\nJoueur : **("..id..")** **"..name2.."** \nSteam HEX : **"..steamhex2.."** \n\nItems : **x"..quantit.." "..items.."**",
                ["footer"] = {
                    ["text"] = logstext,
                    ["icon_url"] = logslogo,
                },
            }
        }
    
        PerformHttpRequest(logsgiveitems, function(err, text, headers) end, 'POST', json.encode({username = "Log Admin | Give items", embeds = admin}), { ['Content-Type'] = 'application/json' })
end)

--
-- Developped by lwz#2051
--