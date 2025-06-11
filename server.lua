-- server.lua


RegisterCommand('antilag', function(source, args)
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
