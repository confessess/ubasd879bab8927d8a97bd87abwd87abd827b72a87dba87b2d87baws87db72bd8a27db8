--// Zee Hood HVH — Single File Merged Edition
--// Load with: loadstring(game:HttpGet("https://raw.githubusercontent.com/confessess/zee-hvh/main/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local Config = {
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
    MaxTargetDistance = 50000000000000000,
    ToggleKey = Enum.KeyCode.RightShift,
    ShowHotkeys = true,
}

--==================================================
-- DRAWING UTILS
--==================================================

local DrawingObjects = {}
local function DrawingNew(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    table.insert(DrawingObjects, obj)
    return obj
end

--==================================================
-- TARGETING
--==================================================

local Targeting = {
    SelectedTarget = nil,
    HighlightBox = nil,
}

local function getCharacterPart(char, partName)
    local part = char:FindFirstChild(partName)
    if part then return part end
    if partName == "Torso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    elseif partName == "Head" then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return char:FindFirstChild("HumanoidRootPart")
end

function Targeting.GetTarget()
    if Config.TargetMode == "Selected" and Targeting.SelectedTarget then
        local char = Targeting.SelectedTarget.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return getCharacterPart(char, Config.TargetPart)
            end
        end
    end
    
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = myChar.HumanoidRootPart.Position
    local closest = nil
    local minDist = math.huge
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            
            local part = getCharacterPart(char, Config.TargetPart)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            if part and hrp then
                local dist = (myPos - hrp.Position).Magnitude
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local md = (Vector2.new(sp.X, sp.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if md <= Config.FOV_Radius and dist < minDist then
                        minDist = dist
                        closest = part
                    end
                end
            end
        end
    end
    return closest
end

function Targeting.UpdateHighlight(target)
    if not Config.Highlights then
        if Targeting.HighlightBox then Targeting.HighlightBox:Destroy() end
        return
    end
    if target and target.Parent then
        if not Targeting.HighlightBox then
            Targeting.HighlightBox = Instance.new("Highlight")
            Targeting.HighlightBox.FillColor = Color3.fromRGB(255, 50, 50)
            Targeting.HighlightBox.OutlineColor = Color3.fromRGB(255, 255, 255)
            Targeting.HighlightBox.FillTransparency = 0.5
            Targeting.HighlightBox.OutlineTransparency = 0
        end
        Targeting.HighlightBox.Parent = target.Parent
        Targeting.HighlightBox.Adornee = target
    else
        if Targeting.HighlightBox then Targeting.HighlightBox:Destroy() end
        Targeting.HighlightBox = nil
    end
end

function Targeting.UpdateSpectate()
    if not Config.Spectate then return end
    local target = Targeting.GetTarget()
    if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
        Camera.CameraSubject = target.Parent.Humanoid
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end

function Targeting.StopSpectate()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
    end
end

function Targeting.RefreshPlayerList(container, onSelect)
    for _, c in ipairs(container:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local y = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 24)
            btn.Position = UDim2.new(0, 0, 0, y)
            btn.BackgroundColor3 = (Targeting.SelectedTarget == plr) and Color3.fromRGB(70, 100, 160) or Color3.fromRGB(35, 35, 45)
            btn.Text = plr.DisplayName
            btn.TextColor3 = Color3.fromRGB(200, 200, 215)
            btn.TextSize = 11
            btn.Font = Enum.Font.Gotham
            btn.Parent = container
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(function()
                Targeting.SelectedTarget = plr
                Config.TargetMode = "Selected"
                onSelect()
            end)
            y = y + 26
        end
    end
    container.CanvasSize = UDim2.new(0, 0, 0, y)
end

--==================================================
-- VISUALS
--==================================================

local Visuals = {}

local FOV_Circle = DrawingNew("Circle", {
    Visible = false,
    Thickness = 1.2,
    Color = Config.FOV_Color,
    Transparency = 0.6,
    Filled = false,
    NumSides = 64,
})

local Tracer = DrawingNew("Line", {
    Visible = false,
    Thickness = 1,
    Color = Config.Tracer_Color,
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

function Visuals.Update()
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
    if not Config.Hitmarkers then return end
    Hitmarker.Position = UserInputService:GetMouseLocation() + Vector2.new(0, -15)
    Hitmarker.Visible = true
    Hitmarker.Color = Color3.fromRGB(255, 80, 80)
    delay(0.2, function() Hitmarker.Visible = false end)
end

--==================================================
-- COMBAT
--==================================================

local Combat = {
    ModifiedTools = {},
}

function Combat.SetupFullAuto(tool)
    if Combat.ModifiedTools[tool] or not tool:FindFirstChild("GunScript") then return end
    
    local success = pcall(function()
        local connections = getconnections(tool.Activated)
        for _, conn in ipairs(connections) do
            local func = conn.Function
            if func then
                local info = debug.getinfo(func)
                for i = 1, (info.nups or 0) do
                    local val = debug.getupvalue(func, i)
                    if type(val) == "number" and val > 0 and val < 0.5 then
                        debug.setupvalue(func, i, 0)
                    end
                end
            end
        end
    end)
    
    if success then
        Combat.ModifiedTools[tool] = true
    end
end

function Combat.FrameTeleportActivate(tool, isRapidFire)
    if not Config.FrameTP then
        tool:Activate()
        return
    end
    
    local target = Targeting.GetTarget()
    if not target then
        tool:Activate()
        return
    end
    
    local char = LocalPlayer.Character
    if not char then
        tool:Activate()
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        tool:Activate()
        return
    end
    
    local targetChar = target.Parent
    if not targetChar then
        tool:Activate()
        return
    end
    
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP then
        tool:Activate()
        return
    end
    
    local origHRP = hrp.CFrame
    local origCam = Camera.CFrame
    
    local targetCF = targetHRP.CFrame
    local shootPos = targetCF.Position + (targetCF.LookVector * 2) + Vector3.new(0, 0.5, 0)
    
    hrp.CFrame = CFrame.new(shootPos, targetCF.Position)
    hrp.Velocity = Vector3.new(0, 0, 0)
    Camera.CFrame = CFrame.new(shootPos + Vector3.new(0, 1.5, 0), target.Position)
    
    tool:Activate()
    
    if not isRapidFire then
        RunService.Heartbeat:Wait()
    elseif Config.OneFrameDelay then
        RunService.Heartbeat:Wait()
    end
    
    hrp.CFrame = origHRP
    hrp.Velocity = Vector3.new(0, 0, 0)
    Camera.CFrame = origCam
    
    Visuals.PlayHitmarker()
end

function Combat.Reset()
    Combat.ModifiedTools = {}
end

--==================================================
-- UI — DARK GLASS
--==================================================

local UI = {}

local PURPLE = Color3.fromRGB(145, 75, 255)
local PURPLE_LIGHT = Color3.fromRGB(195, 140, 255)

local function New(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function Corner(parent, radius)
    return New("UICorner", {CornerRadius = UDim.new(0, radius or 6)}, parent)
end

local function Stroke(parent, transparency, thickness, color)
    return New("UIStroke", {
        Color = color or Color3.fromRGB(180, 120, 255),
        Transparency = transparency or 0.72,
        Thickness = thickness or 1,
    }, parent)
end

local function Tween(object, properties, duration, style, direction)
    local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    return TweenService:Create(object, info, properties)
end

function UI.Build()
    local oldGui = PlayerGui:FindFirstChild("ZeeHoodUI")
    if oldGui then oldGui:Destroy() end
    local oldBlur = Lighting:FindFirstChild("ZeeHoodBlur")
    if oldBlur then oldBlur:Destroy() end
    
    local ScreenGui = New("ScreenGui", {
        Name = "ZeeHoodUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, PlayerGui)
    
    local Background = New("Frame", {
        Name = "Background",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(4, 3, 9),
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        ZIndex = 1,
        Visible = false,
    }, ScreenGui)
    
    New("UIGradient", {
        Rotation = 35,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 8, 38)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 3, 10)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(27, 7, 45)),
        }),
    }, Background)
    
    local StarContainer = New("Frame", {
        Name = "Stars",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 2,
    }, Background)
    
    for i = 1, 60 do
        local size = math.random(1, 3)
        local star = New("Frame", {
            Size = UDim2.fromOffset(size, size),
            Position = UDim2.fromScale(math.random(), math.random()),
            BackgroundColor3 = Color3.fromRGB(220, 195, 255),
            BackgroundTransparency = math.random(20, 90) / 100,
            BorderSizePixel = 0,
            ZIndex = 2,
        }, StarContainer)
        Corner(star, size)
        task.spawn(function()
            while star.Parent do
                local fadeTime = math.random(5, 15) / 10
                Tween(star, {BackgroundTransparency = math.random(15, 55) / 100}, fadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
                task.wait(fadeTime)
                Tween(star, {BackgroundTransparency = math.random(65, 95) / 100}, fadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
                task.wait(fadeTime + math.random(1, 15) / 10)
            end
        end)
    end
    
    local Blur = New("BlurEffect", {
        Name = "ZeeHoodBlur",
        Size = 0,
    }, Lighting)
    
    local GUI_WIDTH, GUI_HEIGHT = 760, 520
    
    local Main = New("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(GUI_WIDTH, GUI_HEIGHT),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(9, 6, 15),
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ZIndex = 10,
        Visible = false,
    }, ScreenGui)
    
    Corner(Main, 20)
    Stroke(Main, 0.72, 1)
    
    local TopHighlight = New("Frame", {
        Size = UDim2.new(1, -40, 0, 1),
        Position = UDim2.fromOffset(20, 1),
        BackgroundColor3 = Color3.fromRGB(195, 140, 255),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 11,
    }, Main)
    Corner(TopHighlight, 1)
    
    local TopBar = New("Frame", {
        Size = UDim2.new(1, -30, 0, 62),
        Position = UDim2.fromOffset(15, 10),
        BackgroundTransparency = 1,
        ZIndex = 12,
    }, Main)
    
    New("TextLabel", {
        Size = UDim2.fromOffset(400, 27),
        Position = UDim2.fromOffset(8, 3),
        BackgroundTransparency = 1,
        Text = "ZEE HOOD",
        TextColor3 = Color3.fromRGB(245, 238, 250),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
    }, TopBar)
    
    New("TextLabel", {
        Size = UDim2.fromOffset(400, 20),
        Position = UDim2.fromOffset(9, 30),
        BackgroundTransparency = 1,
        Text = "HvH Combat Suite",
        TextColor3 = Color3.fromRGB(145, 125, 165),
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
    }, TopBar)
    
    local CloseBtn = New("TextButton", {
        Size = UDim2.fromOffset(34, 34),
        Position = UDim2.new(1, -34, 0, 7),
        BackgroundColor3 = Color3.fromRGB(145, 45, 175),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 245, 255),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 15,
    }, TopBar)
    Corner(CloseBtn, 9)
    
    local Body = New("Frame", {
        Size = UDim2.new(1, -30, 1, -82),
        Position = UDim2.fromOffset(15, 72),
        BackgroundTransparency = 1,
        ZIndex = 12,
    }, Main)
    
    local Sidebar = New("Frame", {
        Size = UDim2.new(0, 175, 1, 0),
        Position = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Color3.fromRGB(16, 10, 24),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 13,
    }, Body)
    Corner(Sidebar, 15)
    Stroke(Sidebar, 0.91, 1)
    
    local Content = New("Frame", {
        Size = UDim2.new(1, -190, 1, 0),
        Position = UDim2.fromOffset(190, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 13,
    }, Body)
    
    local TabNames = {"Combat", "Visuals", "Target", "Settings"}
    local TabButtons = {}
    local Pages = {}
    
    for index, name in ipairs(TabNames) do
        local button = New("TextButton", {
            Size = UDim2.new(1, -32, 0, 43),
            Position = UDim2.fromOffset(22, 12 + ((index - 1) * 50)),
            BackgroundColor3 = PURPLE,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = Color3.fromRGB(145, 135, 160),
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            ZIndex = 15,
        }, Sidebar)
        Corner(button, 10)
        New("UIPadding", {PaddingLeft = UDim.new(0, 16)}, button)
        
        local indicator = New("Frame", {
            Size = UDim2.fromOffset(3, 18),
            Position = UDim2.new(0, 8, 0, 25 + ((index - 1) * 50)),
            BackgroundColor3 = PURPLE_LIGHT,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 20,
        }, Sidebar)
        Corner(indicator, 3)
        
        TabButtons[name] = {Button = button, Indicator = indicator}
        
        local page = New("Frame", {
            Name = name,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 14,
        }, Content)
        Pages[name] = page
    end
    
    local function PageTitle(page, title, description)
        New("TextLabel", {
            Size = UDim2.new(1, -20, 0, 28),
            Position = UDim2.fromOffset(10, 7),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Color3.fromRGB(245, 240, 250),
            TextSize = 21,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 15,
        }, page)
        
        New("TextLabel", {
            Size = UDim2.new(1, -20, 0, 22),
            Position = UDim2.fromOffset(10, 35),
            BackgroundTransparency = 1,
            Text = description,
            TextColor3 = Color3.fromRGB(135, 120, 150),
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 15,
        }, page)
    end
    
    local function CreateCard(page, position, size)
        local card = New("Frame", {
            Size = size,
            Position = position,
            BackgroundColor3 = Color3.fromRGB(18, 11, 27),
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            ZIndex = 15,
        }, page)
        Corner(card, 13)
        Stroke(card, 0.91, 1)
        return card
    end
    
    local function CreateToggle(parent, y, text, default, callback)
        local frame = New("Frame", {
            Size = UDim2.new(1, -20, 0, 32),
            Position = UDim2.fromOffset(10, y),
            BackgroundTransparency = 1,
            ZIndex = 16,
        }, parent)
        
        New("TextLabel", {
            Size = UDim2.new(1, -60, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Color3.fromRGB(200, 190, 215),
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 17,
        }, frame)
        
        local toggle = New("TextButton", {
            Size = UDim2.fromOffset(44, 22),
            Position = UDim2.new(1, -50, 0.5, -11),
            BackgroundColor3 = default and PURPLE or Color3.fromRGB(50, 50, 60),
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 17,
        }, frame)
        Corner(toggle, 11)
        
        local knob = New("Frame", {
            Size = UDim2.fromOffset(18, 18),
            Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 18,
        }, toggle)
        Corner(knob, 20)
        
        local state = default
        toggle.MouseButton1Click:Connect(function()
            state = not state
            Tween(toggle, {BackgroundColor3 = state and PURPLE or Color3.fromRGB(50, 50, 60)}, 0.2):Play()
            Tween(knob, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2):Play()
            callback(state)
        end)
        
        return function() return state end
    end
    
    local function CreateSlider(parent, y, text, min, max, default, callback)
        local frame = New("Frame", {
            Size = UDim2.new(1, -20, 0, 48),
            Position = UDim2.fromOffset(10, y),
            BackgroundTransparency = 1,
            ZIndex = 16,
        }, parent)
        
        local label = New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = text .. " [" .. default .. "]",
            TextColor3 = Color3.fromRGB(200, 190, 215),
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 17,
        }, frame)
        
        local track = New("Frame", {
            Size = UDim2.new(1, 0, 0, 5),
            Position = UDim2.new(0, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BorderSizePixel = 0,
            ZIndex = 17,
        }, frame)
        Corner(track, 3)
        
        local fill = New("Frame", {
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = PURPLE,
            BorderSizePixel = 0,
            ZIndex = 18,
        }, track)
        Corner(fill, 3)
        
        local dragging = false
        local function setValue(input)
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (pos * (max - min)))
            fill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = text .. " [" .. val .. "]"
            callback(val)
        end
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                setValue(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                setValue(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    
    --// COMBAT PAGE
    local CombatPage = Pages.Combat
    PageTitle(CombatPage, "Combat", "Frame teleport shoot and rapid fire controls.")
    
    local CombatCard = CreateCard(CombatPage, UDim2.fromOffset(10, 72), UDim2.new(1, -20, 0, 200))
    
    CreateToggle(CombatCard, 14, "Frame TP Shoot", Config.FrameTP, function(v)
        Config.FrameTP = v
    end)
    CreateToggle(CombatCard, 50, "One-Frame Delay", Config.OneFrameDelay, function(v)
        Config.OneFrameDelay = v
    end)
    CreateToggle(CombatCard, 86, "Rapid Fire", Config.RapidFire, function(v)
        Config.RapidFire = v
    end)
    CreateToggle(CombatCard, 122, "Hitmarkers", Config.Hitmarkers, function(v)
        Config.Hitmarkers = v
    end)
    
    --// VISUALS PAGE
    local VisualsPage = Pages.Visuals
    PageTitle(VisualsPage, "Visuals", "FOV, tracers, and target highlighting.")
    
    local VisualsCard = CreateCard(VisualsPage, UDim2.fromOffset(10, 72), UDim2.new(1, -20, 0, 200))
    
    CreateToggle(VisualsCard, 14, "FOV Circle", Config.FOV_Enabled, function(v)
        Config.FOV_Enabled = v
    end)
    CreateSlider(VisualsCard, 50, "FOV Radius", 50, 600, Config.FOV_Radius, function(v)
        Config.FOV_Radius = v
    end)
    CreateToggle(VisualsCard, 110, "Tracers", Config.Tracers, function(v)
        Config.Tracers = v
    end)
    CreateToggle(VisualsCard, 146, "Highlights", Config.Highlights, function(v)
        Config.Highlights = v
    end)
    
    --// TARGET PAGE
    local TargetPage = Pages.Target
    PageTitle(TargetPage, "Target", "Player selection and spectate controls.")
    
    local TargetCard = CreateCard(TargetPage, UDim2.fromOffset(10, 72), UDim2.new(1, -20, 0, 180))
    
    local targetLabel = New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 14),
        BackgroundTransparency = 1,
        Text = "Target Part: " .. Config.TargetPart,
        TextColor3 = Color3.fromRGB(200, 190, 215),
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, TargetCard)
    
    local partBtn = New("TextButton", {
        Size = UDim2.fromOffset(120, 28),
        Position = UDim2.new(1, -130, 0, 10),
        BackgroundColor3 = Color3.fromRGB(45, 65, 110),
        BorderSizePixel = 0,
        Text = "Cycle Part",
        TextColor3 = Color3.fromRGB(220, 220, 235),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 17,
    }, TargetCard)
    Corner(partBtn, 6)
    
    local parts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "LeftLeg", "RightLeg"}
    local pIdx = 1
    partBtn.MouseButton1Click:Connect(function()
        pIdx = pIdx % #parts + 1
        Config.TargetPart = parts[pIdx]
        targetLabel.Text = "Target Part: " .. Config.TargetPart
    end)
    
    CreateToggle(TargetCard, 50, "Spectate Target", Config.Spectate, function(v)
        Config.Spectate = v
        if not v then Targeting.StopSpectate() end
    end)
    
    local PlayerList = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 0, 140),
        Position = UDim2.fromOffset(10, 90),
        BackgroundColor3 = Color3.fromRGB(12, 8, 18),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 16,
    }, TargetCard)
    Corner(PlayerList, 8)
    
    New("UIListLayout", {Padding = UDim.new(0, 2), Parent = PlayerList})
    
    local function refreshList()
        Targeting.RefreshPlayerList(PlayerList, refreshList)
    end
    refreshList()
    Players.PlayerAdded:Connect(refreshList)
    Players.PlayerRemoving:Connect(refreshList)
    
    --// SETTINGS PAGE
    local SettingsPage = Pages.Settings
    PageTitle(SettingsPage, "Settings", "Interface customization.")
    
    local SettingsCard = CreateCard(SettingsPage, UDim2.fromOffset(10, 72), UDim2.new(1, -20, 0, 100))
    
    New("TextLabel", {
        Size = UDim2.new(1, -140, 0, 25),
        Position = UDim2.fromOffset(15, 14),
        BackgroundTransparency = 1,
        Text = "Toggle Keybind",
        TextColor3 = Color3.fromRGB(235, 220, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)
    
    New("TextLabel", {
        Size = UDim2.new(1, -140, 0, 35),
        Position = UDim2.fromOffset(15, 43),
        BackgroundTransparency = 1,
        Text = "Press a key to rebind the menu toggle.",
        TextColor3 = Color3.fromRGB(140, 125, 155),
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)
    
    local KeybindButton = New("TextButton", {
        Size = UDim2.fromOffset(115, 38),
        Position = UDim2.new(1, -130, 0.5, -19),
        BackgroundColor3 = PURPLE,
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        Text = Config.ToggleKey.Name,
        TextColor3 = Color3.fromRGB(255, 250, 255),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 17,
    }, SettingsCard)
    Corner(KeybindButton, 9)
    
    --// Tab System
    local ActiveTab = nil
    local function SelectTab(name)
        ActiveTab = name
        for tabName, data in pairs(TabButtons) do
            local active = tabName == name
            Tween(data.Button, {
                BackgroundTransparency = active and 0.84 or 1,
                TextColor3 = active and Color3.fromRGB(235, 220, 255) or Color3.fromRGB(145, 135, 160),
            }, 0.2):Play()
            Tween(data.Indicator, {BackgroundTransparency = active and 0 or 1}, 0.2):Play()
        end
        for pageName, page in pairs(Pages) do
            page.Visible = pageName == name
        end
    end
    
    for name, data in pairs(TabButtons) do
        data.Button.MouseButton1Click:Connect(function() SelectTab(name) end)
        data.Button.MouseEnter:Connect(function()
            if ActiveTab ~= name then
                Tween(data.Button, {BackgroundTransparency = 0.94}, 0.15):Play()
            end
        end)
        data.Button.MouseLeave:Connect(function()
            if ActiveTab ~= name then
                Tween(data.Button, {BackgroundTransparency = 1}, 0.15):Play()
            end
        end)
    end
    
    SelectTab("Combat")
    
    --// Keybind Changing
    local ListeningForKey = false
    KeybindButton.MouseButton1Click:Connect(function()
        if ListeningForKey then return end
        ListeningForKey = true
        KeybindButton.Text = "PRESS KEY"
        Tween(KeybindButton, {BackgroundTransparency = 0}, 0.2):Play()
    end)
    
    --// GUI Toggle
    local GUIVisible = false
    local function SetGUIVisible(visible)
        GUIVisible = visible
        if visible then
            Main.Visible = true
            Background.Visible = true
            Tween(Main, {
                Size = UDim2.fromOffset(GUI_WIDTH, GUI_HEIGHT),
                BackgroundTransparency = 0.04,
            }, 0.4):Play()
            Tween(Blur, {Size = 12}, 0.35):Play()
        else
            Tween(Main, {
                Size = UDim2.fromOffset(GUI_WIDTH, 0),
                BackgroundTransparency = 1,
            }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()
            Tween(Blur, {Size = 0}, 0.3):Play()
            task.delay(0.3, function()
                if not GUIVisible then
                    Main.Visible = false
                    Background.Visible = false
                end
            end)
        end
    end
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if ListeningForKey then
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                Config.ToggleKey = input.KeyCode
                KeybindButton.Text = Config.ToggleKey.Name
                ListeningForKey = false
                Tween(KeybindButton, {BackgroundTransparency = 0.18}, 0.2):Play()
            end
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Config.ToggleKey then
            SetGUIVisible(not GUIVisible)
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        SetGUIVisible(false)
    end)
    
    local function Hover(button, normal, hover)
        button.MouseEnter:Connect(function()
            Tween(button, {BackgroundTransparency = hover}, 0.15):Play()
        end)
        button.MouseLeave:Connect(function()
            Tween(button, {BackgroundTransparency = normal}, 0.15):Play()
        end)
    end
    
    Hover(CloseBtn, 0.2, 0.05)
    Hover(KeybindButton, 0.18, 0.05)
    
    Main.Size = UDim2.fromOffset(GUI_WIDTH, 0)
    SetGUIVisible(true)
    
    return ScreenGui
end

--==================================================
-- MAIN ENTRY
--==================================================

UI.Build()

RunService.RenderStepped:Connect(function()
    Visuals.Update()
    
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            Combat.SetupFullAuto(tool)
            if Config.RapidFire and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                Combat.FrameTeleportActivate(tool, true)
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and not Config.RapidFire then
                Combat.FrameTeleportActivate(tool, false)
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    Combat.Reset()
    Targeting.SelectedTarget = nil
    Config.Spectate = false
    Targeting.StopSpectate()
end)

print("[ZeeHood] HvH Suite loaded.")
print("[ZeeHood] Toggle UI with " .. Config.ToggleKey.Name)