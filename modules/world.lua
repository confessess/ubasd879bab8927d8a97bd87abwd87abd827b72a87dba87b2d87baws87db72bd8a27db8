local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local World = {
    Config = nil,
    Connection = nil,
    OriginalValues = {},
    ActiveSky = nil,
    LastSkyTheme = nil,
    OriginalSky = nil,
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
-- SKY THEMES — User-provided texture IDs
-- ═════════════════════════════════════════════════════════════════════════════

local SkyThemes = {
    Default = nil,
    Night = {
        SkyboxBk = "rbxassetid://9425220156",
        SkyboxDn = "rbxassetid://9425220156",
        SkyboxFt = "rbxassetid://9425220156",
        SkyboxLf = "rbxassetid://9425220156",
        SkyboxRt = "rbxassetid://9425220156",
        SkyboxUp = "rbxassetid://9425220156",
        MoonTextureId = "rbxassetid://9343303339",
        MoonAngularSize = 11,
        StarCount = 3000,
        SunAngularSize = 0,
        ClockTime = 0,
        Brightness = 2,
    },
    Light = {
        SkyboxBk = "rbxassetid://15391855678",
        SkyboxDn = "rbxassetid://15391855678",
        SkyboxFt = "rbxassetid://15391855678",
        SkyboxLf = "rbxassetid://15391855678",
        SkyboxRt = "rbxassetid://15391855678",
        SkyboxUp = "rbxassetid://15391855678",
        StarCount = 0,
        SunAngularSize = 15,
        ClockTime = 12,
        Brightness = 8,
    },
    Blood = {
        SkyboxBk = "rbxassetid://98490421374360",
        SkyboxDn = "rbxassetid://98490421374360",
        SkyboxFt = "rbxassetid://98490421374360",
        SkyboxLf = "rbxassetid://98490421374360",
        SkyboxRt = "rbxassetid://98490421374360",
        SkyboxUp = "rbxassetid://98490421374360",
        StarCount = 0,
        SunAngularSize = 0,
        ClockTime = 0,
        Brightness = 3,
    },
    Gray = {
        SkyboxBk = "rbxassetid://105118232158923",
        SkyboxDn = "rbxassetid://105118232158923",
        SkyboxFt = "rbxassetid://105118232158923",
        SkyboxLf = "rbxassetid://105118232158923",
        SkyboxRt = "rbxassetid://105118232158923",
        SkyboxUp = "rbxassetid://105118232158923",
        StarCount = 0,
        SunAngularSize = 0,
        ClockTime = 10,
        Brightness = 4,
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

local function RemoveCustomSky()
    if World.ActiveSky then
        World.ActiveSky:Destroy()
        World.ActiveSky = nil
    end
    for _, child in pairs(Lighting:GetChildren()) do
        if child.Name == "ZeeHoodSky" and child:IsA("Sky") then
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
    RemoveCustomSky()

    -- Hide existing sky objects
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
    if theme.MoonTextureId then sky.MoonTextureId = theme.MoonTextureId end
    if theme.MoonAngularSize then sky.MoonAngularSize = theme.MoonAngularSize end
    if theme.StarCount then sky.StarCount = theme.StarCount end
    if theme.SunAngularSize then sky.SunAngularSize = theme.SunAngularSize end
    sky.Parent = Lighting
    World.ActiveSky = sky

    -- Apply lighting settings for theme mood
    if theme.ClockTime then Lighting.ClockTime = theme.ClockTime end
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