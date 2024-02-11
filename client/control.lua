keys = {
    ["ESCAPE"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["TILDE"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["MINUS"] = 84, ["EQUALS"] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["LEFT_BRACKET"] = 39, ["RIGHT_BRACKET"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFT_SHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFT_CTRL"] = 36, ["LEFT_ALT"] = 19, ["SPACE"] = 22, ["RIGHT_CTRL"] = 70,
    ["HOME"] = 213, ["PAGE_UP"] = 10, ["PAGE_DOWN"] = 11, ["DELETE"] = 178,
    ["LEFT_ARROW"] = 174, ["RIGHT_ARROW"] = 175, ["UP_ARROW"] = 27, ["DOWN_ARROW"] = 173,
    ["NUM_ENTER"] = 201, ["NUM4"] = 108, ["NUM5"] = 60, ["NUM6"] = 107, ["NUM_PLUS"] = 96, ["NUM_MINUS"] = 97, ["NUM7"] = 117, ["NUM8"] = 61, ["NUM9"] = 118
}

local IsPlacingNPC = false
local previewedNPC = nil
local heading = 0

AddEventHandler("control:CreateEntity", function(data)
    if IsPlacingNPC then return end
    CreateNPC(data.hash, data)
end)

function CreateNPC(model, stored)
    IsPlacingNPC = true
    lib.requestModel(model)

    previewedNPC = CreatePed(4, model, GetEntityCoords(cache.ped), heading, false, true)

    SetEntityAlpha(previewedNPC, 150, false)
    SetEntityCollision(previewedNPC, false, false)
    FreezeEntityPosition(previewedNPC, true)
    SetEntityInvincible(previewedNPC, true)
    SetBlockingOfNonTemporaryEvents(previewedNPC, true)
    lib.showTextUI([[
        [E] - Place object
        [Q] - Quit
        [Arrow Left] - Rotate left
        [Arrow Right] - Rotate right
    ]])
    
    while IsPlacingNPC do
        local hit, _, coords, _, _ = lib.raycast.cam(1, 4)

        if hit then
            SetEntityCoords(previewedNPC, coords.x, coords.y, coords.z)
            PlaceObjectOnGroundProperly(previewedNPC)
            local distanceCheck = #(coords - GetEntityCoords(cache.ped))

            if IsControlJustPressed(0, 44) then CancelPlacement() end

            if IsControlPressed(0, 174) then -- left arrow
                heading = heading - 1.0
                SetEntityHeading(previewedNPC, heading)
            end

            if IsControlPressed(0, 175) then -- right arrow
                heading = heading + 1.0
                SetEntityHeading(previewedNPC, heading)
            end

            if IsControlJustPressed(0, 38) then
                PlaceSpawnedNPC(coords, model, stored)
            end
        end
        Wait(0)
    end
end

function PlaceSpawnedNPC(coords, model, stored)
    lib.hideTextUI()
    IsPlacingNPC = false
    DeleteEntity(previewedNPC)
    TriggerServerEvent("insertData", coords, model, stored, heading)
end

function CancelPlacement()
    if previewedNPC then
        DeleteEntity(previewedNPC)
        previewedNPC = nil
    end
    IsPlacingNPC = false
    lib.hideTextUI()
end


function drawText3D(coords, text, scale2, r, g, b, a)
    local processedText = text:gsub("\\n", "\n")
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local textScale = scale * fov * scale2

    SetTextScale(0.35, textScale)
    SetTextFont(6)
    SetTextProportional(1)
    SetTextColour(r or 255, g or 255, b or 255, a or 255)
    SetTextDropShadow()
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(processedText)
    SetDrawOrigin(coords, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end
