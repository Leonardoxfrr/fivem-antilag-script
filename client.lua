-- client.lua
local antilagActive = false
local antilagLoopRunning = false
local ptfxLoaded = false
local lastBackfireAt = 0
local lastTriggerDebugAt = 0
local activeFxName = nil
local lastThrottlePressed = false
local lastHighRpm = false

local cfg = (Config and Config.Client) or {}
local fxCfg = cfg.Fx or {}
local soundCfg = cfg.Sound or {}
local boostCfg = cfg.Boost or {}
local commandName = (Config and Config.CommandName) or 'antilag'

local PTFX_ASSET_NAME = fxCfg.Asset or 'core'
local FX_NAMES = fxCfg.Names or { 'veh_backfire', 'veh_exhaust_flame' }
local FX_SCALE = fxCfg.Scale or 1.5
local FX_OFFSET_X = fxCfg.OffsetX or 0.0
local FX_OFFSET_Y = fxCfg.OffsetY or 0.0
local FX_OFFSET_Z = fxCfg.OffsetZ or 0.0
local FX_ROT_X = fxCfg.RotX or 0.0
local FX_ROT_Y = fxCfg.RotY or 0.0
local FX_ROT_Z = fxCfg.RotZ or 0.0
local EXHAUST_BONE_NAMES = fxCfg.ExhaustBones or { 'exhaust', 'exhaust_2' }

local STATUS_TEXT = cfg.StatusText or '~r~Antilag Aktiv'
local STATUS_X = cfg.StatusX or 0.015
local STATUS_Y = cfg.StatusY or 0.8
local TRIGGER_CONTROL = cfg.TriggerControl or 71
local TRIGGER_THRESHOLD = cfg.TriggerThreshold or 0.15
local ONLY_DRIVER_CAN_TRIGGER = (cfg.OnlyDriverCanTrigger ~= false)
local TRIGGER_MODE = tostring(cfg.TriggerMode or 'hold'):lower()
local BACKFIRE_COOLDOWN_MS = cfg.CooldownMs or 900
local BACKFIRE_BURST_COUNT = cfg.BurstCount or 4
local BACKFIRE_BURST_DELAY_MS = cfg.BurstDelayMs or 70
local MIN_RPM = cfg.MinRpm or 0.72
local MIN_SPEED = cfg.MinSpeed or 1.0
local REQUIRE_RPM = (cfg.RequireRpm == true)
local REQUIRE_SPEED = (cfg.RequireSpeed == true)
local RPM_ZERO_FALLBACK = (cfg.RpmZeroFallback ~= false)
local RPM_ZERO_MIN_SPEED = cfg.RpmZeroMinSpeed or 0.3

local SOUND_ENABLED = (soundCfg.Enabled ~= false)
local SOUND_EVENTS = soundCfg.Events or {
    { Name = 'Explosion', Set = 'BASEEXPLOSIONSOUNDSET' }
}
local SOUND_COORD_RANGE = soundCfg.CoordRange or 140
local SOUND_COORD_FALLBACK = (soundCfg.CoordFallback ~= false)
local SOUND_FRONTEND_FALLBACK = soundCfg.FrontendFallback or {}
local SOUND_FRONTEND_ENABLED = (SOUND_FRONTEND_FALLBACK.Enabled ~= false)
local SOUND_FRONTEND_NAME = SOUND_FRONTEND_FALLBACK.Name or 'TIMER_STOP'
local SOUND_FRONTEND_SET = SOUND_FRONTEND_FALLBACK.Set or 'HUD_MINI_GAME_SOUNDSET'
local SOUND_NUI_FALLBACK = soundCfg.NuiFallback or {}
local SOUND_NUI_ENABLED = (SOUND_NUI_FALLBACK.Enabled ~= false)
local SOUND_NUI_VOLUME = SOUND_NUI_FALLBACK.Volume or 1.0
-- Safety default: boost is opt-in only.
local BOOST_ENABLED = (boostCfg.Enabled == true)
local BOOST_TORQUE_MULTIPLIER = boostCfg.TorqueMultiplier or 1.10
local BOOST_POWER_MULTIPLIER = boostCfg.PowerMultiplier or 10.0

local exhaustBoneCache = {}
local boostedVehicle = 0

