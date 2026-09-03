local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local World = {
    Config = nil,
    Connection = nil,
    OriginalValues = {},
    ActiveSky = nil,
    ActiveAtmosphere = nil,
    LastSkyTheme = nil,
    OriginalSky = nil,
    OriginalAtmosphere = nil,
}

function World.SetConfig(config)
    World.Config = config
end

local function SaveOriginal(name, getter)
    if World.OriginalValues[name] == nil then
        World.OriginalValues[name] = getter()
    end
end

local function RestoreOriginal(name, setter)
    if World.OriginalValues[name] ~= nil then
        setter(World.OriginalValues[name])
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- FULL BRIGHT
-- ═════════════════════════════════════════════════════════════════════════════

local function ApplyFullbright()
    local Config = World.Config
    SaveOriginal("Brightness", function() return Lighting.Brightness end)
    SaveOriginal("GlobalShadows", function() return Lighting.GlobalShadows end)
    SaveOriginal("Ambient", function() return Lighting.Ambient end)
    SaveOriginal("OutdoorAmbient", function() return Lighting.OutdoorAmbient end)
    SaveOriginal("ClockTime", function() return Lighting.ClockTime end)

    Lighting.Brightness = Config.World_Brightness or 10
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.ClockTime = 12
end

local function RemoveFullbright()
    RestoreOriginal("Brightness", function(v) Lighting.Brightness = v end)
    RestoreOriginal("GlobalShadows", function(v) Lighting.GlobalShadows = v end)
    RestoreOriginal("Ambient", function(v) Lighting.Ambient = v end)
    RestoreOriginal("OutdoorAmbient", function(v) Lighting.OutdoorAmbient = v end)
    RestoreOriginal("ClockTime", function(v) Lighting.ClockTime = v end)
end

-- ═════════════════════════════════════════════════════════════════════════════
-- NO FOG
-- ═════════════════════════════════════════════════════════════════════════════

local function ApplyNoFog()
    SaveOriginal("FogStart", function() return Lighting.FogStart end)
    SaveOriginal("FogEnd", function() return Lighting.FogEnd end)
    SaveOriginal("FogColor", function() return Lighting.FogColor end)

    Lighting.FogStart = 0
    Lighting.FogEnd = 999999
    Lighting.FogColor = Color3.fromRGB(255, 255, 255)
end

local function RemoveNoFog()
    RestoreOriginal("FogStart", function(v) Lighting.FogStart = v end)
    RestoreOriginal("FogEnd", function(v) Lighting.FogEnd = v end)
    RestoreOriginal("FogColor", function(v) Lighting.FogColor = v end)
end

-- ═════════════════════════════════════════════════════════════════════════════
-- CUSTOM TIME
-- ═════════════════════════════════════════════════════════════════════════════

local function ApplyCustomTime()
    local Config = World.Config
    SaveOriginal("ClockTime", function() return Lighting.ClockTime end)
    Lighting.ClockTime = Config.World_TimeOfDay or 12
end

local function RemoveCustomTime()
    RestoreOriginal("ClockTime", function(v) Lighting.ClockTime = v end)
end

-- ═════════════════════════════════════════════════════════════════════════════
-- NO SHADOWS
-- ═════════════════════════════════════════════════════════════════════════════

local function ApplyNoShadows()
    SaveOriginal("GlobalShadows", function() return Lighting.GlobalShadows end)
    Lighting.GlobalShadows = false
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("ShadowMap") then v.Enabled = false end
    end
end

local function RemoveNoShadows()
    RestoreOriginal("GlobalShadows", function(v) Lighting.GlobalShadows = v end)
end

-- ═════════════════════════════════════════════════════════════════════════════
-- NO ATMOSPHERE
-- ═════════════════════════════════════════════════════════════════════════════

local function ApplyNoAtmosphere()
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("Atmosphere") then
            if not v:GetAttribute("ZeeHoodHidden") then
                v:SetAttribute("ZeeHoodHidden", true)
                v:SetAttribute("ZeeHoodOldDensity", v.Density)
                v.Density = 0
            end
        end
    end
end

