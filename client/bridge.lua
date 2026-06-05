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

function Bridge.GetJob()
    if framework == 'esx' and ESX then
        local data = ESX.GetPlayerData()
        if data and data.job then
            return { name = data.job.name, grade = data.job.grade }
        end
    elseif framework == 'qb' and QBCore then
        local data = QBCore.Functions.GetPlayerData()
        if data and data.job then
            return { name = data.job.name, grade = data.job.grade.level }
        end
    elseif framework == 'qbx' then
        local data = exports.qbx_core:GetPlayerData()
        if data and data.job then
            return { name = data.job.name, grade = data.job.grade.level }
        end
    end
    return { name = 'unemployed', grade = 0 }
end
