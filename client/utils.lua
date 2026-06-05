Keys = {
    ['ESCAPE'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['TILDE'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['MINUS'] = 84, ['EQUALS'] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['LEFT_BRACKET'] = 39, ['RIGHT_BRACKET'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFT_SHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFT_CTRL'] = 36, ['LEFT_ALT'] = 19, ['SPACE'] = 22, ['RIGHT_CTRL'] = 70,
    ['HOME'] = 213, ['PAGE_UP'] = 10, ['PAGE_DOWN'] = 11, ['DELETE'] = 178,
    ['LEFT_ARROW'] = 174, ['RIGHT_ARROW'] = 175, ['UP_ARROW'] = 27, ['DOWN_ARROW'] = 173,
    ['NUM_ENTER'] = 201, ['NUM4'] = 108, ['NUM5'] = 60, ['NUM6'] = 107, ['NUM_PLUS'] = 96, ['NUM_MINUS'] = 97, ['NUM7'] = 117, ['NUM8'] = 61, ['NUM9'] = 118,
}

function GetKeyOptions()
    local options = {}
    for label, code in pairs(Keys) do
        options[#options + 1] = { value = label, label = label, code = code }
    end
    table.sort(options, function(a, b) return a.label < b.label end)
    return options
end

function DrawText3D(coords, text, scale)
    local processed = text:gsub('\\n', '\n')
    local dist = #(coords - GetGameplayCamCoord())
    local fov = (1 / GetGameplayCamFov()) * 100
    local size = (1 / dist) * 2 * fov * (scale or 0.4)

    SetTextScale(0.35, size)
    SetTextFont(6)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow()
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextOutline()
    SetTextCentre(true)

    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(processed)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end
