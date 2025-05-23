-- server.lua


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand('antilag', function(source, args, rawCommand)
    while ESX == nil do Wait(10) end
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    if #args < 1 then
        TriggerClientEvent('antilag:usage', source)
        return
    end
    local state = tostring(args[1]):lower()
    if state == 'true' then
        TriggerClientEvent('antilag:enable', source)
    elseif state == 'false' then
        TriggerClientEvent('antilag:disable', source)
    else
        TriggerClientEvent('antilag:usage', source)
    end
end, false)