local function RemoveNoAtmosphere()
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("Atmosphere") and v:GetAttribute("ZeeHoodHidden") then
            v.Density = v:GetAttribute("ZeeHoodOldDensity") or v.Density
            v:SetAttribute("ZeeHoodHidden", nil)
            v:SetAttribute("ZeeHoodOldDensity", nil)
        end
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- NO SUN RAYS
-- ═════════════════════════════════════════════════════════════════════════════

local function ApplyNoSunRays()
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("SunRaysEffect") then
            if not v:GetAttribute("ZeeHoodHidden") then
                v:SetAttribute("ZeeHoodHidden", true)
                v:SetAttribute("ZeeHoodOldEnabled", v.Enabled)
                v.Enabled = false
            end
        end
    end
end

local function RemoveNoSunRays()
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("SunRaysEffect") and v:GetAttribute("ZeeHoodHidden") then
            v.Enabled = v:GetAttribute("ZeeHoodOldEnabled") or v.Enabled
            v:SetAttribute("ZeeHoodHidden", nil)
            v:SetAttribute("ZeeHoodOldEnabled", nil)
        end
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- NO COLOR CORRECTION
-- ═════════════════════════════════════════════════════════════════════════════

local function ApplyNoColorCorrection()
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("ColorCorrectionEffect") then
            if not v:GetAttribute("ZeeHoodHidden") then
                v:SetAttribute("ZeeHoodHidden", true)
                v:SetAttribute("ZeeHoodOldEnabled", v.Enabled)
                v.Enabled = false
            end
        end
    end
end

local function RemoveNoColorCorrection()
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("ColorCorrectionEffect") and v:GetAttribute("ZeeHoodHidden") then
            v.Enabled = v:GetAttribute("ZeeHoodOldEnabled") or v.Enabled
            v:SetAttribute("ZeeHoodHidden", nil)
            v:SetAttribute("ZeeHoodOldEnabled", nil)
        end
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- LOW GFX
-- ═════════════════════════════════════════════════════════════════════════════

local function ApplyLowGFX()
    local Config = World.Config
    local level = Config.World_LowGFXLevel or 1

    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            if not part:GetAttribute("ZeeHoodOldCastShadow") then
                part:SetAttribute("ZeeHoodOldCastShadow", part.CastShadow)
            end
            part.CastShadow = false
        end
    end

    for _, emitter in pairs(Workspace:GetDescendants()) do
        if emitter:IsA("ParticleEmitter") or emitter:IsA("Trail") then
            if not emitter:GetAttribute("ZeeHoodOldEnabled") then
                emitter:SetAttribute("ZeeHoodOldEnabled", emitter.Enabled)
            end
            emitter.Enabled = false
        end
    end

    for _, beam in pairs(Workspace:GetDescendants()) do
        if beam:IsA("Beam") then
            if not beam:GetAttribute("ZeeHoodOldEnabled") then
                beam:SetAttribute("ZeeHoodOldEnabled", beam.Enabled)
            end
            beam.Enabled = false
        end
    end

    if level >= 2 then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end
end

local function RemoveLowGFX()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part:GetAttribute("ZeeHoodOldCastShadow") ~= nil then
            part.CastShadow = part:GetAttribute("ZeeHoodOldCastShadow")
            part:SetAttribute("ZeeHoodOldCastShadow", nil)
        end
    end

    for _, emitter in pairs(Workspace:GetDescendants()) do
        if (emitter:IsA("ParticleEmitter") or emitter:IsA("Trail")) and emitter:GetAttribute("ZeeHoodOldEnabled") ~= nil then
            emitter.Enabled = emitter:GetAttribute("ZeeHoodOldEnabled")
            emitter:SetAttribute("ZeeHoodOldEnabled", nil)
        end
    end

    for _, beam in pairs(Workspace:GetDescendants()) do
        if beam:IsA("Beam") and beam:GetAttribute("ZeeHoodOldEnabled") ~= nil then
            beam.Enabled = beam:GetAttribute("ZeeHoodOldEnabled")
            beam:SetAttribute("ZeeHoodOldEnabled", nil)
        end
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- SKY THEMES — Color-based, no image IDs needed
-- Uses Lighting properties + custom Atmosphere for unique looks
-- ═════════════════════════════════════════════════════════════════════════════

