local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local World = {
    Config = nil,
    Connection = nil,
    OriginalValues = {},
    ActiveSky = nil,
    LastSkyTheme = nil,
    OriginalSky = nil,
    LowGFXApplied = false,
    NoShadowsApplied = false,
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
-- NO SHADOWS — Runs ONCE
-- ═════════════════════════════════════════════════════════════════════════════

local function ApplyNoShadows()
    if World.NoShadowsApplied then return end
    World.NoShadowsApplied = true

    SaveOriginal("GlobalShadows", function() return Lighting.GlobalShadows end)
    Lighting.GlobalShadows = false

    -- Scan once, cache results
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if not v:GetAttribute("ZeeHoodOldCastShadow") then
                v:SetAttribute("ZeeHoodOldCastShadow", part.CastShadow)
            end
            v.CastShadow = false
        end
    end
end

local function RemoveNoShadows()
    if not World.NoShadowsApplied then return end
    World.NoShadowsApplied = false

    RestoreOriginal("GlobalShadows", function(v) Lighting.GlobalShadows = v end)

    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part:GetAttribute("ZeeHoodOldCastShadow") ~= nil then
            part.CastShadow = part:GetAttribute("ZeeHoodOldCastShadow")
            part:SetAttribute("ZeeHoodOldCastShadow", nil)
        end
    end
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
-- LOW GFX — Da Hood style, runs ONCE
-- Disables: shadows, particles, decals, textures, beams, trails, lighting effects
-- Lowers: render quality, water quality, particle quality
-- ═════════════════════════════════════════════════════════════════════════════

local function ApplyLowGFX()
    if World.LowGFXApplied then return end
    World.LowGFXApplied = true

    -- 1. Force lowest render quality
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

    -- 2. Disable all shadows globally
    SaveOriginal("GlobalShadows", function() return Lighting.GlobalShadows end)
    SaveOriginal("Brightness", function() return Lighting.Brightness end)
    Lighting.GlobalShadows = false
    Lighting.Brightness = 3

    -- 3. Disable all Lighting effects
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") then
            if not v:GetAttribute("ZeeHoodLowGFX") then
                v:SetAttribute("ZeeHoodLowGFX", true)
                v:SetAttribute("ZeeHoodOldEnabled", v.Enabled)
                v.Enabled = false
            end
        end
        if v:IsA("Atmosphere") then
            if not v:GetAttribute("ZeeHoodLowGFX") then
                v:SetAttribute("ZeeHoodLowGFX", true)
                v:SetAttribute("ZeeHoodOldDensity", v.Density)
                v.Density = 0
            end
        end
    end

    -- 4. Scan Workspace ONCE — disable everything expensive
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Disable shadows on all parts
        if obj:IsA("BasePart") then
            if not obj:GetAttribute("ZeeHoodLowGFX") then
                obj:SetAttribute("ZeeHoodLowGFX", true)
                obj:SetAttribute("ZeeHoodOldCastShadow", obj.CastShadow)
                obj:SetAttribute("ZeeHoodOldReflectance", obj.Reflectance)
                obj:SetAttribute("ZeeHoodOldMaterial", obj.Material.Name)
                obj.CastShadow = false
                obj.Reflectance = 0
                -- Force smooth plastic (cheapest material)
                obj.Material = Enum.Material.SmoothPlastic
            end
        end

        -- Disable all particle emitters
        if obj:IsA("ParticleEmitter") then
            if not obj:GetAttribute("ZeeHoodLowGFX") then
                obj:SetAttribute("ZeeHoodLowGFX", true)
                obj:SetAttribute("ZeeHoodOldEnabled", obj.Enabled)
                obj.Enabled = false
            end
        end

        -- Disable all trails
        if obj:IsA("Trail") then
            if not obj:GetAttribute("ZeeHoodLowGFX") then
                obj:SetAttribute("ZeeHoodLowGFX", true)
                obj:SetAttribute("ZeeHoodOldEnabled", obj.Enabled)
                obj.Enabled = false
            end
        end

        -- Disable all beams
        if obj:IsA("Beam") then
            if not obj:GetAttribute("ZeeHoodLowGFX") then
                obj:SetAttribute("ZeeHoodLowGFX", true)
                obj:SetAttribute("ZeeHoodOldEnabled", obj.Enabled)
                obj.Enabled = false
            end
        end

        -- Disable all decals and textures
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if not obj:GetAttribute("ZeeHoodLowGFX") then
                obj:SetAttribute("ZeeHoodLowGFX", true)
                obj:SetAttribute("ZeeHoodOldTransparency", obj.Transparency)
                obj.Transparency = 1
            end
        end

        -- Disable surface appearances
        if obj:IsA("SurfaceAppearance") then
            if not obj:GetAttribute("ZeeHoodLowGFX") then
                obj:SetAttribute("ZeeHoodLowGFX", true)
                obj:SetAttribute("ZeeHoodOldAlphaMode", obj.AlphaMode.Name)
                obj.AlphaMode = Enum.AlphaMode.Opaque
            end
        end

        -- Disable light objects
        if obj:IsA("Light") then
            if not obj:GetAttribute("ZeeHoodLowGFX") then
                obj:SetAttribute("ZeeHoodLowGFX", true)
                obj:SetAttribute("ZeeHoodOldEnabled", obj.Enabled)
                obj.Enabled = false
            end
        end

        -- Disable fire, smoke, sparkles
        if obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            if not obj:GetAttribute("ZeeHoodLowGFX") then
                obj:SetAttribute("ZeeHoodLowGFX", true)
                obj:SetAttribute("ZeeHoodOldEnabled", obj.Enabled)
                obj.Enabled = false
            end
        end
    end

    -- 5. Disable water waves
    SaveOriginal("WaterWaveSize", function() return Workspace.Terrain.WaterWaveSize end)
    SaveOriginal("WaterWaveSpeed", function() return Workspace.Terrain.WaterWaveSpeed end)
    SaveOriginal("WaterTransparency", function() return Workspace.Terrain.WaterTransparency end)
    Workspace.Terrain.WaterWaveSize = 0
    Workspace.Terrain.WaterWaveSpeed = 0
    Workspace.Terrain.WaterTransparency = 1

    -- 6. Disable humanoid state effects on local player
    local char = LocalPlayer.Character
    if char then
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                if not obj:GetAttribute("ZeeHoodLowGFX") then
                    obj:SetAttribute("ZeeHoodLowGFX", true)
                    obj:SetAttribute("ZeeHoodOldEnabled", obj.Enabled)
                    obj.Enabled = false
                end
            end
        end
    end
end

local function RemoveLowGFX()
    if not World.LowGFXApplied then return end
    World.LowGFXApplied = false

    -- Restore render quality
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic

    -- Restore lighting
    RestoreOriginal("GlobalShadows", function(v) Lighting.GlobalShadows = v end)
    RestoreOriginal("Brightness", function(v) Lighting.Brightness = v end)

    -- Restore all Lighting effects
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:GetAttribute("ZeeHoodLowGFX") then
            if v:IsA("PostEffect") then
                v.Enabled = v:GetAttribute("ZeeHoodOldEnabled") or v.Enabled
            elseif v:IsA("Atmosphere") then
                v.Density = v:GetAttribute("ZeeHoodOldDensity") or v.Density
            end
            v:SetAttribute("ZeeHoodLowGFX", nil)
            v:SetAttribute("ZeeHoodOldEnabled", nil)
            v:SetAttribute("ZeeHoodOldDensity", nil)
        end
    end

    -- Restore Workspace objects
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:GetAttribute("ZeeHoodLowGFX") then
            if obj:IsA("BasePart") then
                obj.CastShadow = obj:GetAttribute("ZeeHoodOldCastShadow") or obj.CastShadow
                obj.Reflectance = obj:GetAttribute("ZeeHoodOldReflectance") or obj.Reflectance
                local matName = obj:GetAttribute("ZeeHoodOldMaterial")
                if matName then
                    obj.Material = Enum.Material[matName]
                end
                obj:SetAttribute("ZeeHoodOldCastShadow", nil)
                obj:SetAttribute("ZeeHoodOldReflectance", nil)
                obj:SetAttribute("ZeeHoodOldMaterial", nil)
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                or obj:IsA("Light") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = obj:GetAttribute("ZeeHoodOldEnabled") or obj.Enabled
                obj:SetAttribute("ZeeHoodOldEnabled", nil)
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = obj:GetAttribute("ZeeHoodOldTransparency") or obj.Transparency
                obj:SetAttribute("ZeeHoodOldTransparency", nil)
            elseif obj:IsA("SurfaceAppearance") then
                local alphaMode = obj:GetAttribute("ZeeHoodOldAlphaMode")
                if alphaMode then
                    obj.AlphaMode = Enum.AlphaMode[alphaMode]
                end
                obj:SetAttribute("ZeeHoodOldAlphaMode", nil)
            end
            obj:SetAttribute("ZeeHoodLowGFX", nil)
        end
    end

    -- Restore water
    RestoreOriginal("WaterWaveSize", function(v) Workspace.Terrain.WaterWaveSize = v end)
    RestoreOriginal("WaterWaveSpeed", function(v) Workspace.Terrain.WaterWaveSpeed = v end)
    RestoreOriginal("WaterTransparency", function(v) Workspace.Terrain.WaterTransparency = v end)

    -- Restore character effects
    local char = LocalPlayer.Character
    if char then
        for _, obj in pairs(char:GetDescendants()) do
            if obj:GetAttribute("ZeeHoodLowGFX") then
                obj.Enabled = obj:GetAttribute("ZeeHoodOldEnabled") or obj.Enabled
                obj:SetAttribute("ZeeHoodLowGFX", nil)
                obj:SetAttribute("ZeeHoodOldEnabled", nil)
            end
        end
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- SKY THEMES — User-provided + verified working skyboxes
-- ═════════════════════════════════════════════════════════════════════════════

local SkyThemes = {
    Default = nil,
    -- User themes
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
    DarkNight = {
        SkyboxBk = "rbxassetid://163208827",
        SkyboxDn = "rbxassetid://163208726",
        SkyboxFt = "rbxassetid://163208689",
        SkyboxLf = "rbxassetid://163208661",
        SkyboxRt = "rbxassetid://163208590",
        SkyboxUp = "rbxassetid://163208536",
        StarCount = 5000,
        SunAngularSize = 0,
        ClockTime = 0,
        Brightness = 1,
    },
    Space = {
        SkyboxBk = "rbxassetid://2489005061",
        SkyboxDn = "rbxassetid://2489005061",
        SkyboxFt = "rbxassetid://2489004059",
        SkyboxLf = "rbxassetid://2489051347",
        SkyboxRt = "rbxassetid://2489052475",
        SkyboxUp = "rbxassetid://2489053637",
        StarCount = 10000,
        SunAngularSize = 0,
        ClockTime = 0,
        Brightness = 1,
    },
    Test = {
        SkyboxBk = "rbxassetid://4662930572",
        SkyboxDn = "rbxassetid://4662930572",
        SkyboxFt = "rbxassetid://4662930572",
        SkyboxLf = "rbxassetid://4662930572",
        SkyboxRt = "rbxassetid://4662930572",
        SkyboxUp = "rbxassetid://4662930572",
        StarCount = 0,
        SunAngularSize = 0,
        ClockTime = 12,
        Brightness = 5,
    },
    -- Random verified working skyboxes (same ID all sides)
    Clouds = {
        SkyboxBk = "rbxassetid://6412253255",
        SkyboxDn = "rbxassetid://6412253255",
        SkyboxFt = "rbxassetid://6412253255",
        SkyboxLf = "rbxassetid://6412253255",
        SkyboxRt = "rbxassetid://6412253255",
        SkyboxUp = "rbxassetid://6412253255",
        StarCount = 0,
        SunAngularSize = 15,
        ClockTime = 14,
        Brightness = 6,
    },
    Sunset2 = {
        SkyboxBk = "rbxassetid://6444695118",
        SkyboxDn = "rbxassetid://6444695118",
        SkyboxFt = "rbxassetid://6444695118",
        SkyboxLf = "rbxassetid://6444695118",
        SkyboxRt = "rbxassetid://6444695118",
        SkyboxUp = "rbxassetid://6444695118",
        StarCount = 0,
        SunAngularSize = 18,
        ClockTime = 17,
        Brightness = 5,
    },
    Galaxy2 = {
        SkyboxBk = "rbxassetid://8139677359",
        SkyboxDn = "rbxassetid://8139677359",
        SkyboxFt = "rbxassetid://8139677359",
        SkyboxLf = "rbxassetid://8139677359",
        SkyboxRt = "rbxassetid://8139677359",
        SkyboxUp = "rbxassetid://8139677359",
        StarCount = 5000,
        SunAngularSize = 0,
        ClockTime = 0,
        Brightness = 2,
    },
    Nebula = {
        SkyboxBk = "rbxassetid://8139677203",
        SkyboxDn = "rbxassetid://8139677203",
        SkyboxFt = "rbxassetid://8139677203",
        SkyboxLf = "rbxassetid://8139677203",
        SkyboxRt = "rbxassetid://8139677203",
        SkyboxUp = "rbxassetid://8139677203",
        StarCount = 3000,
        SunAngularSize = 0,
        ClockTime = 0,
        Brightness = 3,
    },
    Storm2 = {
        SkyboxBk = "rbxassetid://8139676933",
        SkyboxDn = "rbxassetid://8139676933",
        SkyboxFt = "rbxassetid://8139676933",
        SkyboxLf = "rbxassetid://8139676933",
        SkyboxRt = "rbxassetid://8139676933",
        SkyboxUp = "rbxassetid://8139676933",
        StarCount = 0,
        SunAngularSize = 0,
        ClockTime = 8,
        Brightness = 2,
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
    World.LowGFXApplied = false
    World.NoShadowsApplied = false
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