--// modules/visuals.lua
--// FOV, Tracers, Hitmarkers

local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local Drawing = require(script.Parent.Parent.utils.drawing)
local Targeting = require(script.Parent.targeting)

local Config = require(game:GetService("ReplicatedFirst"):WaitForChild("ZeeHConfig", 5) or script.Parent.Parent.config)

local Visuals = {}

local FOV_Circle = Drawing.New("Circle", {
    Visible = false,
    Thickness = 1.2,
    Color = Config.FOV_Color,
    Transparency = 0.6,
    Filled = false,
    NumSides = 64,
})

local Tracer = Drawing.New("Line", {
    Visible = false,
    Thickness = 1,
    Color = Config.Tracer_Color,
    Transparency = 0.5,
})

local Hitmarker = Drawing.New("Text", {
    Visible = false,
    Size = 20,
    Center = true,
    Outline = true,
    Color = Color3.fromRGB(255, 255, 255),
    Text = "✕",
})

function Visuals.Update()
    local mousePos = UserInputService:GetMouseLocation()
    
    -- FOV
    FOV_Circle.Visible = Config.FOV_Enabled
    FOV_Circle.Position = mousePos
    FOV_Circle.Radius = Config.FOV_Radius
    
    -- Tracers
    local target = Targeting.GetTarget()
    if Config.Tracers and target then
        local sp, onScreen = Camera:WorldToViewportPoint(target.Position)
        if onScreen then
            Tracer.Visible = true
            Tracer.From = mousePos
            Tracer.To = Vector2.new(sp.X, sp.Y)
        else
            Tracer.Visible = false
        end
    else
        Tracer.Visible = false
    end
    
    -- Highlight
    Targeting.UpdateHighlight(target)
    
    -- Spectate
    Targeting.UpdateSpectate()
end

function Visuals.PlayHitmarker()
    if not Config.Hitmarkers then return end
    Hitmarker.Position = UserInputService:GetMouseLocation() + Vector2.new(0, -15)
    Hitmarker.Visible = true
    Hitmarker.Color = Color3.fromRGB(255, 80, 80)
    delay(0.2, function() Hitmarker.Visible = false end)
end

return Visuals