local SkyThemes = {
    Default = nil,
    Night = {
        ClockTime = 0,
        Ambient = Color3.fromRGB(30, 30, 60),
        OutdoorAmbient = Color3.fromRGB(20, 20, 50),
        FogColor = Color3.fromRGB(10, 10, 30),
        FogStart = 200,
        FogEnd = 2000,
        Brightness = 2,
        Atmosphere = {
            Density = 0.3,
            Offset = 0.1,
            Color = Color3.fromRGB(40, 40, 80),
            Decay = Color3.fromRGB(20, 20, 50),
            Glare = 0.2,
            Haze = 2,
        },
    },
    Sunset = {
        ClockTime = 17.5,
        Ambient = Color3.fromRGB(180, 120, 80),
        OutdoorAmbient = Color3.fromRGB(200, 140, 90),
        FogColor = Color3.fromRGB(255, 150, 80),
        FogStart = 100,
        FogEnd = 3000,
        Brightness = 5,
        Atmosphere = {
            Density = 0.35,
            Offset = 0.2,
            Color = Color3.fromRGB(255, 180, 100),
            Decay = Color3.fromRGB(255, 100, 50),
            Glare = 0.8,
            Haze = 5,
        },
    },
    BloodMoon = {
        ClockTime = 0,
        Ambient = Color3.fromRGB(80, 20, 20),
        OutdoorAmbient = Color3.fromRGB(100, 30, 30),
        FogColor = Color3.fromRGB(60, 10, 10),
        FogStart = 50,
        FogEnd = 1500,
        Brightness = 3,
        Atmosphere = {
            Density = 0.4,
            Offset = 0.15,
            Color = Color3.fromRGB(150, 30, 30),
            Decay = Color3.fromRGB(80, 10, 10),
            Glare = 0.5,
            Haze = 4,
        },
    },
    Galaxy = {
        ClockTime = 0,
        Ambient = Color3.fromRGB(60, 30, 100),
        OutdoorAmbient = Color3.fromRGB(40, 20, 80),
        FogColor = Color3.fromRGB(20, 10, 50),
        FogStart = 500,
        FogEnd = 5000,
        Brightness = 3,
        Atmosphere = {
            Density = 0.25,
            Offset = 0.05,
            Color = Color3.fromRGB(100, 50, 180),
            Decay = Color3.fromRGB(50, 20, 100),
            Glare = 0.3,
            Haze = 1.5,
        },
    },
    PurpleNebula = {
        ClockTime = 0,
        Ambient = Color3.fromRGB(80, 40, 120),
        OutdoorAmbient = Color3.fromRGB(60, 30, 100),
        FogColor = Color3.fromRGB(40, 20, 80),
        FogStart = 200,
        FogEnd = 3000,
        Brightness = 4,
        Atmosphere = {
            Density = 0.35,
            Offset = 0.1,
            Color = Color3.fromRGB(150, 80, 220),
            Decay = Color3.fromRGB(80, 40, 150),
            Glare = 0.4,
            Haze = 3,
        },
    },
    Vaporwave = {
        ClockTime = 18,
        Ambient = Color3.fromRGB(255, 100, 200),
        OutdoorAmbient = Color3.fromRGB(255, 120, 220),
        FogColor = Color3.fromRGB(255, 80, 180),
        FogStart = 50,
        FogEnd = 2000,
        Brightness = 6,
        Atmosphere = {
            Density = 0.4,
            Offset = 0.25,
            Color = Color3.fromRGB(255, 100, 200),
            Decay = Color3.fromRGB(200, 50, 150),
            Glare = 1,
            Haze = 6,
        },
    },
    DeepSpace = {
        ClockTime = 0,
        Ambient = Color3.fromRGB(5, 5, 15),
        OutdoorAmbient = Color3.fromRGB(3, 3, 10),
        FogColor = Color3.fromRGB(0, 0, 5),
        FogStart = 1000,
        FogEnd = 10000,
        Brightness = 1,
        Atmosphere = {
            Density = 0.1,
            Offset = 0,
            Color = Color3.fromRGB(10, 10, 30),
            Decay = Color3.fromRGB(5, 5, 15),
            Glare = 0,
            Haze = 0.5,
        },
    },
    GoldenHour = {
        ClockTime = 16.5,
        Ambient = Color3.fromRGB(220, 180, 120),
        OutdoorAmbient = Color3.fromRGB(240, 200, 140),
        FogColor = Color3.fromRGB(255, 200, 120),
        FogStart = 200,
        FogEnd = 4000,
        Brightness = 6,
        Atmosphere = {
            Density = 0.3,
            Offset = 0.15,
            Color = Color3.fromRGB(255, 200, 120),
            Decay = Color3.fromRGB(220, 150, 80),
            Glare = 0.7,
            Haze = 4,
        },
    },
    Storm = {
        ClockTime = 8,
        Ambient = Color3.fromRGB(60, 60, 70),
        OutdoorAmbient = Color3.fromRGB(50, 50, 60),
        FogColor = Color3.fromRGB(40, 40, 50),
        FogStart = 30,
        FogEnd = 800,
        Brightness = 2,
        Atmosphere = {
            Density = 0.6,
            Offset = 0.3,
            Color = Color3.fromRGB(80, 80, 100),
            Decay = Color3.fromRGB(50, 50, 60),
            Glare = 0.1,
            Haze = 8,
        },
    },
    Arctic = {
        ClockTime = 10,
        Ambient = Color3.fromRGB(180, 200, 220),
        OutdoorAmbient = Color3.fromRGB(200, 220, 240),
        FogColor = Color3.fromRGB(200, 220, 240),
        FogStart = 100,
        FogEnd = 2500,
        Brightness = 7,
        Atmosphere = {
            Density = 0.35,
            Offset = 0.2,
            Color = Color3.fromRGB(180, 200, 230),
            Decay = Color3.fromRGB(150, 180, 210),
            Glare = 0.4,
            Haze = 5,
        },
    },
    Inferno = {
        ClockTime = 14,
        Ambient = Color3.fromRGB(200, 80, 20),
        OutdoorAmbient = Color3.fromRGB(220, 100, 30),
        FogColor = Color3.fromRGB(180, 60, 10),
        FogStart = 50,
        FogEnd = 1500,
        Brightness = 5,
        Atmosphere = {
            Density = 0.45,
            Offset = 0.2,
            Color = Color3.fromRGB(255, 120, 30),
            Decay = Color3.fromRGB(200, 60, 10),
            Glare = 0.9,
            Haze = 6,
        },
    },
    NeonCity = {
        ClockTime = 20,
        Ambient = Color3.fromRGB(100, 50, 200),
        OutdoorAmbient = Color3.fromRGB(80, 40, 180),
        FogColor = Color3.fromRGB(60, 20, 120),
        FogStart = 80,
        FogEnd = 2000,
        Brightness = 5,
        Atmosphere = {
            Density = 0.4,
            Offset = 0.15,
            Color = Color3.fromRGB(150, 80, 255),
            Decay = Color3.fromRGB(100, 40, 200),
            Glare = 0.6,
            Haze = 5,
        },
    },
}

