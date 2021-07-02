ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
    end
end)

local allowed = false
local StaffMod = false
local NoClip = false
local NoClipSpeed = 1.0
local invisible = false
local PlayerInZone = 0
local ShowName = false
local gamerTags = {}
local pBlips = {}
local armor = 0
local GetOnscreenKeyboardResult = GetOnscreenKeyboardResult
local modestaff = false

local info = {
    NOCLIP = {"Activer/Désactiver le NoClip", 118},
    INVISIBLE = {"Activer/Désactiver l'invisibilité", 111},
    NOM = {"Activer/Désactiver les noms", 117},
    COULEUR = {"Changer de couleur", 124},
}

-- Notification radar
function ShowAboveRadarMessage(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(0, 1)
end
RegisterNetEvent('showNotify')
AddEventHandler('showNotify', function(notify)
    ShowAboveRadarMessage(notify)
end)

-- Commande staffmod
RegisterCommand("staffmod", function(source, args, rawCommand)
    ESX.TriggerServerCallback('lwz-staffmod:getUsergroup', function(group)
        playergroup = group
        if playergroup ~= "user" then
            if not StaffMod then
                StaffMod = true
                local couleur = math.random(0,9)
                local model = GetEntityModel(GetPlayerPed(-1))
                armor = GetPedArmour(GetPlayerPed(-1))
                TriggerEvent('skinchanger:getSkin', function(skin)
                    if model == GetHashKey("mp_m_freemode_01") then
                        clothesSkin = {
                            ['bags_1'] = 0, ['bags_2'] = 0,
                            ['tshirt_1'] = 15, ['tshirt_2'] = 2,
                            ['torso_1'] = 178, ['torso_2'] = couleur,
                            ['arms'] = 31,
                            ['pants_1'] = 77, ['pants_2'] = couleur,
                            ['shoes_1'] = 55, ['shoes_2'] = couleur,
                            ['mask_1'] = 0, ['mask_2'] = 0,
                            ['bproof_1'] = 0,
                            ['chain_1'] = 0,
                            ['helmet_1'] = 91, ['helmet_2'] = couleur,
                        }
                    else
                        clothesSkin = {
                            ['bags_1'] = 0, ['bags_2'] = 0,
                            ['tshirt_1'] = 31, ['tshirt_2'] = 0,
                            ['torso_1'] = 180, ['torso_2'] = couleur,
                            ['arms'] = 36, ['arms_2'] = 0,
                            ['pants_1'] = 79, ['pants_2'] = couleur,
                            ['shoes_1'] = 58, ['shoes_2'] = couleur,
                            ['mask_1'] = 0, ['mask_2'] = 0,
                            ['bproof_1'] = 0,
                            ['chain_1'] = 0,
                            ['helmet_1'] = 90, ['helmet_2'] = couleur,
                        }
                    end
                    TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
                end)
            else
                StaffMod = false
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                    local isMale = skin.sex == 0
                    TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
                        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                            TriggerEvent('skinchanger:loadSkin', skin)
                            TriggerEvent('esx:restoreLoadout')
                        end)
                    end)
                end)
                SetPedArmour(GetPlayerPed(-1), armor)

                FreezeEntityPosition(GetPlayerPed(-1), false)
                NoClip = false

                SetEntityVisible(GetPlayerPed(-1), 1, 0)
                NetworkSetEntityInvisibleToNetwork(GetPlayerPed(-1), 0)

                for _, v in pairs(GetActivePlayers()) do
                    RemoveMpGamerTag(gamerTags[v])
                end

                for k,v in pairs(pBlips) do
                    RemoveBlip(v)
                end
            end
        end
    end)
end, false)

Citizen.CreateThread(function()
    AddTextEntry("NOCLIP", info['NOCLIP'][1])
    AddTextEntry("INVISIBLE", info['INVISIBLE'][1])
    AddTextEntry("NOM", info['NOM'][1])
    AddTextEntry("COULEUR", info['COULEUR'][1])
end)

local pPed = GetPlayerPed(-1)
Citizen.CreateThread(function()
    while StaffMod do
        Citizen.Wait(5000)
        pPed = GetPlayerPed(-1)
        if StaffMod then
            local players = GetActivePlayers()
            for k,v in pairs(pBlips) do
                RemoveBlip(v)
            end
            for k,v in pairs(players) do
                local ped = GetPlayerPed(v)
                local blip = AddBlipForEntity(ped)
                table.insert(pBlips, blip)
                SetBlipScale(blip, 0.85)
                if IsPedOnAnyBike(ped) then
                    SetBlipSprite(blip, 226)
                elseif IsPedInAnyHeli(ped) then
                    SetBlipSprite(blip, 422)
                elseif IsPedInAnyPlane(ped) then
                    SetBlipSprite(blip, 307)
                elseif IsPedInAnyVehicle(ped, false) then
                    SetBlipSprite(blip, 523)
                else
                    SetBlipSprite(blip, 1)
                end

                if IsPedInAnyPoliceVehicle(ped) then
                    SetBlipSprite(blip, 56)
                    SetBlipColour(blip, 3)
                end
                SetBlipRotation(blip, math.ceil(GetEntityHeading(ped)))
            end
        end
    end
end)

--
-- Developped by lwz#2051
--

