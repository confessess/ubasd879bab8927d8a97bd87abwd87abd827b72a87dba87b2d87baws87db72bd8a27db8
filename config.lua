--// config.lua
--// All tunable settings in one place

return {
    -- Combat
    FrameTP = true,
    OneFrameDelay = false,
    RapidFire = true,
    
    -- Visuals
    FOV_Enabled = true,
    FOV_Radius = 250,
    FOV_Color = Color3.fromRGB(255, 80, 80),
    Tracers = true,
    Tracer_Color = Color3.fromRGB(255, 60, 60),
    Hitmarkers = true,
    Highlights = true,
    
    -- Targeting
    TargetPart = "Head",
    TargetMode = "Closest", -- "Closest" or "Selected"
    
    -- UI
    ToggleKey = Enum.KeyCode.RightShift,
    ShowHotkeys = true,
    
    -- Internal
    MaxTargetDistance = 9999999999999,
}