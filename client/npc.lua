local npcTable = {}
local keyOptions = {}
local sortedKeys = {}
local drawString = {}
local showText = false

RegisterCommand("npc", function()
    lib.registerContext({
        id = 'npc_create',
        title = 'NPC Creator made by WhereiamL',
        options = {
            {
                title = 'Create new NPC',
                icon = 'hand',
                description = 'Creates a new NPC',
                onSelect = function()
                    TriggerEvent("npcCreationMenu")
                end,
            },
            {
                title = 'Teleport to NPC',
                icon = 'hand',
                description = "Teleport to your existing NPCs",
                onSelect = function()
                    local locations = lib.callback.await('npcGetAll', false)
                    local options = {}
                    for i = 1, #locations do 
                        options[#options + 1] = {
                            title = locations[i].name,
                            icon = 'marker',
                            description = 'Click to teleport',
                            onSelect = function()
                               SetEntityCoords(PlayerPedId(), locations[i].coords.x, locations[i].coords.y, locations[i].coords.z)
                               lib.notify({
                                    title = 'Teleport',
                                    description = 'Teleported to ' .. locations[i].name,
                                    type = 'success'
                                })
                            end,
                        }
                    end
                    lib.registerContext({
                        id = 'npc_teleport',
                        title = 'Teleport to a desired NPC',
                        options = options
                    })
                    lib.showContext('npc_teleport')
                end,
            },
            
            {
                title = 'Delete existing NPC',
                icon = 'trash',
                description = "Deletes an existing NPC you created",
                onSelect = function()
                    local npc = lib.callback.await('npcGetAll', false)
                    local options = {}
                    for i = 1, #npc do 
                        options[#options + 1] = {
                            title = npc[i].name,
                            icon = 'trash',
                            description = 'Click to delete',
                            onSelect = function()
                                local deleted = TriggerServerEvent("npcDelete", npc[i].name)
                                if not deleted then
                                    lib.notify({
                                        title = 'NPC Creator',
                                        description = 'NPC deleted successfully',
                                        type = 'success'
                                    })
                                else
                                    lib.notify({
                                        title = 'NPC Creator',
                                        description = 'The deletion failed',
                                        type = 'error'
                                    })
                                end
                            end,
                        }
                    end
                    lib.registerContext({
                        id = 'npc_delete',
                        title = 'Delete an existing NPC',
                        options = options
                    })
                    lib.showContext('npc_delete')
                end,
            },        
        }
    })
    lib.showContext('npc_create')
end)

AddEventHandler("npcCreationMenu", function()
    for key, _ in pairs(keys) do
        table.insert(sortedKeys, key)
    end
    table.sort(sortedKeys)
    for _, key in ipairs(sortedKeys) do
        local code = keys[key]
        table.insert(keyOptions, { value = tostring(code), label = key })
    end

    local input = lib.inputDialog('WhereiamL NPC Creator', {
        {type = 'input', label = 'Name of the NPC', required = true}, --1
        {type = 'input', label = 'NPC Hash', description = 'Enter the hash of the NPC model.', required = true},--2
        {type = 'input', label = 'Event', description = 'The event triggered after interacting with the NPC.'},--3
        {type = 'input', placeholder = 'animDict', description = 'The animation dictionary for the NPC.'},--4
        {type = 'input', placeholder = 'animName', description = 'The animation name for the NPC.'},--5
        {type = 'checkbox', label = 'Use ox_target', description = 'Enable advanced interaction options with ox_target.'},--6
        {type = 'checkbox', label = 'Use Drawtext', description = 'Display text above the NPC using drawText.'},--7
        {type = 'input', placeholder = 'Job group', description = 'Specify the job group to restrict interaction. Leave blank for unrestricted access.'},--8
        {type = 'input', label = 'Grade', description = 'Specify the required grade for the job group.'},--9
        {type = 'textarea', label = 'Label', description = 'Label for ox target/drawtext.'},--10
        {type = 'select', label = 'Menu Key', options = keyOptions, description = 'The key to open the menu if drawText is enabled, blank for default key [E]'},--11
    })
    
    if not input then return end
    
    local data = {
        name = input[1],
        hash = input[2],
        event = input[3],
        animDict = input[4] ~= "" and input[4] or "amb@world_human_stand_guard@male@base",
        animName = input[5] ~= "" and input[5] or "base",
        useOxTarget = input[6] and true or false,
        useDrawText = input[7] and true or false,
        job = input[8] ~= "" and input[8] or false,
        grade = input[9] ~= "" and input[9] or 0,
        oxTargetLabel = input[10] or "Label not specified",
        drawTextKey = input[11] or "E",
    }
    TriggerEvent("control:CreateEntity", data)
end)    