Citizen.CreateThread(function()
    local attente = 500
    while StaffMod do
        Wait(attente)
        if StaffMod then
            attente = 1
            if IsControlJustReleased(1, 118) then
                if not NoClip then
                    FreezeEntityPosition(GetPlayerPed(-1), true)
                    NoClip = true
                else
                    FreezeEntityPosition(GetPlayerPed(-1), false)
                    SetEntityCollision(pPed, 1, 1)
                    NoClip = false
                end
            end

            if NoClip then
                local pCoords = GetEntityCoords(pPed, false)
                local camCoords = getCamDirection()
                SetEntityVelocity(pPed, 0.01, 0.01, 0.01)
                SetEntityCollision(pPed, 0, 1)
            
                if IsControlPressed(0, 32) then
                    pCoords = pCoords + (NoClipSpeed * camCoords)
                end
            
                if IsControlPressed(0, 269) then
                    pCoords = pCoords - (NoClipSpeed * camCoords)
                end

                if IsControlPressed(1, 10) then
                    NoClipSpeed = NoClipSpeed + 0.5
                end
                if IsControlPressed(1, 11) then
                    NoClipSpeed = NoClipSpeed - 0.5
                    if NoClipSpeed < 0 then
                        NoClipSpeed = 0
                    end
                end
                SetEntityCoordsNoOffset(pPed, pCoords, true, true, true)
            end

            if IsControlJustReleased(1, 111) then
                if not invisible then
                    invisible = true
                else
                    invisible = false
                end
            end

            if invisible then
                SetEntityVisible(pPed, 0, 0)
                NetworkSetEntityInvisibleToNetwork(pPed, 1)
            else
                SetEntityVisible(pPed, 1, 0)
                NetworkSetEntityInvisibleToNetwork(pPed, 0)
            end

            if IsControlJustReleased(1, 117) then
                if not ShowName then
                    ShowName = true
                else
                    ShowName = false
                end
            end

            if ShowName then
                local pCoords = GetEntityCoords(pPed, false)
                for _, v in pairs(GetActivePlayers()) do
                    local otherPed = GetPlayerPed(v)
                
                    if otherPed ~= pPed then
                        if #(pCoords - GetEntityCoords(otherPed, false)) < 250.0 then
                            gamerTags[v] = CreateFakeMpGamerTag(otherPed, ('[%s] %s'):format(GetPlayerServerId(v), GetPlayerName(v)), false, false, '', 0)
                            SetMpGamerTagVisibility(gamerTags[v], 4, 1)
                        else
                            RemoveMpGamerTag(gamerTags[v])
                            gamerTags[v] = nil
                        end
                    end
                end
            else
                for _, v in pairs(GetActivePlayers()) do
                    RemoveMpGamerTag(gamerTags[v])
                end
            end

            for k,v in pairs(GetActivePlayers()) do
                if NetworkIsPlayerTalking(v) then
                    local pPed = GetPlayerPed(v)
                    local pCoords = GetEntityCoords(pPed)
                    DrawMarker(0, pCoords.x, pCoords.y, pCoords.z+1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 255, 0, 170, 0, 1, 2, 0, nil, nil, 0)
                end
            end

            if IsControlJustReleased(1, 124) then
                local couleur = math.random(0,9)
                TriggerEvent('skinchanger:getSkin', function(skin)
                    local clothesSkin = {
                        ['torso_2'] = couleur,
                        ['pants_2'] = couleur,
                        ['shoes_2'] = couleur,
                        ['helmet_2'] = couleur,
                    }
                    TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
                end)
            end

            SetInstructionalButton("NOCLIP", info['NOCLIP'][2], true)
            SetInstructionalButton("INVISIBLE", info['INVISIBLE'][2], true)
            SetInstructionalButton("NOM", info['NOM'][2], true)
            SetInstructionalButton("COULEUR", info['COULEUR'][2], true)
        else
            SetInstructionalButton("NOCLIP", info['NOCLIP'][2], false)
            SetInstructionalButton("INVISIBLE", info['INVISIBLE'][2], false)
            SetInstructionalButton("NOM", info['NOM'][2], false)
            SetInstructionalButton("COULEUR", info['COULEUR'][2], false)
            attente = 500
        end
    end
end)

-- Récupération de tous les joueurs connectés
local ServersIdSession = {}
Citizen.CreateThread(function()
    while true do
        Wait(500)
        for k,v in pairs(GetActivePlayers()) do
            local found = false
            for _,j in pairs(ServersIdSession) do
                if GetPlayerServerId(v) == j then
                    found = true
                end
            end
            if not found then
                table.insert(ServersIdSession, GetPlayerServerId(v))
            end
        end
    end
end)


-- Déclaration des menus et sous menus
RMenu.Add('STAFF', 'main', RageUI.CreateMenu("Menu Staff", " "))
RMenu:Get('STAFF', 'main'):SetSubtitle("Actions disponibles")
RMenu:Get('STAFF', 'main').EnableMouse = false
RMenu:Get('STAFF', 'main').Closed = function()
end;

RMenu.Add('STAFF', 'joueurs', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'main'), "Liste des joueurs", "Actions disponibles"))
RMenu.Add('STAFF', 'vehicules', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'main'), "Liste des véhicules", "Actions disponibles"))
RMenu.Add('STAFF', 'actionsjoueurs', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joueurs'), "Liste des joueurs", "Actions disponibles"))
RMenu.Add('STAFF', 'monde', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'main'), "Options mondes", "Actions disponibles"))

-- Armes
RMenu.Add('STAFF', 'armescat', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'actionsjoueurs'), "Catégories des armes", "Actions disponibles"))
RMenu.Add('STAFF', 'armesmelees', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'armescat'), "Liste : armes de mélées", "Actions disponibles"))
RMenu.Add('STAFF', 'armeshandguns', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'armescat'), "Liste : armes de poing", "Actions disponibles"))
RMenu.Add('STAFF', 'armessubmac', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'armescat'), "Liste : mitraillettes", "Actions disponibles"))
RMenu.Add('STAFF', 'armeslightmac', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'armescat'), "Liste : mitrailleuses", "Actions disponibles"))
RMenu.Add('STAFF', 'armesfa', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'armescat'), "Liste : fusils d'assaut", "Actions disponibles"))
RMenu.Add('STAFF', 'armessniper', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'armescat'), "Liste : fusil à lunettes", "Actions disponibles"))
RMenu.Add('STAFF', 'armesjetables', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'armescat'), "Liste : jetables", "Actions disponibles"))
RMenu.Add('STAFF', 'armesdivers', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'armescat'), "Liste : divers", "Actions disponibles"))

-- Items
RMenu.Add('STAFF', 'itemlist', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'actionsjoueurs'), "Catégories des items", "Actions disponibles"))
RMenu.Add('STAFF', 'itemsmecano', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'itemlist'), "Liste : mécano", "Actions disponibles"))
RMenu.Add('STAFF', 'itemsems', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'itemlist'), "Liste : EMS", "Actions disponibles"))
RMenu.Add('STAFF', 'itemsltd247', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'itemlist'), "Liste : magasins", "Actions disponibles"))
RMenu.Add('STAFF', 'itemsvigneron', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'itemlist'), "Liste : vigneron", "Actions disponibles"))
RMenu.Add('STAFF', 'itemsorpailleur', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'itemlist'), "Liste : orpailleur", "Actions disponibles"))
RMenu.Add('STAFF', 'itemstabac', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'itemlist'), "Liste : orpailleur", "Actions disponibles"))
RMenu.Add('STAFF', 'itemsunicorn', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'itemlist'), "Liste : unicorn", "Actions disponibles"))
RMenu.Add('STAFF', 'itemsvip', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'itemlist'), "Liste : VIP", "Actions disponibles"))
RMenu.Add('STAFF', 'itemsdrogues', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'itemlist'), "Liste : drogues", "Actions disponibles"))

