local ESX = nil
local QBCore = nil

if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

function CreateUseableItem(itemName, callback)
    if QBCore then
        QBCore.Functions.CreateUseableItem(itemName, callback)
    elseif ESX then
        ESX.RegisterUsableItem(itemName, callback)
    end
end

function GetPlayer(source)
    if ESX then
        return ESX.GetPlayerFromId(source)
    elseif QBCore then
        return QBCore.Functions.GetPlayer(source)
    end
    return nil
end

function IsPlayerInJob(player, jobList)
    local playerJob = nil

    if ESX then
        playerJob = player.job.name
    elseif QBCore then
        playerJob = player.PlayerData.job.name
    end

    for i = 1, #jobList do
        if playerJob == jobList[i] then
            return true
        end
    end

    return false
end

function GetPlayerCharacterName(player)
    if ESX then
        return player.get('firstName'), player.get('lastName')
    elseif QBCore then
        local charInfo = player.PlayerData.charinfo
        return charInfo.firstname, charInfo.lastname
    end
    return nil, nil
end

function HasItem(itemName)
    if not itemName or type(itemName) ~= "string" then
        error("Geçersiz öğe adı sağlandı.")
    end

    if ESX then
        if GetResourceState("ox_inventory") == "started" then
            return exports.ox_inventory:Search('count', itemName) > 0
        end
    elseif QBCore then
        if GetResourceState("ox_inventory") == "started" then
            return exports.ox_inventory:Search('count', itemName) > 0
        elseif GetResourceState("qb-inventory") == "started" then
            return QBCore.Functions.HasItem(itemName)
        end
    end

    return false
end


function GetPlayerData()
    if ESX then
        return ESX.GetPlayerData()
    elseif QBCore then
        return QBCore.Functions.GetPlayerData()
    end
    return nil
end