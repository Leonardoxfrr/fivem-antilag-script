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
                    -- Test: Nur HUD Sound abspielen, um zu prüfen ob natives funktionieren
                    PlaySoundFrontend(-1, "ERROR", "HUD_AMMO_SHOP_SOUNDSET", true)
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