-- Jobs
RMenu.Add('STAFF', 'joblist', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'actionsjoueurs'), "Liste des jobs", "Actions disponibles"))
RMenu.Add('STAFF', 'jobslspd', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joblist'), "LSPD", "Actions disponibles"))
RMenu.Add('STAFF', 'jobsems', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joblist'), "EMS", "Actions disponibles"))
RMenu.Add('STAFF', 'jobsconcess', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joblist'), "Concessionnaire Auto", "Actions disponibles"))
RMenu.Add('STAFF', 'jobsmecano', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joblist'), "Mécano", "Actions disponibles"))
RMenu.Add('STAFF', 'jobsconcess2', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joblist'), "Concessionnaire Moto", "Actions disponibles"))
RMenu.Add('STAFF', 'jobsagentimmo', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joblist'), "Agent Immobilier", "Actions disponibles"))
RMenu.Add('STAFF', 'jobsorpa', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joblist'), "Orpailleur", "Actions disponibles"))
RMenu.Add('STAFF', 'jobstabac', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joblist'), "Tabac", "Actions disponibles"))
RMenu.Add('STAFF', 'jobsvigne', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joblist'), "Vigneron", "Actions disponibles"))
RMenu.Add('STAFF', 'jobsblanchi', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joblist'), "Blanchisseur", "Actions disponibles"))
RMenu.Add('STAFF', 'jobschomeur', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joblist'), "Chômeur", "Actions disponibles"))

-- Véhicules
RMenu.Add('STAFF', 'spawnveh', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'vehicules'), "Catégorie des véhicules", "Actions disponibles"))

-- Sanction
RMenu.Add('STAFF', 'sanction', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joueurs'), "Sanctionner", "Actions disponibles"))

-- Kick
RMenu.Add('STAFF', 'expulser', RageUI.CreateSubMenu(RMenu:Get('STAFF', 'joueurs'), "Expulser", "Actions disponibles"))

-- Liste du contenu des menus
local MenuType = {
    "Réanimer",
    "Téléporter sur moi",
    "Téléporter sur lui",
}
local WarnType = {
    "Freekill",
    "Provocation inutile (ForceRP)",
    "HRP vocal",
    "Conduite HRP",
    "NoFear",
    "NoPain",
    "Parle coma",
    "Troll",
    "Powergaming",
    "Insultes",
    "Non respect du staff",
    "Metagaming",
    "ForceRP",
    "Freeshoot",
    "Freepunch",
    "Tire en zone safe",
    "Non respect du masse RP",
    "Rentre dans les quartiers",
    "Vol de véhicule en zone safe",
    "Vol de véhicule de fonction",
    "Autre (Entrer une raison)",
}
local KickType = {
	"Troll",
	"NoFear",
	"NoPain",
	"Insultes",
	"HRP",
	"AFK",
	"Autre (Entrer la raison)",
}

-- Liste armes
local ArmeMeleeType = {
	"weapon_unarmed",
    "weapon_dagger",
    "weapon_bat",
    "weapon_bottle",
    "weapon_crowbar",
    "weapon_flashlight",
	"weapon_golfclub",
    "weapon_hammer",
    "weapon_hatchet",
	"weapon_knuckle",
	"weapon_knife",
	"weapon_machete",
	"weapon_switchblade",
	"weapon_nightstick",
	"weapon_wrench",
	"weapon_battleaxe",
	"weapon_poolcue",
	"weapon_stone_hatchet",
}
local ArmeHandgunsType = {
	"weapon_pistol",
    "weapon_pistol_mk2",
    "weapon_combatpistol",
    "weapon_appistol",
    "weapon_stungun",
    "weapon_pistol50",
	"weapon_snspistol",
    "weapon_snspistol_mk2",
    "weapon_heavypistol",
	"weapon_vintagepistol",
	"weapon_flaregun",
	"weapon_marksmanpistol",
	"weapon_revolver",
	"weapon_revolver_mk2",
	"weapon_doubleaction",
	"weapon_ceramicpistol",
	"weapon_navyrevolver",
}
local ArmeSubMachineType = {
	"weapon_microsmg",
    "weapon_smg",
    "weapon_smg_mk2",
    "weapon_assaultsmg",
    "weapon_combatpdw",
    "weapon_machinepistol",
	"weapon_minismg",
    "weapon_raycarbine",
}
local ArmeLightMachineType = {
	"weapon_mg",
    "weapon_combatmg",
    "weapon_combatmg_mk2",
    "weapon_gusenberg",
}
local ArmeAssaultRifleType = {
	"weapon_assaultrifle",
    "weapon_assaultrifle_mk2",
    "weapon_carbinerifle",
    "weapon_carbinerifle_mk2",
	"weapon_advancedrifle",
    "weapon_specialcarbine",
    "weapon_specialcarbine_mk2",
    "weapon_bullpuprifle",
	"weapon_bullpuprifle_mk2",
	"weapon_compactrifle",
}
local ArmeSniperType = {
	"weapon_sniperrifle",
    "weapon_heavysniper",
    "weapon_marksmanrifle",
}

local ArmeJetableType = {
	"weapon_smokegrenade",
	"weapon_flare",
}
local ArmeDiversType = {
	"weapon_petrolcan",
    "gadget_parachute",
    "weapon_fireextinguisher",
    "weapon_hazardcan",
}

-- Liste items mécano
local ItemMecanoType = {
	"blowpipe",
	"carokit",
	"carotool",
	"fixkit",
	"fixtool",
	"gazbottle",
}
-- Liste items EMS
local ItemEMSType = {
	"bandage",
	"medikit",
}
-- Liste items LTD et 24/7
local ItemLTD247Type = {
	"bread",
	"water",
	"energy",
	"sandwich",
}
-- Liste items vigneron
local ItemVigneType = {
	"raisin",
	"vine",
	"jus_raisin",
}
-- Liste items orpailleur
local ItemOrpaType = {
	"or",
	"or_fondu",
	"lingot",
}
-- Liste items tabac
local ItemTabacType = {
	"tabac",
	"malboro",
	"spliff",
}
-- Liste items unicorn
local ItemUnicType = {
	"grand_cru",
	"icetea",
	"limonade",
	"martini",
	"mojito",
	"rhum",
	"vodka",
}
-- Liste items VIP
local ItemVIPType = {
	"gigatacos",
	"bigkingxxl",
	"steackhouse",
	"mcflurry",
	"fanta",
	"pinacolada",
	"ricard",
	"whisky",
	"silencieux",
}
-- Liste items drogues
local ItemDrogType = {
	"weed",
	"weed_pooch",
	"opium",
	"opium_pooch",
	"meth",
	"meth_pooch",
	"coke",
	"coke_pooch",
	"gilet",
	"giletlspd",
}
-- Liste des jobs
local JobLspdType = {
    {  
		job = {
            { nom = "LSPD - Recrue [0]", setjob = "police", grade = "0"},
            { nom = "LSPD - Officier [1]", setjob = "police", grade = "1"},
            { nom = "LSPD - Sergent [2]", setjob = "police", grade = "2"},
            { nom = "LSPD - Lieutenant [3]", setjob = "police", grade = "3"},
            { nom = "LSPD - Commandant [4]", setjob = "police", grade = "4"},
        },
    },
}
local JobEmsType = {
    {  
		job = {
            { nom = "EMS - Ambulancier [0]", setjob = "ambulance", grade = "0"},
            { nom = "EMS - Médecin-Chef [1]", setjob = "ambulance", grade = "1"},
            { nom = "EMS - Chirurgien [2]", setjob = "ambulance", grade = "2"},
        },
    },
}
local JobConcessType = {
    {  
		job = {
            { nom = "Concessionnaire - Recrue [0]", setjob = "cardealer", grade = "0"},
            { nom = "Concessionnaire - Novice [1]", setjob = "cardealer", grade = "1"},
            { nom = "Concessionnaire - Experimente [2]", setjob = "cardealer", grade = "2"},
            { nom = "Concessionnaire - Patron [3]", setjob = "cardealer", grade = "3"},
        },
    },
}
local JobMecaType = {
    {  
		job = {
            { nom = "Mécano - Recrue [0]", setjob = "mechanic", grade = "0"},
            { nom = "Mécano - Novice [1]", setjob = "mechanic", grade = "1"},
            { nom = "Mécano - Experimente [2]", setjob = "mechanic", grade = "2"},
            { nom = "Mécano - Chef d'équipe [3]", setjob = "mechanic", grade = "3"},
            { nom = "Mécano - Patron [4]", setjob = "mechanic", grade = "4"},
        },
    },
}
local JobConcess2Type = {
    {  
		job = {
            { nom = "Concessionnaire - Recrue [0]", setjob = "motorcycle", grade = "0"},
            { nom = "Concessionnaire - Novice [1]", setjob = "motorcycle", grade = "1"},
            { nom = "Concessionnaire - Experimenté [2]", setjob = "motorcycle", grade = "2"},
            { nom = "Concessionnaire - Patron [3]", setjob = "motorcycle", grade = "3"},
        },
    },
}
local JobAgentImmoType = {
    {  
		job = {
            { nom = "Agent Immobilier - Location [0]", setjob = "realestateagent", grade = "0"},
            { nom = "Agent Immobilier - Vendeur [1]", setjob = "realestateagent", grade = "1"},
            { nom = "Agent Immobilier - Gestion [2]", setjob = "realestateagent", grade = "2"},
            { nom = "Agent Immobilier - Patron [3]", setjob = "realestateagent", grade = "3"},
        },
    },
}
local JobOrpaType = {
    {  
		job = {
            { nom = "Orpailleur - Intérimaire [0]", setjob = "orpailleur", grade = "0"},
            { nom = "Orpailleur - Orpailleur [1]", setjob = "orpailleur", grade = "1"},
            { nom = "Orpailleur - Chef de chai [2]", setjob = "orpailleur", grade = "2"},
            { nom = "Orpailleur - Patron [3]", setjob = "orpailleur", grade = "3"},
        },
    },
}
local JobTabacType = {
    {  
		job = {
            { nom = "Tabac - Stagiaire [0]", setjob = "tabac", grade = "0"},
            { nom = "Tabac - Employé [1]", setjob = "tabac", grade = "1"},
            { nom = "Tabac - Responsable [2]", setjob = "tabac", grade = "2"},
            { nom = "Tabac - Co Patron [3]", setjob = "tabac", grade = "3"},
            { nom = "Tabac - Patron [4]", setjob = "tabac", grade = "4"},
        },
    },
}
local JobVigneType = {
    {  
		job = {
            { nom = "Vigneron - Stagiaire [0]", setjob = "vigneron", grade = "0"},
            { nom = "Vigneron - Employé [1]", setjob = "vigneron", grade = "1"},
            { nom = "Vigneron - Responsable [2]", setjob = "vigneron", grade = "2"},
            { nom = "Vigneron - Patron [3]", setjob = "vigneron", grade = "3"},
        },
    },
}
local JobChomeurType = {
    {  
		job = {
            { nom = "Chômeur - Unemployed [0]", setjob = "unemployed", grade = "0"},
        },
    },
}

-- Function pour la box 
local function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return result
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end

-- Spawn vehicule
local function admin_vehspawn(vehicle)
	local plyPed = PlayerPedId()
	local PlayerInCar = GetVehiclePedIsIn(plyPed, false)
	
	ESX.Game.SpawnVehicle(vehicle, GetEntityCoords(plyPed), GetEntityHeading(plyPed), function(vehicle)
		TaskWarpPedIntoVehicle(plyPed, vehicle, -1)
	end)
end

local Menu = {
	check = false
}

local IdSelected = 0
RageUI.CreateWhile(1.0, function()
    if not StaffMod then Wait(500) end
    if RageUI.Visible(RMenu:Get('STAFF', 'main')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()			
			RageUI.Checkbox("Activer le mode staff", false, Menu.check, {Style = RageUI.CheckboxStyle.Tick}, function(Hovered, Active, Selected, Checked)
				if Checked then
					modestaff = true
				else
					modestaff = false
				end
				if Selected then
					if modestaff == true then
						TriggerServerEvent('lwz-staffmod:logsms2')
					else
						TriggerServerEvent('lwz-staffmod:logsms3')
					end
				end
				Menu.check = Checked;
			end)		
			if modestaff == true then
				RageUI.Button("Joueurs", false, { RightBadge = 16 }, true, function(Hovered, Active, Selected)
				end, RMenu:Get('STAFF', 'joueurs'))
				RageUI.Button("Véhicules", false, { RightBadge = 13 }, true, function(Hovered, Active, Selected) --13 = car
				end, RMenu:Get('STAFF', 'vehicules'))
				RageUI.Button("Monde", false, { RightBadge = 20 }, true, function(Hovered, Active, Selected)
				end, RMenu:Get('STAFF', 'monde'))
			end

        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'vehicules')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			RageUI.Button("Spawn avec le nom", false, { RightBadge = 13}, true, function(Hovered, Active, Selected)
				if Selected then
					AddTextEntry("Nom du véhicule", "Nom du véhicule")
                    DisplayOnscreenKeyboard(1, "Nom du véhicule", 'Nom du véhicule', "", '', '', '', 75)
                        
                    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
						Citizen.Wait(0)
                    end
                        
                    if UpdateOnscreenKeyboard() ~= 2 then
						vehicle = GetOnscreenKeyboardResult()
                        Citizen.Wait(1)
                    else
                        Citizen.Wait(1)
                    end
					admin_vehspawn(vehicle)
					TriggerServerEvent('lwz-staffmod:logspawnveh', vehicle)
				end
            end)
			RageUI.Button("Réparer le véhicule", false, { RightBadge = 13}, true, function(Hovered, Active, Selected)
                    if Active then
                        local veh = ESX.Game.GetClosestVehicle(GetEntityCoords(GetPlayerPed(-1)))
                        local vCoords = GetEntityCoords(veh)
                        if pVeh ~= veh then
                            DrawMarker(0, vCoords.x, vCoords.y, vCoords.z+2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 3, 252, 7, 255, 1, 0, 0, 1, nil, nil, 0)
                        end
                    end
                    if Selected then
                        local vehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(GetPlayerPed(-1)))
                        local entity = vehicle
						local model = GetEntityModel(entity)
						local veh2 = GetDisplayNameFromVehicleModel(model)
                        NetworkRequestControlOfEntity(entity)                       
						SetVehicleFixed(entity)
						TriggerServerEvent('lwz-staffmod:logrepairveh', veh2)
                    end
                end)
			RageUI.Button("Supprimer le véhicule", false, { RightBadge = 13}, true, function(Hovered, Active, Selected)
                    if Active then
                        local veh = ESX.Game.GetClosestVehicle(GetEntityCoords(GetPlayerPed(-1)))
                        local vCoords = GetEntityCoords(veh)
                        if pVeh ~= veh then
                            DrawMarker(0, vCoords.x, vCoords.y, vCoords.z+3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 3, 252, 7, 255, 1, 0, 0, 1, nil, nil, 0)
                        end
                    end
                    if Selected then
                        local vehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(GetPlayerPed(-1)))
                        local entity = vehicle
						local model = GetEntityModel(entity)
						local veh2 = GetDisplayNameFromVehicleModel(model)
                        NetworkRequestControlOfEntity(entity)       
                        Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )
                        
                        if (DoesEntityExist(entity)) then 
                            TriggerServerEvent("DeleteEntity", NetworkGetNetworkIdFromEntity(entity))
                            DeleteEntity(entity)
                        end
                        TriggerServerEvent('lwz-staffmod:logdelveh', veh2)
                    end
                end)
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'monde')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			RageUI.Button("Nettoyer la rue (PNJ)", false, { RightBadge = 13}, true, function(Hovered, Active, Selected)
				if Selected then
					ClearAreaOfPeds(GetEntityCoords(GetPlayerPed(-1)), 50.0)
				end
            end)
			RageUI.Button("Nettoyer la rue (Props)", false, { RightBadge = 13}, true, function(Hovered, Active, Selected)
                if Selected then
                    ClearAreaOfObjects(GetEntityCoords(GetPlayerPed(-1)), 50.0)
                end
            end)
			RageUI.Button("Nettoyer la rue (Tout)", false, { RightBadge = 13}, true, function(Hovered, Active, Selected)
                if Selected then
					ClearAreaOfEverything(GetEntityCoords(GetPlayerPed(-1)), 50.0, false, false, false, false)
                end
            end)
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('STAFF', 'joueurs')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            for k,v in ipairs(ServersIdSession) do
                if GetPlayerName(GetPlayerFromServerId(v)) == "**Invalid**" then table.remove(ServersIdSession, k) end
                RageUI.Button("("..v..") - "..GetPlayerName(GetPlayerFromServerId(v)), nil, {}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        IdSelected = v
                    end
				end, RMenu:Get('STAFF', 'actionsjoueurs'))
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'actionsjoueurs')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.Button("~b~("..IdSelected..") - "..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil, {}, true, function(Hovered, Active, Selected)
                if Selected then
                    
                end
            end)		
			RageUI.Button("Réanimer", nil, { RightBadge = 15 }, true, function(Hovered, Active, Selected)
				if Selected then
					TriggerServerEvent('a_ambulancejob:paintballrevive', IdSelected)
					TriggerServerEvent('lwz-staffmod:logrevive', IdSelected)
				end
			end)
			RageUI.Button("Téléporter sur moi", nil, {}, true, function(Hovered, Active, Selected)
				if Selected then
					TriggerServerEvent('a_menu:Admin_teleS', IdSelected, plyPedCoords)
					TriggerServerEvent('lwz-staffmod:logtptome', IdSelected)
				end
			end)
			RageUI.Button("Téléporter sur lui", nil, {}, true, function(Hovered, Active, Selected)
				if Selected then
					SetEntityCoords(plyPed, targetPlyCoords)
					TriggerServerEvent('lwz-staffmod:loggoto', IdSelected)
				end
			end)
			RageUI.Button("Envoyer un message", nil, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
				if Selected then
					AddTextEntry("Entrer la raison", "Entrer le message que vous voulez transmettre")
                    DisplayOnscreenKeyboard(1, "Entrer la raison", '', "", '', '', '', 128)
                    TriggerServerEvent("lwz-staffmod", IdSelected, msg)
                    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
						Citizen.Wait(0)
                    end
                    if UpdateOnscreenKeyboard() ~= 2 then
						msg = GetOnscreenKeyboardResult()
                        Citizen.Wait(1)
                    end
                    TriggerServerEvent("lwz-staffmod:SendMsgToPlayer", IdSelected, msg)
				end
			end)
			RageUI.Button("Choisir le job", false, { RightBadge = 16 }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'joblist'))
			RageUI.Button("Donner une arme", false, { RightBadge = 14 }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'armescat'))
			RageUI.Button("Donner un item", false, { RightBadge = 7 }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'itemlist'))
			RageUI.Button("Sanctionner", false, { RightBadge = 5 }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'sanction'))
			RageUI.Button("Expulser", false, { RightBadge = 22 }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('STAFF', 'expulser'))
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('STAFF', 'joblist')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			RageUI.Button("LSPD", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('STAFF', 'jobslspd'))
            RageUI.Button("EMS", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('STAFF', 'jobsems'))
            RageUI.Button("Concessionnaire Auto", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('STAFF', 'jobsconcess'))
            RageUI.Button("Mécano", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('STAFF', 'jobsmecano'))
            RageUI.Button("Concessionnaire Moto", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('STAFF', 'jobsconcess2'))
            RageUI.Button("Agent Immobilier", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('STAFF', 'jobsagentimmo'))
            RageUI.Button("Orpailleur", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('STAFF', 'jobsorpa'))
            RageUI.Button("Tabac", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('STAFF', 'jobstabac'))
            RageUI.Button("Vigneron", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('STAFF', 'jobsvigne'))
            RageUI.Button("Chômeur", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
            end, RMenu:Get('STAFF', 'jobschomeur'))
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'jobslspd')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
		for _,i in pairs(JobLspdType) do
			for _,j in pairs(i.job) do
                RageUI.Button(j.nom, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent("STAFFMOD:SetJob", IdSelected, j.setjob, j.grade)
						TriggerServerEvent('lwz-staffmod:logsetjob', IdSelected, j.setjob, j.grade)
                    end
                end)
            end
		end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('STAFF', 'jobsems')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
		for _,i in pairs(JobEmsType) do
			for _,j in pairs(i.job) do
                RageUI.Button(j.nom, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent("STAFFMOD:SetJob", IdSelected, j.setjob, j.grade)
						TriggerServerEvent('lwz-staffmod:logsetjob', IdSelected, j.setjob, j.grade)
                    end
                end)
            end
		end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('STAFF', 'jobsconcess')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
		for _,i in pairs(JobConcessType) do
			for _,j in pairs(i.job) do
                RageUI.Button(j.nom, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent("STAFFMOD:SetJob", IdSelected, j.setjob, j.grade)
						TriggerServerEvent('lwz-staffmod:logsetjob', IdSelected, j.setjob, j.grade)
                    end
                end)
            end
		end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('STAFF', 'jobsmecano')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
		for _,i in pairs(JobMecaType) do
			for _,j in pairs(i.job) do
                RageUI.Button(j.nom, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent("STAFFMOD:SetJob", IdSelected, j.setjob, j.grade)
						TriggerServerEvent('lwz-staffmod:logsetjob', IdSelected, j.setjob, j.grade)
                    end
                end)
            end
		end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('STAFF', 'jobsconcess2')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
		for _,i in pairs(JobConcess2Type) do
			for _,j in pairs(i.job) do
                RageUI.Button(j.nom, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent("STAFFMOD:SetJob", IdSelected, j.setjob, j.grade)
						TriggerServerEvent('lwz-staffmod:logsetjob', IdSelected, j.setjob, j.grade)
                    end
                end)
            end
		end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('STAFF', 'jobsagentimmo')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
		for _,i in pairs(JobAgentImmoType) do
			for _,j in pairs(i.job) do
                RageUI.Button(j.nom, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent("STAFFMOD:SetJob", IdSelected, j.setjob, j.grade)
						TriggerServerEvent('lwz-staffmod:logsetjob', IdSelected, j.setjob, j.grade)
                    end
                end)
            end
		end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('STAFF', 'jobsorpa')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
		for _,i in pairs(JobOrpaType) do
			for _,j in pairs(i.job) do
                RageUI.Button(j.nom, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent("STAFFMOD:SetJob", IdSelected, j.setjob, j.grade)
						TriggerServerEvent('lwz-staffmod:logsetjob', IdSelected, j.setjob, j.grade)
                    end
                end)
            end
		end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('STAFF', 'jobstabac')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
		for _,i in pairs(JobTabacType) do
			for _,j in pairs(i.job) do
                RageUI.Button(j.nom, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent("STAFFMOD:SetJob", IdSelected, j.setjob, j.grade)
						TriggerServerEvent('lwz-staffmod:logsetjob', IdSelected, j.setjob, j.grade)
                    end
                end)
            end
		end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('STAFF', 'jobsvigne')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
		for _,i in pairs(JobVigneType) do
			for _,j in pairs(i.job) do
                RageUI.Button(j.nom, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent("STAFFMOD:SetJob", IdSelected, j.setjob, j.grade)
						TriggerServerEvent('lwz-staffmod:logsetjob', IdSelected, j.setjob, j.grade)
                    end
                end)
            end
		end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('STAFF', 'jobschomeur')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
		for _,i in pairs(JobChomeurType) do
			for _,j in pairs(i.job) do
                RageUI.Button(j.nom, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent("STAFFMOD:SetJob", IdSelected, j.setjob, j.grade)
						TriggerServerEvent('lwz-staffmod:logsetjob', IdSelected, j.setjob, j.grade)
                    end
                end)
            end
		end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'gradelspd')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
		for _,i in pairs(JobType) do
			for _,j in pairs(i.job) do
                RageUI.Button(j.nom, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						local grade = KeyboardInput('Grade', 'Grade','', '', 1)
						TriggerServerEvent("STAFFMOD:SetJob", IdSelected, j.setjob, grade)
						TriggerServerEvent('lwz-staffmod:logsetjob', IdSelected, j.setjob, grade)
                    end
                end)
            end
		end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'itemlist')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			RageUI.Button("LTD - 24/7", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'itemsltd247'))
            RageUI.Button("Mécano", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'itemsmecano'))
			RageUI.Button("Ambulance", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'itemsems'))
			RageUI.Button("Vigneron", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'itemsvigneron'))
			RageUI.Button("Orpailleur", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'itemsorpailleur'))
			RageUI.Button("Unicorn", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'itemsunicorn'))
			RageUI.Button("Tabac", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'itemstabac'))
			RageUI.Button("VIP", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'itemsvip'))
			RageUI.Button("Drogues", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'itemsdrogues'))
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'itemsltd247')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			for k,v in pairs(ItemLTD247Type) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						AddTextEntry("Montant", "Montant")
						DisplayOnscreenKeyboard(1, "Montant", '', "", '', '', '', 128)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(0)
						end
						if UpdateOnscreenKeyboard() ~= 2 then
							quantit = GetOnscreenKeyboardResult()
							Citizen.Wait(1)
						end
						local qr = math.floor(quantit+0)
						TriggerServerEvent('lwz-staffmod:giveitems', IdSelected, v, qr)
						TriggerServerEvent('lwz-staffmod:loggiveitems', IdSelected, v, qr)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'itemsmecano')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			for k,v in pairs(ItemMecanoType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						AddTextEntry("Montant", "Montant")
						DisplayOnscreenKeyboard(1, "Montant", '', "", '', '', '', 128)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(0)
						end
						if UpdateOnscreenKeyboard() ~= 2 then
							quantit = GetOnscreenKeyboardResult()
							Citizen.Wait(1)
						end
						local qr = math.floor(quantit+0)
						TriggerServerEvent('lwz-staffmod:giveitems', IdSelected, v, qr)
						TriggerServerEvent('lwz-staffmod:loggiveitems', IdSelected, v, qr)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'itemsems')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			for k,v in pairs(ItemEMSType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						AddTextEntry("Montant", "Montant")
						DisplayOnscreenKeyboard(1, "Montant", '', "", '', '', '', 128)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(0)
						end
						if UpdateOnscreenKeyboard() ~= 2 then
							quantit = GetOnscreenKeyboardResult()
							Citizen.Wait(1)
						end
						local qr = math.floor(quantit+0)
						TriggerServerEvent('lwz-staffmod:giveitems', IdSelected, v, qr)
						TriggerServerEvent('lwz-staffmod:loggiveitems', IdSelected, v, qr)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'itemsvigneron')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			for k,v in pairs(ItemVigneType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						AddTextEntry("Montant", "Montant")
						DisplayOnscreenKeyboard(1, "Montant", '', "", '', '', '', 128)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(0)
						end
						if UpdateOnscreenKeyboard() ~= 2 then
							quantit = GetOnscreenKeyboardResult()
							Citizen.Wait(1)
						end
						local qr = math.floor(quantit+0)
						TriggerServerEvent('lwz-staffmod:giveitems', IdSelected, v, qr)
						TriggerServerEvent('lwz-staffmod:loggiveitems', IdSelected, v, qr)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'itemsorpailleur')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			for k,v in pairs(ItemOrpaType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						AddTextEntry("Montant", "Montant")
						DisplayOnscreenKeyboard(1, "Montant", '', "", '', '', '', 128)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(0)
						end
						if UpdateOnscreenKeyboard() ~= 2 then
							quantit = GetOnscreenKeyboardResult()
							Citizen.Wait(1)
						end
						local qr = math.floor(quantit+0)
						TriggerServerEvent('lwz-staffmod:giveitems', IdSelected, v, qr)
						TriggerServerEvent('lwz-staffmod:loggiveitems', IdSelected, v, qr)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'itemsunicorn')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			for k,v in pairs(ItemUnicType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						AddTextEntry("Montant", "Montant")
						DisplayOnscreenKeyboard(1, "Montant", '', "", '', '', '', 128)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(0)
						end
						if UpdateOnscreenKeyboard() ~= 2 then
							quantit = GetOnscreenKeyboardResult()
							Citizen.Wait(1)
						end
						local qr = math.floor(quantit+0)
						TriggerServerEvent('lwz-staffmod:giveitems', IdSelected, v, qr)
						TriggerServerEvent('lwz-staffmod:loggiveitems', IdSelected, v, qr)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'itemstabac')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			for k,v in pairs(ItemTabacType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						AddTextEntry("Montant", "Montant")
						DisplayOnscreenKeyboard(1, "Montant", '', "", '', '', '', 128)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(0)
						end
						if UpdateOnscreenKeyboard() ~= 2 then
							quantit = GetOnscreenKeyboardResult()
							Citizen.Wait(1)
						end
						local qr = math.floor(quantit+0)
						TriggerServerEvent('lwz-staffmod:giveitems', IdSelected, v, qr)
						TriggerServerEvent('lwz-staffmod:loggiveitems', IdSelected, v, qr)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'itemsvip')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			for k,v in pairs(ItemVIPType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						AddTextEntry("Montant", "Montant")
						DisplayOnscreenKeyboard(1, "Montant", '', "", '', '', '', 128)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(0)
						end
						if UpdateOnscreenKeyboard() ~= 2 then
							quantit = GetOnscreenKeyboardResult()
							Citizen.Wait(1)
						end
						local qr = math.floor(quantit+0)
						TriggerServerEvent('lwz-staffmod:giveitems', IdSelected, v, qr)
						TriggerServerEvent('lwz-staffmod:loggiveitems', IdSelected, v, qr)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'itemsdrogues')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
			for k,v in pairs(ItemDrogType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						AddTextEntry("Montant", "Montant")
						DisplayOnscreenKeyboard(1, "Montant", '', "", '', '', '', 128)
						while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
							Citizen.Wait(0)
						end
						if UpdateOnscreenKeyboard() ~= 2 then
							quantit = GetOnscreenKeyboardResult()
							Citizen.Wait(1)
						end
						local qr = math.floor(quantit+0)
						TriggerServerEvent('lwz-staffmod:giveitems', IdSelected, v, qr)
						TriggerServerEvent('lwz-staffmod:loggiveitems', IdSelected, v, qr)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'armescat')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.Button("Mélées", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'armesmelees'))
			RageUI.Button("Armes de poing", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'armeshandguns'))
			RageUI.Button("Mitraillettes", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'armessubmac'))
			RageUI.Button("Mitrailleuses", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'armeslightmac'))
			RageUI.Button("Fusils d'assaut", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'armesfa'))
			RageUI.Button("Fusils à lunettes", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'armessniper'))
			RageUI.Button("Jetables", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'armesjetables'))
			RageUI.Button("Divers", false, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
			end, RMenu:Get('STAFF', 'armesdivers'))
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'armesmelees')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.Button("~b~("..IdSelected..") - "..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil, {}, true, function(Hovered, Active, Selected)
            end)
            for k,v in pairs(ArmeMeleeType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent('lwz-staffmod:giveweapon', IdSelected, v)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'armeshandguns')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.Button("~b~("..IdSelected..") - "..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil, {}, true, function(Hovered, Active, Selected)
            end)
            for k,v in pairs(ArmeHandgunsType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent('lwz-staffmod:giveweapon', IdSelected, v)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'armessubmac')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.Button("~b~("..IdSelected..") - "..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil, {}, true, function(Hovered, Active, Selected)
            end)
            for k,v in pairs(ArmeSubMachineType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent('lwz-staffmod:giveweapon', IdSelected, v)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'armeslightmac')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.Button("~b~("..IdSelected..") - "..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil, {}, true, function(Hovered, Active, Selected)
            end)
            for k,v in pairs(ArmeLightMachineType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent('lwz-staffmod:giveweapon', IdSelected, v)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'armesfa')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.Button("~b~("..IdSelected..") - "..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil, {}, true, function(Hovered, Active, Selected)
            end)
            for k,v in pairs(ArmeAssaultRifleType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent('lwz-staffmod:giveweapon', IdSelected, v)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'armessniper')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.Button("~b~("..IdSelected..") - "..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil, {}, true, function(Hovered, Active, Selected)
            end)
            for k,v in pairs(ArmeSniperType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent('lwz-staffmod:giveweapon', IdSelected, v)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'armesjetables')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.Button("~b~("..IdSelected..") - "..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil, {}, true, function(Hovered, Active, Selected)
            end)
            for k,v in pairs(ArmeJetableType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent('lwz-staffmod:giveweapon', IdSelected, v)
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'armesdivers')) then
		local plyPed = PlayerPedId()
		local plyPedCoords = GetEntityCoords(plyPed)
		local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected)))
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.Button("~b~("..IdSelected..") - "..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil, {}, true, function(Hovered, Active, Selected)
            end)
            for k,v in pairs(ArmeDiversType) do
                RageUI.Button(v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
						TriggerServerEvent('lwz-staffmod:giveweapon', IdSelected, v)
                    end
                end)
            end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('STAFF', 'sanction')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.Button("~b~("..IdSelected..") - "..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil, {}, true, function(Hovered, Active, Selected)
            end)
            for k,v in pairs(WarnType) do
                RageUI.Button("Warn : "..v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
                        if v == "Autre (Entrer une raison)" then
                            AddTextEntry("Entrer la raison", "Entrer la raison")
                            DisplayOnscreenKeyboard(1, "Entrer la raison", '', "", '', '', '', 128)
                        
                            while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
                                Citizen.Wait(0)
                            end
                        
                            if UpdateOnscreenKeyboard() ~= 2 then
                                raison = GetOnscreenKeyboardResult()
                                Citizen.Wait(1)
                            else
                                Citizen.Wait(1)
                            end
                            TriggerServerEvent("STAFFMOD:RegisterWarn", IdSelected, raison)
							TriggerServerEvent('lwz-staffmod:logwarns', IdSelected, raison)
                        else
                            TriggerServerEvent("STAFFMOD:RegisterWarn", IdSelected, v)
							TriggerServerEvent('lwz-staffmod:logwarns', IdSelected, v)
                        end
                    end
                end)
            end
        end, function()
        end)
    end
	if RageUI.Visible(RMenu:Get('STAFF', 'expulser')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.Button("~b~("..IdSelected..") - "..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil, {}, true, function(Hovered, Active, Selected)
            end)
            for k,v in pairs(KickType) do
                RageUI.Button("Kick : "..v, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
                        if v == "Autre (Entrer la raison)" then
                            AddTextEntry("Entrer la raison", "Entrer la raison")
                            DisplayOnscreenKeyboard(1, "Entrer la raison", '', "", '', '', '', 128)
                            while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
						        Citizen.Wait(0)
                            end
                            if UpdateOnscreenKeyboard() ~= 2 then
						        raison = GetOnscreenKeyboardResult()
                                Citizen.Wait(1)
                            end
							TriggerServerEvent('lwz-staffmod:logkick', IdSelected, raison)
							Wait(100)
                            TriggerServerEvent("STAFFMOD:Kick", IdSelected, raison)
						else
							TriggerServerEvent('lwz-staffmod:logkick', IdSelected, v)
							Wait(100)
							TriggerServerEvent("STAFFMOD:Kick2", IdSelected, v)
                        end
                    end
                end)
            end
        end, function()
        end)
    end
