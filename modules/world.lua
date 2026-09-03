local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local World = {
    Config = nil,
    Connection = nil,
    OriginalValues = {},
    ActiveSky = nil,
    LastSkyTheme = nil,
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
-- SKYBOX / THEMES
-- ═════════════════════════════════════════════════════════════════════════════

local SkyThemes = {
    Default = nil,
    Night = {
        SkyboxBk = "rbxassetid://159454299",
        SkyboxDn = "rbxassetid://159454296",
        SkyboxFt = "rbxassetid://159454293",
        SkyboxLf = "rbxassetid://159454286",
        SkyboxRt = "rbxassetid://159454300",
        SkyboxUp = "rbxassetid://159454288",
        StarCount = 3000,
        SunAngularSize = 0,
    },
    Sunset = {
        SkyboxBk = "rbxassetid://150335524",
        SkyboxDn = "rbxassetid://150335525",
        SkyboxFt = "rbxassetid://150335527",
        SkyboxLf = "rbxassetid://150335528",
        SkyboxRt = "rbxassetid://150335529",
        SkyboxUp = "rbxassetid://150335530",
        SunAngularSize = 21,
    },
    BloodMoon = {
        SkyboxBk = "rbxassetid://5098640313",
        SkyboxDn = "rbxassetid://5098640313",
        SkyboxFt = "rbxassetid://5098640313",
        SkyboxLf = "rbxassetid://5098640313",
        SkyboxRt = "rbxassetid://5098640313",
        SkyboxUp = "rbxassetid://5098640313",
        SunAngularSize = 0,
    },
    Galaxy = {
        SkyboxBk = "rbxassetid://159248188",
        SkyboxDn = "rbxassetid://159248183",
        SkyboxFt = "rbxassetid://159248187",
        SkyboxLf = "rbxassetid://159248173",
        SkyboxRt = "rbxassetid://159248192",
        SkyboxUp = "rbxassetid://159248176",
        StarCount = 5000,
        SunAngularSize = 0,
    },
    PurpleNebula = {
        SkyboxBk = "rbxassetid://5084575798",
        SkyboxDn = "rbxassetid://5084575807",
        SkyboxFt = "rbxassetid://5084575791",
        SkyboxLf = "rbxassetid://5084575795",
        SkyboxRt = "rbxassetid://5084575787",
        SkyboxUp = "rbxassetid://5084575802",
        SunAngularSize = 0,
    },
    Vaporwave = {
        SkyboxBk = "rbxassetid://1417494403",
        SkyboxDn = "rbxassetid://1417494146",
        SkyboxFt = "rbxassetid://1417494253",
        SkyboxLf = "rbxassetid://1417494499",
        SkyboxRt = "rbxassetid://1417494643",
        SkyboxUp = "rbxassetid://1417494300",
        SunAngularSize = 0,
    },
    DeepSpace = {
        SkyboxBk = "rbxassetid://159454288",
        SkyboxDn = "rbxassetid://159454288",
        SkyboxFt = "rbxassetid://159454288",
        SkyboxLf = "rbxassetid://159454288",
        SkyboxRt = "rbxassetid://159454288",
        SkyboxUp = "rbxassetid://159454288",
        StarCount = 0,
        SunAngularSize = 0,
    },
}

local function RemoveCustomSky()
    if World.ActiveSky then
        World.ActiveSky:Destroy()
        World.ActiveSky = nil
    end
    -- Also remove any existing ZeeHoodSky
    for _, child in pairs(Lighting:GetChildren()) do
        if child.Name == "ZeeHoodSky" and child:IsA("Sky") then
            child:Destroy()
        end
    end
end

local function ApplyCustomSky()
    local Config = World.Config
    local themeName = Config.World_SkyTheme or "Default"

    -- Only reapply if theme changed
    if World.LastSkyTheme == themeName then return end
    World.LastSkyTheme = themeName

    if themeName == "Default" then
        RemoveCustomSky()
        return
    end

    local theme = SkyThemes[themeName]
    if not theme then return end

    RemoveCustomSky()

    -- Remove any existing Sky objects in Lighting first
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") and child.Name ~= "ZeeHoodSky" then
            child.Parent = nil
        end
    end

    local sky = Instance.new("Sky")
    sky.Name = "ZeeHoodSky"
    sky.SkyboxBk = theme.SkyboxBk
    sky.SkyboxDn = theme.SkyboxDn
    sky.SkyboxFt = theme.SkyboxFt
    sky.SkyboxLf = theme.SkyboxLf
    sky.SkyboxRt = theme.SkyboxRt
    sky.SkyboxUp = theme.SkyboxUp
    if theme.StarCount then sky.StarCount = theme.StarCount end
    if theme.SunAngularSize then sky.SunAngularSize = theme.SunAngularSize end
    sky.Parent = Lighting
    World.ActiveSky = sky
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
    RemoveCustomSky()
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