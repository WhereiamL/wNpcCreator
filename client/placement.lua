function StartPlacement(model)
    local hash = joaat(model)
    if not IsModelValid(hash) then
        lib.notify({ title = 'NPC Creator', description = 'Invalid model hash.', type = 'error' })
        return
    end
    if not lib.requestModel(hash, 10000) then return end

    local preview = CreatePed(0, hash, GetEntityCoords(cache.ped), 0.0, false, true)
    SetModelAsNoLongerNeeded(hash)
    SetEntityAlpha(preview, 150, false)
    SetEntityCollision(preview, false, false)
    FreezeEntityPosition(preview, true)
    SetEntityInvincible(preview, true)
    SetBlockingOfNonTemporaryEvents(preview, true)

    local heading = GetEntityHeading(cache.ped) + 0.0
    local result

    lib.showTextUI('[E] Place  \n[Q] Cancel  \n[←] Rotate left  \n[→] Rotate right', {
        position = 'left-center',
    })

    while true do
        Wait(0)
        local hit, _, coords = lib.raycast.cam(511, 4)

        if hit then
            SetEntityCoords(preview, coords.x, coords.y, coords.z, false, false, false, false)
            PlaceObjectOnGroundProperly(preview)
            SetEntityHeading(preview, heading)
        end

        if IsControlPressed(0, Keys.LEFT_ARROW) then
            heading = (heading - 2.0) % 360.0
            SetEntityHeading(preview, heading)
        elseif IsControlPressed(0, Keys.RIGHT_ARROW) then
            heading = (heading + 2.0) % 360.0
            SetEntityHeading(preview, heading)
        end

        if hit and IsControlJustReleased(0, Keys.E) then
            local placed = GetEntityCoords(preview)
            result = { coords = { x = placed.x, y = placed.y, z = placed.z }, heading = heading }
            break
        end

        if IsControlJustReleased(0, Keys.Q) then
            break
        end
    end

    lib.hideTextUI()
    if DoesEntityExist(preview) then
        DeleteEntity(preview)
    end

    return result
end
