-- client.lua
local antilagActive = false

RegisterNetEvent('antilag:enable')
AddEventHandler('antilag:enable', function()
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then
        TriggerEvent('chat:addMessage', { args = { '[Antilag]', 'Du musst im Fahrzeug sitzen!' } })
        return
    end
    antilagActive = true
    TriggerEvent('chat:addMessage', { args = { '[Antilag]', 'Antilag aktiviert!' } })
    -- Dauerhafte Notify anzeigen
    Citizen.CreateThread(function()
        while antilagActive do
            -- Notify anzeigen
            SetTextFont(4)
            SetTextProportional(1)
            SetTextScale(0.45, 0.45)
            SetTextColour(255, 50, 50, 255)
            SetTextDropShadow(0, 0, 0, 0,255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("~r~Antilag Aktiv")
            EndTextCommandDisplayText(0.015, 0.8)
            local veh = GetVehiclePedIsIn(playerPed, false)
            -- Automatisch deaktivieren, wenn Spieler nicht mehr im Fahrzeug ist
            if not IsPedInAnyVehicle(playerPed, false) then
                antilagActive = false
                TriggerEvent('chat:addMessage', { args = { '[Antilag]', 'Antilag wurde automatisch deaktiviert (du bist ausgestiegen).' } })
                break
            end
            if veh ~= 0 and IsControlPressed(0, 71) then -- W / Gas
                for i = 1, 15 do
                    UseParticleFxAssetNextCall("core")
                    StartParticleFxNonLoopedOnEntity("veh_exhaust_flame", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, false, false, false)
                    StartParticleFxNonLoopedOnEntity("veh_exhaust_flame", veh, -0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, false, false, false)
                    PlaySoundFromEntity(-1, "Backfire", veh, "DLC_IE_VEHICLE_ENGINE_UPGRADES_SOUNDS", 0, 0)
                    -- Knall-Effekt (Explosion ohne Schaden an Umgebung, aber mit 1% Fahrzeugsdchaden)
                    -- 1% Schaden am Fahrzeug
                    local health = GetEntityHealth(veh)
                    local maxHealth = GetEntityMaxHealth(veh)
                    local newHealth = math.max(health - math.floor(maxHealth * 0.01), 100)
                    SetEntityHealth(veh, newHealth)
                    Wait(10)
                end
            end
            Wait(0)
        end
    end)
end)

RegisterNetEvent('antilag:disable')
AddEventHandler('antilag:disable', function()
    antilagActive = false
    TriggerEvent('chat:addMessage', { args = { '[Antilag]', 'Antilag deaktiviert!' } })
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsIn(playerPed, false)
        -- Audio zurücksetzen
        SetVehicleAudio(veh, "")
    end
end)

RegisterNetEvent('antilag:usage')
AddEventHandler('antilag:usage', function()
    TriggerEvent('chat:addMessage', { args = { '[Antilag]', 'Benutze /antilag true zum Aktivieren, /antilag false zum Deaktivieren.' } })
end)