local HAS_START_NETWORKED_FX_ON_BONE = (type(StartNetworkedParticleFxNonLoopedOnEntityBone) == 'function')
local HAS_START_FX_ON_BONE = (type(StartParticleFxNonLoopedOnEntityBone) == 'function')
local HAS_REMOVE_NAMED_PTFX_ASSET = (type(RemoveNamedPtfxAsset) == 'function')
local HAS_SET_VEHICLE_TORQUE = (type(SetVehicleEngineTorqueMultiplier) == 'function')
local HAS_SET_VEHICLE_POWER = (type(SetVehicleEnginePowerMultiplier) == 'function')

local function debugLog(message, ...)
    if not (Config and Config.Debug) then
        return
    end

    local formatted = message
    if select('#', ...) > 0 then
        formatted = message:format(...)
    end
    print(('[Antilag][Client] %s'):format(formatted))
end

local function notify(message)
    TriggerEvent('chat:addMessage', { args = { '[Antilag]', message } })
end

local function drawAntilagStatus()
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.45, 0.45)
    SetTextColour(255, 50, 50, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(STATUS_TEXT)
    EndTextCommandDisplayText(STATUS_X, STATUS_Y)
end

local function loadPtfxAsset()
    if ptfxLoaded then
        return true
    end

    RequestNamedPtfxAsset(PTFX_ASSET_NAME)
    local timeoutAt = GetGameTimer() + 2000

    while not HasNamedPtfxAssetLoaded(PTFX_ASSET_NAME) do
        Wait(0)
        if GetGameTimer() > timeoutAt then
            debugLog("Timed out while loading PTFX asset '%s'", PTFX_ASSET_NAME)
            return false
        end
    end

    ptfxLoaded = true
    debugLog("Loaded PTFX asset '%s'", PTFX_ASSET_NAME)
    return true
end

local function unloadPtfxAsset()
    if ptfxLoaded then
        if HAS_REMOVE_NAMED_PTFX_ASSET then
            RemoveNamedPtfxAsset(PTFX_ASSET_NAME)
        end
        ptfxLoaded = false
        debugLog("Unloaded PTFX asset '%s'", PTFX_ASSET_NAME)
    end
end

local function getExhaustBones(vehicle)
    local model = GetEntityModel(vehicle)
    local cachedBones = exhaustBoneCache[model]
    if cachedBones then
        return cachedBones
    end

    local bones = {}
    for _, boneName in ipairs(EXHAUST_BONE_NAMES) do
        local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
        if boneIndex ~= -1 then
            bones[#bones + 1] = boneIndex
        end
    end

    exhaustBoneCache[model] = bones
    debugLog("Vehicle model %s exhaust bones detected: %s", model, #bones)
    return bones
end

local function spawnBackfireFx(vehicle, bones)
    for _, fxName in ipairs(FX_NAMES) do
        local didSpawn = false

        if #bones > 0 then
            for _, boneIndex in ipairs(bones) do
                UseParticleFxAssetNextCall(PTFX_ASSET_NAME)
                local ok = false
                -- Prefer local FX first to avoid unnecessary network-side entity interaction.
                if HAS_START_FX_ON_BONE then
                    ok = StartParticleFxNonLoopedOnEntityBone(
                        fxName,
                        vehicle,
                        FX_OFFSET_X, FX_OFFSET_Y, FX_OFFSET_Z,
                        FX_ROT_X, FX_ROT_Y, FX_ROT_Z,
                        boneIndex,
                        FX_SCALE,
                        false, false, false
                    )
                end
                if (not ok) and HAS_START_NETWORKED_FX_ON_BONE then
                    ok = StartNetworkedParticleFxNonLoopedOnEntityBone(
                        fxName,
                        vehicle,
                        FX_OFFSET_X, FX_OFFSET_Y, FX_OFFSET_Z,
                        FX_ROT_X, FX_ROT_Y, FX_ROT_Z,
                        boneIndex,
                        FX_SCALE,
                        false, false, false
                    )
                end
                if ok then
                    didSpawn = true
                end
            end
        else
            UseParticleFxAssetNextCall(PTFX_ASSET_NAME)
            didSpawn = StartParticleFxNonLoopedOnEntity(
                fxName,
                vehicle,
                FX_OFFSET_X, FX_OFFSET_Y, FX_OFFSET_Z,
                FX_ROT_X, FX_ROT_Y, FX_ROT_Z,
                FX_SCALE,
                false, false, false
            )
        end

        if didSpawn then
            if activeFxName ~= fxName then
                activeFxName = fxName
                debugLog("Using FX '%s' for backfire", fxName)
            end
            return true
        end
    end

    return false
end

local function playBackfireSound(vehicle, bones)
    if not SOUND_ENABLED then
        return
    end

    local coords = GetEntityCoords(vehicle)
    local soundX, soundY, soundZ = coords.x, coords.y, coords.z

    local firstBone = nil
    if bones and #bones > 0 then
        firstBone = bones[1]
    else
        local byName = GetEntityBoneIndexByName(vehicle, EXHAUST_BONE_NAMES[1])
        if byName ~= -1 then
            firstBone = byName
        end
    end

    if firstBone then
        local boneCoords = GetWorldPositionOfEntityBone(vehicle, firstBone)
        soundX, soundY, soundZ = boneCoords.x, boneCoords.y, boneCoords.z
    end

    for _, soundEvent in ipairs(SOUND_EVENTS) do
        local name = soundEvent.Name
        local set = soundEvent.Set
        if name and set then
            local soundId = GetSoundId()
            PlaySoundFromEntity(soundId, name, vehicle, set, false, 0)
            ReleaseSoundId(soundId)

            if SOUND_COORD_FALLBACK then
                PlaySoundFromCoord(-1, name, soundX, soundY, soundZ, set, false, SOUND_COORD_RANGE, false)
            end
        end
    end

    if SOUND_FRONTEND_ENABLED then
        PlaySoundFrontend(-1, SOUND_FRONTEND_NAME, SOUND_FRONTEND_SET, true)
    end

    if SOUND_NUI_ENABLED then
        SendNUIMessage({
            type = 'antilag_pop',
            volume = SOUND_NUI_VOLUME
        })
    end
end

local function resetVehicleBoost(vehicle)
    if not BOOST_ENABLED then
        return
    end
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    if HAS_SET_VEHICLE_TORQUE then
        SetVehicleEngineTorqueMultiplier(vehicle, 1.0)
    end
    if HAS_SET_VEHICLE_POWER then
        SetVehicleEnginePowerMultiplier(vehicle, 0.0)
    end
end

local function clearBoostState()
    if boostedVehicle ~= 0 then
        resetVehicleBoost(boostedVehicle)
        debugLog('Boost reset on vehicle=%s', boostedVehicle)
    end
    boostedVehicle = 0
end

local function applyVehicleBoost(vehicle)
    if not BOOST_ENABLED then
        return
    end
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    if boostedVehicle ~= 0 and boostedVehicle ~= vehicle then
        resetVehicleBoost(boostedVehicle)
        debugLog('Boost moved from vehicle=%s to vehicle=%s', boostedVehicle, vehicle)
    end

    if boostedVehicle ~= vehicle then
        boostedVehicle = vehicle
        debugLog(
            'Boost active vehicle=%s torque=%.2f power=%.2f',
            vehicle,
            BOOST_TORQUE_MULTIPLIER,
            BOOST_POWER_MULTIPLIER
        )
    end

    -- Some natives are expected to be set repeatedly while active.
    if HAS_SET_VEHICLE_TORQUE then
        SetVehicleEngineTorqueMultiplier(vehicle, BOOST_TORQUE_MULTIPLIER)
    end
    if HAS_SET_VEHICLE_POWER then
        SetVehicleEnginePowerMultiplier(vehicle, BOOST_POWER_MULTIPLIER)
    end
end

local function playBackfireBurst(vehicle)
    local bones = getExhaustBones(vehicle)
    local spawnedAny = false

    for _ = 1, BACKFIRE_BURST_COUNT do
        local didSpawn = spawnBackfireFx(vehicle, bones)
        if didSpawn then
            spawnedAny = true
        end

        playBackfireSound(vehicle, bones)

        Wait(BACKFIRE_BURST_DELAY_MS)
    end

    if not spawnedAny then
        debugLog(
            "No backfire FX spawned. Asset='%s', fxCandidates=%s, bones=%s",
            PTFX_ASSET_NAME,
            #FX_NAMES,
            #bones
        )
    end
end

local function shouldTriggerBackfire(triggerPressed, highRpm)
    if TRIGGER_MODE == 'hold' then
        return triggerPressed and highRpm
    end

    if TRIGGER_MODE == 'liftoff' then
        return (not triggerPressed) and lastThrottlePressed and lastHighRpm
    end

    return triggerPressed and highRpm and (not lastHighRpm)
end

local function isDriver(ped, vehicle)
    return GetPedInVehicleSeat(vehicle, -1) == ped
end

local function startAntilagLoop()
    if antilagLoopRunning then
        return
    end

    antilagLoopRunning = true
    CreateThread(function()
        while antilagActive do
            local playerPed = PlayerPedId()
            if not IsPedInAnyVehicle(playerPed, false) then
                antilagActive = false
                notify('Antilag wurde automatisch deaktiviert (du bist ausgestiegen).')
                break
            end
            if veh ~= 0 and IsControlPressed(0, 71) then -- W / Gas
                TriggerEvent('chat:addMessage', { args = { '[Antilag]', 'Backfire-Test läuft!' } })
                for i = 1, 15 do
                    -- Partikeleffekt laden
                    RequestNamedPtfxAsset("core")
                    while not HasNamedPtfxAssetLoaded("core") do
                        Wait(1)
                    end
                    UseParticleFxAssetNextCall("core")
                    StartParticleFxNonLoopedOnEntity("veh_exhaust_flame", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, false, false, false)
                    -- TEST: Verschiedene Soundsets ausprobieren
                    -- 1. Explosion
                    PlaySoundFromEntity(-1, "Explosion", veh, "BASEEXPLOSIONSOUNDSET", 0, 0)
                    -- 2. Alternativ: Knall aus anderem Set
                    -- PlaySoundFromEntity(-1, "Bomb_03", veh, "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 0, 0)
                    -- 3. Alternativ: Schuss
                    -- PlaySoundFromEntity(-1, "Fire", veh, "DLC_SM_Countermeasures_Sounds", 0, 0)
                    Wait(100)
                end
            end
            Wait(0)
        end

        antilagLoopRunning = false
        unloadPtfxAsset()
        clearBoostState()
        debugLog('Antilag loop stopped')
    end)
end

RegisterNetEvent('antilag:enable', function()
    if antilagActive then
        notify('Antilag ist bereits aktiviert.')
        return
    end

    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then
        notify('Du musst im Fahrzeug sitzen.')
        return
    end

    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if ONLY_DRIVER_CAN_TRIGGER and vehicle ~= 0 and (not isDriver(playerPed, vehicle)) then
        notify('Du musst Fahrer sein, um Antilag zu aktivieren.')
        return
    end

    if not loadPtfxAsset() then
        notify('Partikeleffekt konnte nicht geladen werden. Bitte erneut versuchen.')
        return
    end

    antilagActive = true
    lastBackfireAt = 0
    lastTriggerDebugAt = 0
    activeFxName = nil
    lastThrottlePressed = false
    lastHighRpm = false
    clearBoostState()

    if vehicle ~= 0 then
        local bones = getExhaustBones(vehicle)
        debugLog('Enable antilag. Vehicle=%s, exhaustBones=%s', vehicle, #bones)
    end
    if BOOST_ENABLED then
        debugLog('Boost is enabled. On some servers this can be flagged by anti-cheat.')
    end

    notify('Antilag aktiviert.')
    startAntilagLoop()
end)

RegisterNetEvent('antilag:disable', function()
    if not antilagActive then
        notify('Antilag ist bereits deaktiviert.')
        return
    end

    antilagActive = false
    unloadPtfxAsset()
    clearBoostState()
    lastThrottlePressed = false
    lastHighRpm = false
    notify('Antilag deaktiviert.')
end)

RegisterNetEvent('antilag:toggle', function()
    if antilagActive then
        TriggerEvent('antilag:disable')
        return
    end
    TriggerEvent('antilag:enable')
end)

RegisterNetEvent('antilag:usage', function()
    notify(
        ('Benutze /%s (toggle), /%s true|on|1 zum Aktivieren, /%s false|off|0|2 zum Deaktivieren.'):format(
            commandName,
            commandName,
            commandName
        )
    )
end)
