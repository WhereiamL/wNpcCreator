local function notify(description, ntype)
    lib.notify({ title = 'NPC Creator', description = description, type = ntype or 'inform' })
end

local function createNpc()
    local input = lib.inputDialog('Create NPC', {
        { type = 'input', label = 'Name', description = 'Unique name for this NPC.', required = true },
        { type = 'input', label = 'Model', description = 'Ped model name or hash.', required = true },
        { type = 'input', label = 'Event', description = 'Client event triggered on interaction.' },
        { type = 'input', label = 'Animation dictionary', description = 'Leave blank for the default.' },
        { type = 'input', label = 'Animation name', description = 'Leave blank for the default.' },
        { type = 'checkbox', label = 'Use ox_target', description = 'Interact through ox_target.' },
        { type = 'checkbox', label = 'Use DrawText', description = 'Show floating text and key interaction.' },
        { type = 'input', label = 'Job', description = 'Restrict to a job. Leave blank for everyone.' },
        { type = 'number', label = 'Grade', description = 'Minimum job grade required.', default = 0, min = 0 },
        { type = 'input', label = 'Label', description = 'Text shown for target / drawtext.' },
        { type = 'select', label = 'Interaction key', description = 'Key used when DrawText is enabled.',
          options = GetKeyOptions(), default = Config.DefaultInteractKey },
    })

    if not input then return end

    local placement = StartPlacement(input[2])
    if not placement then
        notify('Placement cancelled.', 'inform')
        return
    end

    TriggerServerEvent('wnpc:create', {
        name = input[1],
        model = input[2],
        event = input[3],
        animDict = input[4],
        animName = input[5],
        useTarget = input[6] == true,
        useDrawText = input[7] == true,
        job = input[8],
        grade = input[9],
        label = input[10],
        drawKey = input[11],
        coords = placement.coords,
        heading = placement.heading,
    })
end

local function teleportMenu()
    local list = NpcManager.getAll()
    if #list == 0 then
        notify('No NPCs to teleport to.', 'inform')
        return
    end

    local options = {}
    for i = 1, #list do
        local npc = list[i]
        options[#options + 1] = {
            title = npc.name,
            icon = 'location-dot',
            description = 'Teleport here',
            onSelect = function()
                SetEntityCoords(cache.ped, npc.coords.x, npc.coords.y, npc.coords.z, false, false, false, false)
                notify(('Teleported to %s.'):format(npc.name), 'success')
            end,
        }
    end

    lib.registerContext({ id = 'wnpc_teleport', title = 'Teleport to NPC', menu = 'wnpc_main', options = options })
    lib.showContext('wnpc_teleport')
end

local function deleteMenu()
    local list = NpcManager.getAll()
    if #list == 0 then
        notify('No NPCs to delete.', 'inform')
        return
    end

    local options = {}
    for i = 1, #list do
        local npc = list[i]
        options[#options + 1] = {
            title = npc.name,
            icon = 'trash',
            description = 'Delete this NPC',
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Delete NPC',
                    content = ('Are you sure you want to delete **%s**?'):format(npc.name),
                    centered = true,
                    cancel = true,
                })
                if confirm == 'confirm' then
                    TriggerServerEvent('wnpc:delete', npc.id)
                end
            end,
        }
    end

    lib.registerContext({ id = 'wnpc_delete', title = 'Delete NPC', menu = 'wnpc_main', options = options })
    lib.showContext('wnpc_delete')
end

RegisterNetEvent('wnpc:openMenu', function()
    lib.registerContext({
        id = 'wnpc_main',
        title = 'NPC Creator',
        options = {
            { title = 'Create NPC', icon = 'plus', description = 'Place a new NPC', onSelect = createNpc },
            { title = 'Teleport to NPC', icon = 'location-arrow', description = 'Travel to an existing NPC', onSelect = teleportMenu },
            { title = 'Delete NPC', icon = 'trash', description = 'Remove an existing NPC', onSelect = deleteMenu },
        },
    })
    lib.showContext('wnpc_main')
end)
