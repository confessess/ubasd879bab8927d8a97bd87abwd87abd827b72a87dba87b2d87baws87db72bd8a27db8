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
    
    -- Teleport Spam
    SpamEnabled = false,
    SpamRange = "Close",
    SpamCloseHeight = 350,
    SpamCloseRadius = 250,
    SpamCloseVerticalJitter = 50,
    SpamFarBase = Vector3.new(500000, 500000, 500000),
    SpamFarJitter = 5000,
    SpamEnabledKey = nil,
    
    -- Toggle hotkeys
    FrameTPKey = nil,
    OneFrameDelayKey = nil,
    RapidFireKey = nil,
    SpectateKey = nil,
    AntiStompKey = nil,
}