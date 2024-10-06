local npcTable = {}

local function hasPermission(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end

    local playerGroup = xPlayer.getGroup()

    for _, adminGroup in ipairs(Config.adminGroups) do
        if playerGroup == adminGroup then
            return true
        end
    end
end

local function FoundExploiter(src,reason)
	-- ADD YOUR BAN EVENT HERE UNTIL THEN IT WILL ONLY KICK THE PLAYER --
	DropPlayer(src,reason)
end

function GetPlayerSteamHex(serverId)
    local identifiers = GetPlayerIdentifiers(serverId)

    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, "steam:") then
            return string.gsub(identifier, "steam:", "")
        end
    end

    return nil -- Return nil if Steam hex is not found
end

RegisterCommand(Config.Command, function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if hasPermission(src) then
        TriggerClientEvent("npcCreation", src)
    else
        xPlayer.showNotification("You don't have permission for this", false, false, false)
    end
end)

AddEventHandler("insertData")
RegisterNetEvent("insertData", function(coords, model, data, heading)
    -- If this fails its 99% a mod-menu, the variables client sided are setup to provide the exact right arguments
	if type(heading) ~= 'number' or type(model) ~= 'string' or not data or not coords then
		print(('wNpcCreator: %s attempted to create NPC with invalid input type!'):format(GetPlayerSteamHex(source)))
		return
	end
    if hasPermission(src) then
        table.insert(npcTable, {
            name = data.name,
            hash = model,
            event = data.event,
            coords = coords,
            heading = heading,
            animDict = data.animDict,
            animName = data.animName,
            useOxTarget = data.useOxTarget,
            job = data.job,
            grade = data.grade,
            oxTargetLabel = data.oxTargetLabel,
            useDrawText = data.useDrawText,
            drawTextKey = data.drawTextKey,
        })
        SaveNPCData()
    else
        print(('wNpcCreator: %s attempted to create NPC without permission!'):format(GetPlayerSteamHex(source)))
        FoundExploiter(source,'insertData Event Trigger')
    end
end)

AddEventHandler("npcDelete")
RegisterNetEvent("npcDelete", function(name)
    -- If this fails its 99% a mod-menu, the variables client sided are setup to provide the exact right arguments
	if type(name) ~= 'string' then
		print(('wNpcCreator: %s attempted to delete invalid NPC!'):format(GetPlayerSteamHex(source)))
		return
	end
    if hasPermission(src) then
        for i = #npcTable, 1, -1 do
            if string.lower(npcTable[i].name) == string.lower(name) then
                local npcHash = npcTable[i].hash
                table.remove(npcTable, i)
                SaveNPCData()
                TriggerClientEvent('deleteNPCServer', -1, npcHash)
                break
            end
        end
    else
        print(('wNpcCreator: %s attempted to delete NPC without permission!'):format(GetPlayerSteamHex(source)))
        FoundExploiter(source,'npcDelete Event Trigger')
    end
end)

function SaveNPCData()
    local jsonData = json.encode(npcTable)
    SaveResourceFile(GetCurrentResourceName(), "npcData.json", jsonData, -1)
    TriggerClientEvent('resourceStart', -1, npcTable)
end

function LoadNPCData()
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "npcData.json")
    if loadFile then
        npcTable = json.decode(loadFile)
    end
end

lib.callback.register('npcGetAll', function(source)
    return npcTable
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        LoadNPCData()
        Wait(200)
        TriggerClientEvent('resourceStart', -1, npcTable)
    end  
end)

AddEventHandler("playerJoining", function(playerId, reason)
    LoadNPCData()
    Wait(200)
    TriggerClientEvent('resourceStart', playerId, npcTable)
end)
