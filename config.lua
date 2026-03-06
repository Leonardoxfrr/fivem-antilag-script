Config = {}

-- Enables verbose logs in F8/client console and server console.
Config.Debug = false

Config.CommandName = 'antilag'

Config.Client = {
    StatusText = '~r~Antilag Aktiv',
    StatusX = 0.015,
    StatusY = 0.8,

    TriggerControl = 71,      -- W / gas
    TriggerThreshold = 0.15,  -- analog input threshold
    -- Safety: only the driver can trigger antlag logic.
    OnlyDriverCanTrigger = true,
    -- Modes: hold | rise | liftoff
    -- hold: while throttle + rpm condition is true
    -- rise: only when entering high-rpm zone
    -- liftoff: when throttle is released at high rpm
    TriggerMode = 'hold',
    -- Gate checks are off by default so it still works on vehicles with bad RPM/speed reporting.
    RequireRpm = false,
    RequireSpeed = false,
    -- If RPM is stuck at 0.0 on a vehicle, use throttle+speed as fallback.
    RpmZeroFallback = true,
    RpmZeroMinSpeed = 0.3,
    CooldownMs = 900,

    BurstCount = 4,
    BurstDelayMs = 70,
    MinRpm = 0.72,
    MinSpeed = 1.0,

    Fx = {
        Asset = 'core',
        -- First valid effect name is used.
        Names = {
            'veh_backfire',
            'veh_exhaust_flame'
        },
        Scale = 1.5,
        OffsetX = 0.0,
        OffsetY = 0.0,
        OffsetZ = 0.0,
        RotX = 0.0,
        RotY = 0.0,
        RotZ = 0.0,
        ExhaustBones = {
            'exhaust',
            'exhaust_2',
            'exhaust_3',
            'exhaust_4',
            'exhaust_5',
            'exhaust_6',
            'exhaust_7',
            'exhaust_8',
            'exhaust_9',
            'exhaust_10',
            'exhaust_11',
            'exhaust_12',
            'exhaust_13',
            'exhaust_14',
            'exhaust_15',
            'exhaust_16'
        }
    },

    Sound = {
        Enabled = true,
        CoordRange = 140,
        Events = {
            { Name = 'Explosion', Set = 'BASEEXPLOSIONSOUNDSET' },
            { Name = 'Bomb_03', Set = 'DLC_HEISTS_BIOLAB_FINALE_SOUNDS' }
        },
        FrontendFallback = {
            Enabled = false,
            Name = 'TIMER_STOP',
            Set = 'HUD_MINI_GAME_SOUNDSET'
        },
        NuiFallback = {
            Enabled = true,
            Volume = 1.6
        },
        CoordFallback = true,
        ExplosionFallback = {
            -- Safety: keep disabled. Explosion natives can still damage vehicles.
            Enabled = false,
            Type = 2,
            DamageScale = 2.0,
            Audible = true,
            Invisible = false,
            CameraShake = 0.0,
            NoDamage = true
        }
    },

    Boost = {
        -- Safety default off: some anticheats may delete/despawn vehicles
        -- when power/torque natives are used repeatedly.
        Enabled = false,
        -- GTA native range is different between torque/power.
        -- Torque is multiplier (1.0 = stock), 1.10 ~= +10%.
        TorqueMultiplier = 1.10,
        -- Power multiplier uses GTA unit; 10.0 is a light boost.
        PowerMultiplier = 10.0
    }
}
