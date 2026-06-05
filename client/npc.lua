local NpcEntity = lib.class('NpcEntity')

function NpcEntity:constructor(data)
    self.id = data.id
    self.name = data.name
    self.model = data.model
    self.event = data.event
    self.coords = vec3(data.coords.x + 0.0, data.coords.y + 0.0, data.coords.z + 0.0)
    self.heading = data.heading + 0.0
    self.animDict = data.animDict
    self.animName = data.animName
    self.useTarget = data.useTarget and WNPC.UseTarget
    self.useDrawText = data.useDrawText
    self.job = data.job
    self.grade = data.grade or 0
    self.label = data.label or 'Interact'
    self.drawKey = Keys[data.drawKey] or Keys[Config.DefaultInteractKey]

    self.ped = nil
    self.zoneId = nil

    self:register()
end

function NpcEntity:canInteract()
    if not self.job then return true end
    local job = Bridge.GetJob()
    return job.name == self.job and job.grade >= self.grade
end

function NpcEntity:playAnim()
    if not self.ped or not self.animDict or self.animDict == '' then return end
    lib.requestAnimDict(self.animDict)
    TaskPlayAnim(self.ped, self.animDict, self.animName, 8.0, -8.0, -1, 1, 0.0, false, false, false)
    RemoveAnimDict(self.animDict)
end

function NpcEntity:spawn()
    if self.ped and DoesEntityExist(self.ped) then return end

    local hash = joaat(self.model)
    if not IsModelValid(hash) then
        warn(('NPC "%s" has an invalid model: %s'):format(self.name, self.model))
        return
    end

    if not lib.requestModel(hash, 10000) then return end

    local ped = CreatePed(0, hash, self.coords.x, self.coords.y, self.coords.z, self.heading, false, true)
    SetModelAsNoLongerNeeded(hash)

    SetEntityHeading(ped, self.heading)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedDiesWhenInjured(ped, false)

    self.ped = ped
    self:playAnim()
end

function NpcEntity:despawn()
    if self.ped and DoesEntityExist(self.ped) then
        DeleteEntity(self.ped)
    end
    self.ped = nil
end

function NpcEntity:drawText(distance)
    if distance > Config.DrawTextDistance or not self:canInteract() then return end

    DrawText3D(self.coords + vec3(0.0, 0.0, 1.0), self.label, 0.4)

    if distance <= Config.InteractDistance and self.event and self.event ~= '' then
        if IsControlJustReleased(0, self.drawKey) then
            TriggerEvent(self.event)
        end
    end
end

function NpcEntity:addTarget()
    local option = {
        name = ('wnpc_%d'):format(self.id),
        icon = 'fas fa-hand',
        label = self.label,
        distance = Config.InteractDistance,
        onSelect = function()
            if self.event and self.event ~= '' then
                TriggerEvent(self.event)
            end
        end,
    }
    if self.job then
        option.groups = { [self.job] = self.grade }
    end

    self.zoneId = exports.ox_target:addBoxZone({
        coords = self.coords,
        size = vec3(1.0, 1.0, 2.5),
        rotation = self.heading,
        options = { option },
    })
end

function NpcEntity:register()
    if self.useTarget then
        self:addTarget()
    end

    local entity = self
    self.point = lib.points.new({
        coords = self.coords,
        distance = Config.SpawnDistance,
    })

    function self.point:onEnter()
        entity:spawn()
    end

    function self.point:onExit()
        entity:despawn()
    end

    if self.useDrawText then
        function self.point:nearby()
            entity:drawText(self.currentDistance)
        end
    end
end

function NpcEntity:destroy()
    self:despawn()
    if self.point then
        self.point:remove()
        self.point = nil
    end
    if self.zoneId then
        exports.ox_target:removeZone(self.zoneId)
        self.zoneId = nil
    end
end

NpcManager = {
    npcs = {},
}

function NpcManager.add(data)
    if NpcManager.npcs[data.id] then return end
    NpcManager.npcs[data.id] = NpcEntity:new(data)
end

function NpcManager.remove(id)
    local npc = NpcManager.npcs[id]
    if not npc then return end
    npc:destroy()
    NpcManager.npcs[id] = nil
end

function NpcManager.clear()
    for id, npc in pairs(NpcManager.npcs) do
        npc:destroy()
        NpcManager.npcs[id] = nil
    end
end

function NpcManager.getAll()
    local list = {}
    for _, npc in pairs(NpcManager.npcs) do
        list[#list + 1] = { id = npc.id, name = npc.name, coords = npc.coords }
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

function NpcManager.bootstrap()
    local list = lib.callback.await('wnpc:getAll', false)
    NpcManager.clear()
    for i = 1, #list do
        NpcManager.add(list[i])
    end
end

RegisterNetEvent('wnpc:add', function(data)
    NpcManager.add(data)
end)

RegisterNetEvent('wnpc:remove', function(id)
    NpcManager.remove(id)
end)

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    NpcManager.bootstrap()
end)

AddEventHandler('onClientResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    NpcManager.clear()
end)
