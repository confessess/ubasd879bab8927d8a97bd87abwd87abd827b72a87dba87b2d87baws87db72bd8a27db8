return {
    FrameTP = true,
    OneFrameDelay = false,
    RapidFire = true,
    FOV_Enabled = true,
    FOV_Radius = 250,
    FOV_Color = Color3.fromRGB(255, 80, 80),
    Tracers = true,
    Tracer_Color = Color3.fromRGB(255, 60, 60),
    Hitmarkers = true,
    Highlights = true,
    Spectate = false,
    TargetPart = "Head",
    TargetMode = "Closest",
    MaxTargetDistance = 5000000000000000,
    ToggleKey = Enum.KeyCode.RightShift,
    ShowHotkeys = true,

    -- AntiStomp
    AntiStomp = false,
    AntiStompMode = "Void",
    AntiStompThreshold = 50,

    -- Teleport Spam
    SpamEnabled = false,
    SpamRange = "Close",
    SpamCloseHeight = 350,
    SpamCloseRadius = 250,
    SpamCloseVerticalJitter = 50,
    SpamFarBase = Vector3.new(500000, 500000, 500000),
    SpamFarJitter = 5000,
    SpamSpeed = 1,
    SpamEnabledKey = nil,

    -- Auto Armor
    AutoArmor = false,
    AutoArmorOnDamage = false,
    AutoArmorPos = Vector3.new(-934.12, -25.38, 571.02),
    AutoArmorTriggerHealth = 50,
    AutoArmorCooldown = 1,

    -- Farm
    FarmEnabled = false,
    FarmDistance = 12,
    FarmVerticalOffset = 0,
    FarmPullSpeed = 1,
    FarmEnabledKey = nil,

    -- Toggle hotkeys
    FrameTPKey = nil,
    OneFrameDelayKey = nil,
    RapidFireKey = nil,
    SpectateKey = nil,
    AntiStompKey = nil,
}