local function SaveOriginalSky()
    if World.OriginalSky ~= nil then return end
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            World.OriginalSky = child:Clone()
            break
        end
    end
end

local function SaveOriginalAtmosphere()
    if World.OriginalAtmosphere ~= nil then return end
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Atmosphere") then
            World.OriginalAtmosphere = child:Clone()
            break
        end
    end
end

local function RemoveCustomSky()
    if World.ActiveSky then
        World.ActiveSky:Destroy()
        World.ActiveSky = nil
    end
    if World.ActiveAtmosphere then
        World.ActiveAtmosphere:Destroy()
        World.ActiveAtmosphere = nil
    end
    for _, child in pairs(Lighting:GetChildren()) do
        if child.Name == "ZeeHoodSky" and child:IsA("Sky") then
            child:Destroy()
        end
        if child.Name == "ZeeHoodAtmosphere" and child:IsA("Atmosphere") then
            child:Destroy()
        end
    end
end

local function RestoreOriginalSky()
    RemoveCustomSky()
    if World.OriginalSky then
        local already = false
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA("Sky") and child.Name == World.OriginalSky.Name then
                already = true
                break
            end
        end
        if not already then
            World.OriginalSky:Clone().Parent = Lighting
        end
        World.OriginalSky = nil
    end
    if World.OriginalAtmosphere then
        local already = false
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA("Atmosphere") and child.Name == World.OriginalAtmosphere.Name then
                already = true
                break
            end
        end
        if not already then
            World.OriginalAtmosphere:Clone().Parent = Lighting
        end
        World.OriginalAtmosphere = nil
    end
