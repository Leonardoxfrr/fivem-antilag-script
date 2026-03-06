-- server.lua


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand('antilag', function(source, args, rawCommand)
    while ESX == nil do Wait(10) end
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    if #args < 1 then
        debugLog('Toggle requested by source=%s', source)
        TriggerClientEvent('antilag:toggle', source)
        return
    end

    local state = tostring(args[1]):lower()
    if state == 'true' or state == 'on' or state == '1' or state == 'enable' then
        debugLog('Enable requested by source=%s', source)
        TriggerClientEvent('antilag:enable', source)
    elseif state == 'false' or state == 'off' or state == '0' or state == '2' or state == 'disable' then
        debugLog('Disable requested by source=%s', source)
        TriggerClientEvent('antilag:disable', source)
    elseif state == 'toggle' or state == 't' then
        debugLog('Toggle requested by source=%s', source)
        TriggerClientEvent('antilag:toggle', source)
    else
        debugLog('Invalid argument from source=%s value=%s', source, state)
        TriggerClientEvent('antilag:usage', source)
    end
end, false)
