local functions = LoadResourceFile('kirep-gps', 'functions.lua')

local lang = Config.General.lang
local time = Config.General.updateInterval

local deniedColor = Config.Noification.deniedColor
local deniedIcon = Config.Noification.deniedIcon
local successColor = Config.Noification.successColor
local successIcon = Config.Noification.successIcon

local playerId = PlayerId()
local ped = PlayerPedId()

local playerBlips = {}
local weBlip = {}
local playersID = nil
local badgeNumber
local jobName = ''
local hasItem = false

GPSstatus = false
Locales = {}

if functions then
    load(functions)()
end

Citizen.CreateThread(function()

    if lang == nil or lang == '' then
        print("Invalid locale in Config: " .. tostring(lang))
        return
    end
    
    LoadLocale(lang)

    local Player = GetPlayerData()
    hasItem = HasItem(Config.General.itemName)
    jobName = Player.job.name

    if Player then
        print("Player Data:", json.encode(Player))
    else
        print("GetPlayerData returned nil")
    end
end)

RegisterNUICallback('openGPS', function(data, cb)
    SetNuiFocus(false, false)

    badgeNumber = data.value

    if badgeNumber ~= '' and badgeNumber ~= ' ' then
        if GPSstatus ==  false then
            GPSstatus = true

            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            local vehicleClass = GetVehicleClass(vehicle)
            local sirenOn = tostring(IsVehicleSirenOn(vehicle))
            local playerParachute = GetPedParachuteState(ped)
            local playerId = PlayerId()

            TriggerEvent('screenshot')
            notification(getLang('sucTitle'), getLang('gpsIsOn'), successIcon, successColor)
            TriggerEvent('webhookControl', badgeNumber, 'on')
            blipSettings(0)
            cb('ok')

            while true do
                Citizen.Wait(time)

                hasItem = HasItem(Config.General.itemName)

                if GPSstatus == false then
                    break
                elseif not hasItem then
                    stopGPS(false)
                    break
                else
                    TriggerServerEvent('playerInfo', badgeNumber, vehicleClass, sirenOn, playerParachute, playerId, jobName)
                end
                
            end
        else
            notification(getLang('errTitle'), getLang('alreadyGPSOn'), deniedIcon, deniedColor)
        end
    else
        notification(getLang('errTitle'), getLang('noSpace'), deniedIcon, deniedColor)
        cb('ok')
    end
end)


RegisterNUICallback('closeGPS', function(data, cb) -- Close GPS
    SetNuiFocus(false, false)
    stopGPS(true)
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(data, cb) -- Close Menu
    cb('ok')
end)

RegisterNetEvent('gps:itemUsed') -- Item Used
AddEventHandler('gps:itemUsed', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openMenu'
    })
end)

RegisterNetEvent('gps:blipCreate') -- Blip Creating (Server Info)
AddEventHandler('gps:blipCreate', function(coords, firstName, lastName, serverPlayerName, serverBadge, vehicleClass, sirenOn, playerParachute, playerID, otherPlayerJob)

        local veh = GetVehiclePedIsIn(ped, false)
        local plrName = GetPlayerName(playerId)
        local plrParachute = GetPedParachuteState(ped)

        if GPSstatus then
            for i = #blipConfig.Jobs, 1, -1 do
                if jobName == blipConfig.Jobs[i] then

                    local job = blipConfig.Jobs[i]
                    local configJob = job.."Blips"

                    if plrName == serverPlayerName then                                                       -- Player Name Control
                        clientBlipCreate(configJob, veh, plrParachute, firstName, lastName, serverBadge)
                    elseif otherPlayerJob == blipConfig.Jobs[i] then
                        serverBlipCreate(configJob, sirenOn, vehicleClass, playerParachute, coords, firstName, lastName, serverBadge, playerID)
                end
            end
        end
    end
end)

RegisterNetEvent('webhookControl')
AddEventHandler('webhookControl', function (number, status)

    local URL = Config.Webhook.URL
    local webhookEnable = Config.Webhook.enabled

    exports['screenshot-basic']:requestScreenshotUpload(URL, 'files[]', function(data)
        if webhookEnable then
            TriggerServerEvent('discordWebhook', number, status, json.decode(data).attachments[1].proxy_url)
        end
    end)
end)

