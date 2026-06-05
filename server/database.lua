Database = {}

local TABLE = 'wnpc_creator'

local SCHEMA = ([[
CREATE TABLE IF NOT EXISTS `%s` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `model` VARCHAR(100) NOT NULL,
    `event` VARCHAR(255) DEFAULT NULL,
    `pos_x` FLOAT NOT NULL,
    `pos_y` FLOAT NOT NULL,
    `pos_z` FLOAT NOT NULL,
    `heading` FLOAT NOT NULL DEFAULT 0,
    `anim_dict` VARCHAR(100) DEFAULT NULL,
    `anim_name` VARCHAR(100) DEFAULT NULL,
    `use_target` TINYINT(1) NOT NULL DEFAULT 0,
    `use_drawtext` TINYINT(1) NOT NULL DEFAULT 0,
    `job` VARCHAR(100) DEFAULT NULL,
    `grade` INT NOT NULL DEFAULT 0,
    `label` VARCHAR(255) DEFAULT NULL,
    `draw_key` VARCHAR(20) NOT NULL DEFAULT 'E',
    `created_by` VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `wnpc_name` (`name`)
);
]]):format(TABLE)

local function rowToNpc(row)
    return {
        id = row.id,
        name = row.name,
        model = row.model,
        event = row.event,
        coords = { x = row.pos_x, y = row.pos_y, z = row.pos_z },
        heading = row.heading,
        animDict = row.anim_dict,
        animName = row.anim_name,
        useTarget = row.use_target == 1,
        useDrawText = row.use_drawtext == 1,
        job = row.job,
        grade = row.grade,
        label = row.label,
        drawKey = row.draw_key,
    }
end

function Database.init()
    MySQL.query.await(SCHEMA)
    Database.migrate()
end

function Database.fetchAll()
    local rows = MySQL.query.await(('SELECT * FROM `%s`'):format(TABLE)) or {}
    local result = {}
    for i = 1, #rows do
        result[i] = rowToNpc(rows[i])
    end
    return result
end

function Database.insert(data, creator)
    return MySQL.insert.await(([[
        INSERT INTO `%s`
            (name, model, event, pos_x, pos_y, pos_z, heading, anim_dict, anim_name,
             use_target, use_drawtext, job, grade, label, draw_key, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]]):format(TABLE), {
        data.name, data.model, data.event,
        data.coords.x, data.coords.y, data.coords.z, data.heading,
        data.animDict, data.animName,
        data.useTarget and 1 or 0, data.useDrawText and 1 or 0,
        data.job, data.grade, data.label, data.drawKey, creator,
    })
end

function Database.delete(id)
    return MySQL.update.await(('DELETE FROM `%s` WHERE id = ?'):format(TABLE), { id })
end

function Database.migrate()
    local file = LoadResourceFile(GetCurrentResourceName(), 'npcData.json')
    if not file then return end

    local ok, decoded = pcall(json.decode, file)
    if not ok or type(decoded) ~= 'table' or #decoded == 0 then return end

    local existing = MySQL.scalar.await(('SELECT COUNT(*) FROM `%s`'):format(TABLE))
    if existing and existing > 0 then return end

    for i = 1, #decoded do
        local n = decoded[i]
        local coords = n.coords or {}
        Database.insert({
            name = n.name,
            model = n.hash,
            event = (n.event ~= '' and n.event) or nil,
            coords = { x = coords.x + 0.0, y = coords.y + 0.0, z = coords.z + 0.0 },
            heading = (n.heading or 0.0) + 0.0,
            animDict = n.animDict,
            animName = n.animName,
            useTarget = n.useOxTarget == true,
            useDrawText = n.useDrawText == true,
            job = (n.job and n.job ~= false) and n.job or nil,
            grade = tonumber(n.grade) or 0,
            label = n.oxTargetLabel,
            drawKey = n.drawTextKey or Config.DefaultInteractKey,
        }, 'migration')
    end

    SaveResourceFile(GetCurrentResourceName(), 'npcData.json', '[]', -1)
    print(('[wNpcCreator] Migrated %d NPC(s) from npcData.json to SQL.'):format(#decoded))
end