end

local function ApplyCustomSky()
    local Config = World.Config
    local themeName = Config.World_SkyTheme or "Default"

    if World.LastSkyTheme == themeName then return end
    World.LastSkyTheme = themeName

    if themeName == "Default" then
        RestoreOriginalSky()
        return
    end

    local theme = SkyThemes[themeName]
    if not theme then return end

    SaveOriginalSky()
    SaveOriginalAtmosphere()
    RemoveCustomSky()

    -- Hide existing sky objects
    for _, child in pairs(Lighting:GetChildren()) do
        if (child:IsA("Sky") or child:IsA("Atmosphere")) and child.Name ~= "ZeeHoodSky" and child.Name ~= "ZeeHoodAtmosphere" then
            child.Parent = nil
        end
    end

    -- Create a plain dark sky as base
    local sky = Instance.new("Sky")
    sky.Name = "ZeeHoodSky"
    sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
    sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
    sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
    sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
    sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
    sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
    sky.StarCount = 0
    sky.SunAngularSize = 0
    sky.MoonAngularSize = 0
    sky.Parent = Lighting
    World.ActiveSky = sky

    -- Apply atmosphere for the theme color
    if theme.Atmosphere then
        local atm = Instance.new("Atmosphere")
        atm.Name = "ZeeHoodAtmosphere"
        atm.Density = theme.Atmosphere.Density
        atm.Offset = theme.Atmosphere.Offset
        atm.Color = theme.Atmosphere.Color
        atm.Decay = theme.Atmosphere.Decay
        atm.Glare = theme.Atmosphere.Glare
        atm.Haze = theme.Atmosphere.Haze
        atm.Parent = Lighting
        World.ActiveAtmosphere = atm
    end

    -- Apply lighting properties
    if theme.ClockTime then Lighting.ClockTime = theme.ClockTime end
    if theme.Ambient then Lighting.Ambient = theme.Ambient end
    if theme.OutdoorAmbient then Lighting.OutdoorAmbient = theme.OutdoorAmbient end
    if theme.FogColor then Lighting.FogColor = theme.FogColor end
    if theme.FogStart then Lighting.FogStart = theme.FogStart end
    if theme.FogEnd then Lighting.FogEnd = theme.FogEnd end
    if theme.Brightness then Lighting.Brightness = theme.Brightness end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- RENDER LOOP
-- ═════════════════════════════════════════════════════════════════════════════

local function OnRender()
    local Config = World.Config
    if not Config then return end

    if Config.World_Fullbright then ApplyFullbright() else RemoveFullbright() end
    if Config.World_NoFog then ApplyNoFog() else RemoveNoFog() end
    if Config.World_CustomTime then ApplyCustomTime() else RemoveCustomTime() end
    if Config.World_NoShadows then ApplyNoShadows() else RemoveNoShadows() end
    if Config.World_NoAtmosphere then ApplyNoAtmosphere() else RemoveNoAtmosphere() end
    if Config.World_NoSunRays then ApplyNoSunRays() else RemoveNoSunRays() end
    if Config.World_NoColorCorrection then ApplyNoColorCorrection() else RemoveNoColorCorrection() end
    if Config.World_LowGFX then ApplyLowGFX() else RemoveLowGFX() end
    ApplyCustomSky()
end

-- ═════════════════════════════════════════════════════════════════════════════
-- LIFECYCLE
-- ═════════════════════════════════════════════════════════════════════════════

function World.Init()
    if World.Connection then return end
    World.Connection = RunService.RenderStepped:Connect(OnRender)
end

function World.Cleanup()
    if World.Connection then
        World.Connection:Disconnect()
        World.Connection = nil
    end
    World.LastSkyTheme = nil
    RestoreOriginalSky()
    RemoveFullbright()
    RemoveNoFog()
    RemoveCustomTime()
    RemoveNoShadows()
    RemoveNoAtmosphere()
    RemoveNoSunRays()
    RemoveNoColorCorrection()
    RemoveLowGFX()
    World.OriginalValues = {}
end

return World