RegisterNetEvent("resourceStart")
AddEventHandler("resourceStart", function(list)
    hasDrawText = false
    for _, npcData in ipairs(list) do
        if npcData.useDrawText then
            hasDrawText = true
            drawString[#drawString + 1] = { label = npcData.oxTargetLabel, hash = npcData.hash } 
        end

        local npcIdentifier = npcData.hash
        if not npcExists(npcIdentifier) then
            local modelHash = GetHashKey(npcData.hash)
            if not IsModelValid(modelHash) then
                print("Invalid model hash:", npcData.hash)
                goto continue
            end

            local npc = createNPC(modelHash, npcData.coords, npcData.heading, npcData.animDict, npcData.animName)
            if not npc then
                print("Failed to create NPC:", npcData.hash)
                goto continue
            end
            table.insert(npcTable, {
                npc = npc,
                identifier = npcIdentifier,
            })

            options = {}
            if npcData.useOxTarget then
                local groups = nil
                if npcData.job then
                    options[#options +1] = {
                       groups = { [npcData.job] = tonumber(npcData.grade)},
                       event = npcData.event,
                       icon = "fas fa-globe",
                       label = npcData.oxTargetLabel,
                    }
                else
                    options[#options +1] = {
                        event = npcData.event,
                        icon = "fas fa-globe",
                        label = npcData.oxTargetLabel,
                     }
                end
                exports.ox_target:addBoxZone({
                    coords = vec3(npcData.coords.x, npcData.coords.y, npcData.coords.z),
                    size = vec3(0.6, 0.6, 3.5),
                    name = "npc -" .. npcIdentifier,
                    heading = npcData.heading,
                    debug = false,
                    options = options,
                    distance = 1.5
                })
            end
            if hasDrawText == true then
                CreateThread(function()
                    while hasDrawText do
                        Wait(0)
                        local pedC = GetEntityCoords(PlayerPedId())
                        local controlCode = keys[npcData.drawTextKey]
                        if #(pedC - vec3(npcData.coords.x, npcData.coords.y, npcData.coords.z)) <= 10 then
                            local hasJobAndGrade = false
                            if ESX.PlayerData.job.name == npcData.job and ESX.PlayerData.job.grade >= tonumber(npcData.grade) then       
                                hasJobAndGrade = true
                            end

                            local isPublic = npcData.job == false and tonumber(npcData.grade) == 0
                            local isRestricted = npcData.job ~= false and tonumber(npcData.grade) ~= 0
                            
                            if isPublic or (isRestricted and hasJobAndGrade) then
                                for i = 1, #drawString do
                                    if drawString[i].label == npcData.oxTargetLabel then
                                        drawText3D(vec3(npcData.coords.x, npcData.coords.y, npcData.coords.z + 1.2), drawString[i].label, 0.40)
                                    end
                                end
                                
                                if #(pedC - vec3(npcData.coords.x, npcData.coords.y, npcData.coords.z)) <= 3 then
                                    if IsControlJustPressed(0, controlCode) then
                                        TriggerEvent(npcData.event)
                                    end
                                end
                            end
                        else
                            Wait(1400)
                        end
                    end
                end)
            end
        end
        ::continue::
    end
end)

function npcExists(npcIdentifier)
    for _, existingNpc in ipairs(npcTable) do
        if existingNpc.identifier == npcIdentifier then
            return true
        end
    end
    return false
end

function deleteNPC(npcHash)
    for i, npc in ipairs(npcTable) do
        if npc.identifier == npcHash then
            if DoesEntityExist(npc.npc) then
                DeleteEntity(npc.npc)
            end
            table.remove(npcTable, i)
            break
        end
    end
end

RegisterNetEvent("deleteNPCServer")
AddEventHandler("deleteNPCServer", function(npcHash)
    deleteNPC(npcHash)
    for i, data in ipairs(drawString) do
        if data.hash == npcHash then
            table.remove(drawString, i)
            break
        end
    end
end)

function createNPC(modelHash, coords, heading, animDict, animName, blipName, blipColor, blipSize)
    local npc = createPed(modelHash, coords, heading)
    if not npc then
        return nil
    end
    setupNPC(npc)
    playAnimation(npc, animDict, animName)
    return npc
end

function createPed(modelHash, coords, heading)
    lib.requestModel(modelHash)
    local npc = CreatePed(4, modelHash, coords.x, coords.y, coords.z, heading, false, true)
    if not DoesEntityExist(npc) then
        return nil
    end
    PlaceObjectOnGroundProperly(npc)
    SetEntityHeading(npc, heading)
    Wait(100)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetModelAsNoLongerNeeded(npc)
    return npc
end

function setupNPC(npc)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
end

function playAnimation(npc, animDict, animName)
    lib.requestAnimDict(animDict)
    TaskPlayAnim(npc, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
end