local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local Visuals = {
    Config = nil,
    Targeting = nil,
}

local DrawingObjects = {}
local function DrawingNew(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    table.insert(DrawingObjects, obj)
    return obj
end

local FOV_Circle = DrawingNew("Circle", {
    Visible = false,
    Thickness = 1.2,
    Color = Color3.fromRGB(255, 80, 80),
    Transparency = 0.6,
    Filled = false,
    NumSides = 64,
})

local Tracer = DrawingNew("Line", {
    Visible = false,
    Thickness = 1,
    Color = Color3.fromRGB(255, 60, 60),
    Transparency = 0.5,
})

local Hitmarker = DrawingNew("Text", {
    Visible = false,
    Size = 20,
    Center = true,
    Outline = true,
    Color = Color3.fromRGB(255, 255, 255),
    Text = "✕",
})

function Visuals.SetConfig(config)
    Visuals.Config = config
end

function Visuals.SetTargeting(targeting)
    Visuals.Targeting = targeting
end

function Visuals.Update()
    local Config = Visuals.Config
    local Targeting = Visuals.Targeting
    if not Config or not Targeting then return end
    
    local mousePos = UserInputService:GetMouseLocation()
    
    FOV_Circle.Visible = Config.FOV_Enabled
    FOV_Circle.Position = mousePos
    FOV_Circle.Radius = Config.FOV_Radius
    
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
    
    Targeting.UpdateHighlight(target)
    Targeting.UpdateSpectate()
end

function Visuals.PlayHitmarker()
    if not Visuals.Config or not Visuals.Config.Hitmarkers then return end
    Hitmarker.Position = UserInputService:GetMouseLocation() + Vector2.new(0, -15)
    Hitmarker.Visible = true
    Hitmarker.Color = Color3.fromRGB(255, 80, 80)
    delay(0.2, function() Hitmarker.Visible = false end)
end

return Visuals