local functions = LoadResourceFile('kirep-gps', 'functions.lua')

local webhookEnable = Config.Webhook.enabled
local lang = Config.General.lang

local deniedColor = Config.Noification.deniedColor
local deniedIcon = Config.Noification.deniedIcon

Locales = {}
local gpsUsers = {}

if functions then
    load(functions)()
end

Citizen.CreateThread(function()

    if lang == nil or lang == '' then
        print('^1'..'Invalid locale in Config: '..'^3'..tostring(lang))
        return
    end

    LoadLocale(lang)

    if webhookEnable then
        print('^2'..getLang('webhookIsOn'))
    else
        print('^1'..getLang('webhookIsOff'))
    end
end)

CreateUseableItem(Config.General.itemName, function(source)
    local player = GetPlayer(source)
    local jobControl

    if player then
        local isJobValid = IsPlayerInJob(player, blipConfig.Jobs)

        if isJobValid then
            TriggerClientEvent('gps:itemUsed', source)
            jobControl = true
        else
            jobControl = false
        end

        if jobControl == false then
            TriggerClientEvent('webhookControl', source, nil, 'noJob')
            notification(getLang('errTitle'), getLang('noJob'), deniedIcon, deniedColor, source)
        end
    end
end)

RegisterServerEvent('playerInfo')
AddEventHandler('playerInfo', function(badgeNumber, vehicleClass, sirenOn, playerParachute, plrHealth, jobName)
    local playerId = source
    local Player = GetPlayer(playerId)

    if Player then
        local serverPlayerName = GetPlayerName(playerId)
        local ped = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(ped)
    
        local firstName, lastName = GetPlayerCharacterName(Player)

        gpsUsers[playerId] = playerId

        for id, data in pairs(gpsUsers) do
            if gpsUsers[id] then
                TriggerClientEvent('gps:blipCreate', id, playerCoords, firstName, lastName, serverPlayerName, badgeNumber, vehicleClass, sirenOn, playerParachute, plrHealth, playerId, jobName)
            end
        end
    end
end)

RegisterServerEvent('gps:stopTracking')  -- Stop player is GPS
AddEventHandler('gps:stopTracking', function()
    local player = source

    if gpsUsers[player] then
        gpsUsers[player] = nil
    end
end)

