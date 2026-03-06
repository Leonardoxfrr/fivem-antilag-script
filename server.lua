-- server.lua

local commandName = (Config and Config.CommandName) or 'antilag'

local function debugLog(message, ...)
    if not (Config and Config.Debug) then
        return
    end

    local formatted = message
    if select('#', ...) > 0 then
        formatted = message:format(...)
    end
    print(('[Antilag][Server] %s'):format(formatted))
end

RegisterCommand(commandName, function(source, args)
    if source == 0 then
        print('[Antilag] Dieser Befehl kann nur im Spiel verwendet werden.')
        return
    end

    debugLog('Command from source=%s args=%s', source, #args)

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