function clientBlipCreate(configJob, veh, plrParachute, firstName, lastName, serverBadge)
    if blipConfig[configJob].sirenBlip and IsVehicleSirenOn(veh) then              -- Siren Control
        clientBlip(blipConfig[configJob].sirenBlipIcon, blipConfig[configJob].sirenBlipScale, firstName, lastName, serverBadge, blipConfig[configJob].sirenBlipColor)
    elseif blipConfig[configJob].motorBlip and GetVehicleClass(veh) == 8 then      -- Motorcycle Control
        clientBlip(blipConfig[configJob].motorBlipIcon, blipConfig[configJob].motorBlipScale, firstName, lastName, serverBadge, blipConfig[configJob].motorBlipColor)
    elseif blipConfig[configJob].boatBlip and GetVehicleClass(veh) == 14 then      -- Boat Control
        clientBlip(blipConfig[configJob].boatBlipIcon, blipConfig[configJob].boatBlipScale, firstName, lastName, serverBadge, blipConfig[configJob].boatBlipColor)
    elseif blipConfig[configJob].heliBlip and GetVehicleClass(veh) == 15 then      -- Helicopter Control
        clientBlip(blipConfig[configJob].heliBlipIcon, blipConfig[configJob].heliBlipScale, firstName, lastName, serverBadge, blipConfig[configJob].heliBlipColor)
    elseif blipConfig[configJob].planeBlip and GetVehicleClass(veh) == 16 then     -- Plane Control
        clientBlip(blipConfig[configJob].planeBlipIcon, blipConfig[configJob].planeBlipScale, firstName, lastName, serverBadge, blipConfig[configJob].planeBlipColor)
    elseif blipConfig[configJob].militaryBlip and GetVehicleClass(veh) == 19 then  -- Military Control
        clientBlip(blipConfig[configJob].militaryBlipIcon, blipConfig[configJob].militaryBlipScale, firstName, lastName, serverBadge, blipConfig[configJob].militaryBlipColor)
    elseif blipConfig[configJob].parachuteBlip and plrParachute == 2 then          -- Parachute Control
        clientBlip(blipConfig[configJob].parachuteBlipIcon, blipConfig[configJob].parachuteBlipScale, firstName, lastName, serverBadge, blipConfig[configJob].parachuteBlipColor)
    else
        clientBlip(blipConfig[configJob].defaultBlipIcon, blipConfig[configJob].defaultBlipScale, firstName, lastName, serverBadge, blipConfig[configJob].defaultBlipColor)
    end
end

function serverBlipCreate(configJob, sirenOn, vehicleClass, playerParachute, coords, firstName, lastName, serverBadge, playerID)
    if blipConfig[configJob].sirenBlip and sirenOn then                             -- Siren Control
        serverBlip(blipConfig[configJob].sirenBlipIcon, blipConfig[configJob].sirenBlipScale, coords, firstName, lastName, serverBadge, blipConfig[configJob].sirenBlipColor, playerID)
    elseif blipConfig[configJob].motorBlip and vehicleClass == 8 then               -- Motorcycle Control
        serverBlip(blipConfig[configJob].motorBlipIcon, blipConfig[configJob].motorBlipScale, coords, firstName, lastName, serverBadge, blipConfig[configJob].motorBlipColor, playerID)
    elseif blipConfig[configJob].boatBlip and vehicleClass == 14 then               -- Boat Control
        serverBlip(blipConfig[configJob].boatBlipIcon, blipConfig[configJob].boatBlipScale, coords, firstName, lastName, serverBadge, blipConfig[configJob].boatBlipColor, playerID)
    elseif blipConfig[configJob].heliBlip and vehicleClass == 15 then               -- Helicopter Control
        serverBlip(blipConfig[configJob].heliBlipIcon, blipConfig[configJob].heliBlipScale, coords, firstName, lastName, serverBadge, blipConfig[configJob].heliBlipColor, playerID)
    elseif blipConfig[configJob].planeBlip and vehicleClass == 16 then              -- Plane Control
        serverBlip(blipConfig[configJob].planeBlipIcon, blipConfig[configJob].planeBlipScale, coords, firstName, lastName, serverBadge, blipConfig[configJob].planeBlipColor, playerID)
    elseif blipConfig[configJob].militaryBlip and vehicleClass == 19 then           -- Military Control
        serverBlip(blipConfig[configJob].militaryBlipIcon, blipConfig[configJob].militaryBlipScale, coords, firstName, lastName, serverBadge, blipConfig[configJob].militaryBlipColor, playerID)
    elseif blipConfig[configJob].parachuteBlip and playerParachute == 2 then        -- Parachute Control
        serverBlip(blipConfig[configJob].parachuteBlipIcon, blipConfig[configJob].parachuteBlipScale, coords, firstName, lastName, serverBadge, blipConfig[configJob].parachuteBlipColor, playerID)
    else
        serverBlip(blipConfig[configJob].defaultBlipIcon, blipConfig[configJob].defaultBlipScale, coords, firstName, lastName, serverBadge, blipConfig[configJob].defaultBlipColor, playerID)
    end