RegisterServerEvent('discordWebhook')
AddEventHandler('discordWebhook', function(badgeNumber, status, screenshot)
    local playerId = source
    local Player = GetPlayer(playerId)
    local firstName, lastName = GetPlayerCharacterName(Player)
    local health = GetPlayerMaxHealth(playerId)

    local name = Config.Webhook.serverName
    local URL = Config.Webhook.URL
    local image = Config.Webhook.imageURL
    local noJobLog = Config.Webhook.noJobLog

    local embed

    local successColor = Config.Webhook.successColor
    local deniedColor = Config.Webhook.deniedColor
    local noJobColor = Config.Webhook.noJobColor

    local DC = string.sub(GetPlayerIdentifierByType(playerId, 'discord'), 9)
    local Steam = tostring(GetPlayerIdentifierByType(playerId, 'steam'))
    local FiveM = tostring(GetPlayerIdentifierByType(playerId, 'fivem'))

    local embed1 = {{
        ["title"] = getLang('webhookOnTitle'),
        ["fields"] = {
            {["name"] = getLang('webhookName'), ["value"] = firstName..' '..lastName, ["inline"] = true},
            {["name"] = getLang('webhookBadge'), ["value"] = '`'..tostring(badgeNumber)..'`', ["inline"] = true},
            {["name"] = getLang('webhookPlayerID'), ["value"] = '`'..tostring(playerId)..'`', ["inline"] = true},
            {["name"] = getLang('webhookHealth'), ["value"] = '`100/'..tostring(health)..'`', ["inline"] = true},
            {["name"] = getLang('webhookDiscord'), ["value"] = '`'..DC..'`', ["inline"] = true},
            {["name"] = getLang('webhookSteam'), ["value"] = '`'..Steam..'`', ["inline"] = true},
        },
        ["image"] = {
            ["url"] = screenshot,
        },
        ["color"] = successColor
    }}

    local embed2 = {{
        ["title"] = getLang('webhookOffTitle'),
        ["fields"] = {
            {["name"] = getLang('webhookName'), ["value"] = firstName..' '..lastName, ["inline"] = true},
            {["name"] = getLang('webhookBadge'), ["value"] = '`'..tostring(badgeNumber)..'`', ["inline"] = true},
            {["name"] = getLang('webhookPlayerID'), ["value"] = '`'..tostring(playerId)..'`', ["inline"] = true},
            {["name"] = getLang('webhookHealth'), ["value"] = '`100/'..tostring(health)..'`', ["inline"] = true},
            {["name"] = getLang('webhookDiscord'), ["value"] = '`'..DC..'`', ["inline"] = true},
            {["name"] = getLang('webhookSteam'), ["value"] = '`'..Steam..'`', ["inline"] = true},
        },
        ["image"] = {
            ["url"] = screenshot,
        },
        ["color"] = deniedColor
    }}

    local embed3 = {{
        ["description"] = getLang('webhookNoJob'),
        ["fields"] = {
            {["name"] = getLang('webhookName'), ["value"] = firstName..' '..lastName, ["inline"] = true},
            {["name"] = getLang('webhookPlayerID'), ["value"] = '`'..tostring(playerId)..'`', ["inline"] = true},
            {["name"] = getLang('webhookHealth'), ["value"] = '`100/'..tostring(health)..'`', ["inline"] = true},
            {["name"] = getLang('webhookDiscord'), ["value"] = '`'..DC..'`', ["inline"] = true},
            {["name"] = getLang('webhookSteam'), ["value"] = '`'..Steam..'`', ["inline"] = true},
            {["name"] = getLang('webhookFiveM'), ["value"] = '`'..FiveM..'`', ["inline"] = true},
        },
        ["image"] = {
            ["url"] = screenshot,
        },
        ["color"] = noJobColor
    }}

    if status == 'on' then
        embed = embed1
    elseif status == 'off' then
        embed = embed2
    elseif noJobLog and status == 'noJob' then
        embed = embed3
    end

    PerformHttpRequest(URL, function(err, text, headers) 
        if err ~= 204 then
            print('-------------------------------------------------------')
            print('WEBHOOK ERROR')
            print('^1'.."Error: "..'^3'..tostring(err))
            print('^1'.."Response: "..'^3'..tostring(text))
            print('-------------------------------------------------------')
        end
    end, 'POST', json.encode({username = name, avatar_url = image, embeds = embed}), { ['Content-Type'] = 'application/json' })
end)

function LoadLocale(locale)
    if locale == nil or locale == '' then
        print('^1'.."Invalid locale: " .. tostring(locale))
        return
    end

    local filePath = 'locales/' .. locale .. '.lua'
    local file = LoadResourceFile(GetCurrentResourceName(), filePath)
    if file then
        local func, err = load(file)
        if func then
            local ok, err = pcall(func)
            if not ok then
                print('^1'.."Error executing locale file: "..'^3'..err)
            end
        else
            print('^1'.."Error loading locale file: "..'^3'..err)
        end
    else
        print('^1'.."Locale file not found: "..'^3'..filePath)
    end
end

function getLang(key)
    local locale = lang
    
    if locale == nil or locale == '' then
        print('^1'.."Invalid locale: "..'^3'..tostring(locale))
        return 'Locale not set'
    end

    if Locales == nil then
        print('^1'.."Locales is nil")
        return 'Locales not loaded'

    elseif Locales[locale] == nil then
        print('^1'.."Locale not found in Locales: "..'^3'..locale)
        return 'Locale not found'
    end

    local text = Locales[locale][key]
    if text then
        return text
    else
        print('^1'.."Key not found: "..'^3'..key)
        return 'Key not found: ' .. key
    end
end

function notification(title, desc, icon, iconColor, player)
    local backgroundColor = Config.Noification.backgroundColor
    local descriptionColor = Config.Noification.descriptionColor
    local showDuration = Config.Noification.showDuration
    local position = Config.Noification.position
    local iconAnimation = Config.Noification.iconAnimation
    local titleColor = Config.Noification.titleColor

    TriggerClientEvent('ox_lib:notify', player, {
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