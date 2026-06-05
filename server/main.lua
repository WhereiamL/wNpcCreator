local NpcStore = {}

local function validate(p)
    if type(p) ~= 'table' then return end
    if type(p.name) ~= 'string' or p.name == '' then return end
    if type(p.model) ~= 'string' or p.model == '' then return end
    if type(p.coords) ~= 'table' then return end
    if type(p.coords.x) ~= 'number' or type(p.coords.y) ~= 'number' or type(p.coords.z) ~= 'number' then return end
    if type(p.heading) ~= 'number' then return end

    return {
        name = p.name:sub(1, 100),
        model = p.model:sub(1, 100),
        event = (type(p.event) == 'string' and p.event ~= '') and p.event:sub(1, 255) or nil,
        coords = { x = p.coords.x, y = p.coords.y, z = p.coords.z },
        heading = p.heading + 0.0,
        animDict = (type(p.animDict) == 'string' and p.animDict ~= '') and p.animDict or Config.DefaultAnimDict,
        animName = (type(p.animName) == 'string' and p.animName ~= '') and p.animName or Config.DefaultAnimName,
        useTarget = p.useTarget == true,
        useDrawText = p.useDrawText == true,
        job = (type(p.job) == 'string' and p.job ~= '') and p.job or nil,
        grade = tonumber(p.grade) or 0,
        label = (type(p.label) == 'string' and p.label ~= '') and p.label:sub(1, 255) or 'Interact',
        drawKey = (type(p.drawKey) == 'string' and p.drawKey ~= '') and p.drawKey or Config.DefaultInteractKey,
    }
end

CreateThread(function()
    Database.init()
    local rows = Database.fetchAll()
    for i = 1, #rows do
        NpcStore[rows[i].id] = rows[i]
    end
    print(('[wNpcCreator] Loaded %d NPC(s).'):format(#rows))
end)

lib.callback.register('wnpc:getAll', function()
    local list = {}
    for _, npc in pairs(NpcStore) do
        list[#list + 1] = npc
    end
    return list
end)

RegisterNetEvent('wnpc:create', function(payload)
    local src = source
    if not Bridge.HasPermission(src) then
        Bridge.Notify(src, 'You do not have permission to do that.', 'error')
        return
    end

    local data = validate(payload)
    if not data then
        Bridge.Notify(src, 'Invalid NPC data received.', 'error')
        return
    end

    local id = Database.insert(data, Bridge.GetIdentifier(src))
    if not id or id == 0 then
        Bridge.Notify(src, 'Could not save NPC, name may already exist.', 'error')
        return
    end

    data.id = id
    NpcStore[id] = data
    TriggerClientEvent('wnpc:add', -1, data)
    Bridge.Notify(src, ('NPC "%s" created.'):format(data.name), 'success')
end)

RegisterNetEvent('wnpc:delete', function(id)
    local src = source
    if not Bridge.HasPermission(src) then
        Bridge.Notify(src, 'You do not have permission to do that.', 'error')
        return
    end

    id = tonumber(id)
    if not id or not NpcStore[id] then return end

    Database.delete(id)
    local name = NpcStore[id].name
    NpcStore[id] = nil
    TriggerClientEvent('wnpc:remove', -1, id)
    Bridge.Notify(src, ('NPC "%s" deleted.'):format(name), 'success')
end)

RegisterCommand(Config.Command, function(source)
    if source == 0 then
        print('[wNpcCreator] This command can only be used in-game.')
        return
    end
    if not Bridge.HasPermission(source) then
        Bridge.Notify(source, 'You do not have permission to do that.', 'error')
        return
    end
    TriggerClientEvent('wnpc:openMenu', source)
end, false)
