Bridge = {}

local framework = WNPC.Framework
local ESX, QBCore

CreateThread(function()
    if framework == 'esx' then
        ESX = exports.es_extended:getSharedObject()
    elseif framework == 'qb' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end)

function Bridge.HasPermission(src)
    if IsPlayerAceAllowed(src, Config.AcePermission) then
        return true
    end

    for i = 1, #Config.AdminGroups do
        local group = Config.AdminGroups[i]

        if framework == 'esx' and ESX then
            local xPlayer = ESX.GetPlayerFromId(src)
            if xPlayer and xPlayer.getGroup() == group then
                return true
            end
        elseif framework == 'qb' and QBCore then
            if QBCore.Functions.HasPermission(src, group) then
                return true
            end
        elseif framework == 'qbx' then
            if IsPlayerAceAllowed(src, 'group.' .. group) then
                return true
            end
        end
    end

    return false
end

function Bridge.GetIdentifier(src)
    return GetPlayerIdentifierByType(src, 'license')
        or GetPlayerIdentifierByType(src, 'steam')
        or ('server:%s'):format(src)
end

function Bridge.Notify(src, message, ntype)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'NPC Creator',
        description = message,
        type = ntype or 'inform',
    })
end