end

function serverBlip(icon, scale, coords, firstName, lastName, serverBadge, color, playerID) -- Other Player Blip Create
    playersID = playerID

    if playerBlips[playersID] then -- Remove Blip
        RemoveBlip(playerBlips[playersID])
        playerBlips[playersID] = nil
    end

    local blip1 = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip1, icon)
    SetBlipDisplay(blip1, 4)
    SetBlipScale(blip1, scale)
    SetBlipColour(blip1, color)
    SetBlipAsShortRange(blip1, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("[" .. serverBadge .. "] " .. firstName .. " " .. lastName)
    EndTextCommandSetBlipName(blip1)
    playerBlips[playersID] = blip1
end

function clientBlip(icon, scale, firstName, lastName, serverBadge, color) -- My Blip Create
    if weBlip[playerId] then                                             -- Remove Blip
        RemoveBlip(weBlip[playerId])
        weBlip[playerId] = nil
    end

    if playerBlips[playersID] then
        RemoveBlip(playerBlips[playersID])
        playerBlips[playersID] = nil
    end

    local blip2 = AddBlipForEntity(ped)
    SetBlipSprite(blip2, icon)
    SetBlipDisplay(blip2, 4)
    SetBlipScale(blip2, scale)
    SetBlipColour(blip2, color)
    SetBlipAsShortRange(blip2, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("[" .. serverBadge .. "] " .. firstName .. " " .. lastName)
    EndTextCommandSetBlipName(blip2)
    weBlip[playerId] = blip2
end

function blipSettings(status)
    local playerBlip = GetMainPlayerBlipId()
    local configControl = Config.General.playerBlip

    if configControl then
        if DoesBlipExist(playerBlip) then
            SetBlipAlpha(playerBlip, status)
        end
    end
end

function stopGPS(value)

    if GPSstatus then
        GPSstatus = false

        blipSettings(255)
        
        if weBlip[playerId] then
            RemoveBlip(weBlip[playerId])
            weBlip[playerId] = nil
        end

        if playerBlips[playersID] then
            RemoveBlip(playerBlips[playersID])
            playerBlips[playersID] = nil
        end

        TriggerServerEvent('gps:stopTracking')
        TriggerEvent('screenshot')

        TriggerEvent('webhookControl', badgeNumber, 'off')

        if value == true then
            notification(getLang('sucTitle'), getLang('gpsIsOff'), successIcon, successColor)
        else
            notification(getLang('errTitle'), getLang('notGPS'), deniedIcon, deniedColor)
        end
    else
        notification(getLang('errTitle'), getLang('alreadyGPSOff'), deniedIcon, deniedColor)
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        blipSettings(255)
    end
end)

function LoadLocale(locale)
    if locale == nil or locale == '' then
        print("Invalid locale: " .. tostring(locale))
        return
    end

    local filePath = 'locales/' .. locale .. '.lua'
    local file = LoadResourceFile(GetCurrentResourceName(), filePath)
    if file then
        local func, err = load(file)
        if func then
            local ok, err = pcall(func)
            if not ok then
                print("Error executing locale file: " .. err)
            end
        else
            print("Error loading locale file: " .. err)
        end
    else
        print("Locale file not found: " .. filePath)
    end
end

function getLang(key)
    local locale = lang
    if locale == nil or locale == '' then
        print("Invalid locale: " .. tostring(locale))
        return 'Locale not set'
    end

    if Locales == nil then
        print("Locales is nil")
        return 'Locales not loaded'
    elseif Locales[locale] == nil then
        print("Locale not found in Locales: " .. locale)
        return 'Locale not found'
    end

    local text = Locales[locale][key]
    if text then
        return text
    else
        print("Key not found: " .. key)
        return 'Key not found: ' .. key
    end
end

function notification(title, desc, icon, iconColor)

    local backgroundColor = Config.Noification.backgroundColor
    local descriptionColor = Config.Noification.descriptionColor
    local showDuration = Config.Noification.showDuration
    local position = Config.Noification.position
    local iconAnimation = Config.Noification.iconAnimation
    local titleColor = Config.Noification.titleColor

    exports.ox_lib:notify({
        title = title,
        description = desc,
        showDuration = showDuration,
        position = position,
        style = {
            backgroundColor = backgroundColor,
            color = titleColor,
            ['.description'] = {
              color = descriptionColor
            }
        },
        icon = icon,
        iconColor = iconColor,
        iconAnimation = iconAnimation
    })
end