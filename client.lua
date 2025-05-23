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
            if veh ~= 0 and IsControlPressed(0, 71) then -- W / Gas
                -- Lauteren Sound simulieren
                StartVehicleHorn(veh, 100, "HELDDOWN", false)
                -- Flammen und Knall (nur optisch, für echtes Tuning weitere Effekte nötig)
                -- Hier kann man z.B. Partikeleffekte einbauen
                -- Beispiel: PlaySoundFromEntity(-1, "Backfire", veh, 0, 0, 0)
                -- Lautstärke erhöhen
                SetVehicleAudio(veh, "monster")
                -- 15x Backfire-Effekt
                for i = 1, 15 do
                    UseParticleFxAssetNextCall("core")
                    StartParticleFxNonLoopedOnEntity("veh_exhaust_flame", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, false, false, false)
                    StartParticleFxNonLoopedOnEntity("veh_exhaust_flame", veh, -0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, false, false, false)
                    -- Lauten Backfire-Sound abspielen
                    PlaySoundFromEntity(-1, "Backfire", veh, "DLC_IE_VEHICLE_ENGINE_UPGRADES_SOUNDS", 0, 0)
                    Wait(10) -- kleine Pause für sichtbare/separate Effekte
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
