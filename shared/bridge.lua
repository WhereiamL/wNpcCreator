WNPC = WNPC or {}

local function detectFramework()
    if Config.Framework and Config.Framework ~= 'auto' then
        return Config.Framework
    end
    if GetResourceState('es_extended') == 'started' then return 'esx' end
    if GetResourceState('qbx_core') == 'started' then return 'qbx' end
    if GetResourceState('qb-core') == 'started' then return 'qb' end
    return 'standalone'
end

WNPC.Framework = detectFramework()
WNPC.UseTarget = GetResourceState('ox_target') == 'started'