end, 1)

-- Save des warns
RegisterNetEvent("STAFFMOD:RegisterWarn")
AddEventHandler("STAFFMOD:RegisterWarn", function(reason)
    SetAudioFlag("LoadMPData", 1)
    PlaySoundFrontend(-1, "CHARACTER_SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    ShowFreemodeMessage("WARNED", "Tu as été warn pour : "..reason, 5)
end)

function ShowFreemodeMessage(title, msg, sec)
	local scaleform = _RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')
	BeginScaleformMovieMethod(scaleform, 'SHOW_SHARD_WASTED_MP_MESSAGE')
	PushScaleformMovieMethodParameterString(title)
	PushScaleformMovieMethodParameterString(msg)
	EndScaleformMovieMethod()
	while sec > 0 do
		Citizen.Wait(1)
		sec = sec - 0.01
		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
	end
	SetScaleformMovieAsNoLongerNeeded(scaleform)
end

function _RequestScaleformMovie(movie)
	local scaleform = RequestScaleformMovie(movie)
	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(0)
	end
	return scaleform
end

function Popup(txt)
	ClearPrints()
	SetNotificationBackgroundColor(140)
	SetNotificationTextEntry("STRING")
	AddTextComponentSubstringPlayerName(txt)
	DrawNotification(false, true)
end

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(pPed)
	local pitch = GetGameplayCamRelativePitch()
	local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
	local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))
	if len ~= 0 then
		coords = coords / len
	end
	return coords
end

-- Bind du menu (cette fonction permet de pouvoir modifier la touche soit meme dans les paramètres -> configurations des touches -> fivem)
Keys.Register('F1', 'F1', 'lwzSTAFFMOD', function() 
	RageUI.CloseAll()
    if StaffMod then
        RageUI.Visible(RMenu:Get('STAFF', 'main'), not RageUI.Visible(RMenu:Get('STAFF', 'main')))
    end
end)

--
-- Developped by lwz#2051
--