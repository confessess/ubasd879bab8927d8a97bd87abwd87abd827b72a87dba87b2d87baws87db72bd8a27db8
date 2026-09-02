local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UI = {
    Config = nil,
    Targeting = nil,
    Combat = nil,
    ScreenGui = nil,
    Main = nil,
    HotkeyDisplay = nil,
    GUIVisible = false,
    ListeningKey = nil,
    ToggleCallbacks = {},
    KeybindButtons = {},
}

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

function UI.SetConfig(config)
    UI.Config = config
end

function UI.SetTargeting(targeting)
    UI.Targeting = targeting
end

function UI.SetCombat(combat)
    UI.Combat = combat
end

function UI.SetMisc(misc)
    UI.Misc = misc
end

function UI.UpdateHotkeyDisplay()
    local Config = UI.Config
    if not Config or not UI.HotkeyDisplay then return end
    for _, child in ipairs(UI.HotkeyDisplay:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    if not Config.ShowHotkeys then
        UI.HotkeyDisplay.Visible = false
        return
    end
    UI.HotkeyDisplay.Visible = not UI.GUIVisible
    local y = 6
    local function addLine(text)
        New("TextLabel", {
            Size = UDim2.new(1, -16, 0, 18),
            Position = UDim2.fromOffset(8, y),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Color3.fromRGB(195, 175, 220),
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 51,
        }, UI.HotkeyDisplay)
        y = y + 16
    end
    addLine("MENU  •  " .. Config.ToggleKey.Name)
    for toggleId, _ in pairs(UI.ToggleCallbacks) do
        local key = Config[toggleId .. "Key"]
        if key then
            local name = toggleId:gsub("([A-Z])", " %1")
            name = name:gsub("^%s", "")
            name = string.upper(name):sub(1, 12)
            addLine(name .. "  •  " .. key.Name)
        end
    end
    UI.HotkeyDisplay.Size = UDim2.fromOffset(155, math.max(36, y + 4))
end
function UI.Build()
    local Config = UI.Config
    if not Config then return end
    UI.ToggleCallbacks = {}
    UI.KeybindButtons = {}
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
    UI.ScreenGui = ScreenGui
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
                local ft = math.random(5, 15) / 10
                Tween(star, {BackgroundTransparency = math.random(15, 55) / 100}, ft, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
                task.wait(ft)
                Tween(star, {BackgroundTransparency = math.random(65, 95) / 100}, ft, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
                task.wait(ft + math.random(1, 15) / 10)
            end
        end)
    end
    local Blur = New("BlurEffect", {
        Name = "ZeeHoodBlur",
        Size = 0,
    }, Lighting)
    local GUI_WIDTH, GUI_HEIGHT = 760, 540
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
    UI.Main = Main
    Corner(Main, 20)
    Stroke(Main, 0.72, 1)
    New("Frame", {
        Size = UDim2.new(1, -40, 0, 1),
        Position = UDim2.fromOffset(20, 1),
        BackgroundColor3 = Color3.fromRGB(195, 140, 255),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 11,
    }, Main)
    Corner(Main, 1)
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
        Text = "Stars.cc",
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
        Text = "Made by confess",
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
    local TabNames = {"Combat", "Visuals", "Target", "Misc", "Settings"}
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
    local function CreateToggle(parent, y, text, default, toggleId, hasHotkey, callback)
        local frame = New("Frame", {
            Size = UDim2.new(1, -20, 0, 32),
            Position = UDim2.fromOffset(10, y),
            BackgroundTransparency = 1,
            ZIndex = 16,
        }, parent)
        local labelWidth = hasHotkey and 168 or 120
        New("TextLabel", {
            Size = UDim2.new(1, -labelWidth, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Color3.fromRGB(200, 190, 215),
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 17,
        }, frame)
        if hasHotkey and toggleId then
            local keybindKey = Config[toggleId .. "Key"]
            local keyBtn = New("TextButton", {
                Size = UDim2.fromOffset(44, 20),
                Position = UDim2.new(1, -102, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(45, 65, 110),
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Text = keybindKey and keybindKey.Name or "—",
                TextColor3 = Color3.fromRGB(180, 180, 200),
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                ZIndex = 17,
            }, frame)
            Corner(keyBtn, 5)
            keyBtn.MouseButton1Click:Connect(function()
                if UI.ListeningKey then return end
                UI.ListeningKey = toggleId
                keyBtn.Text = "..."
                Tween(keyBtn, {BackgroundTransparency = 0}, 0.2):Play()
            end)
            UI.KeybindButtons[toggleId] = keyBtn
        end
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
        local function setState(newState)
            state = newState
            Tween(toggle, {BackgroundColor3 = state and PURPLE or Color3.fromRGB(50, 50, 60)}, 0.2):Play()
            Tween(knob, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2):Play()
            callback(state)
        end
        toggle.MouseButton1Click:Connect(function()
            setState(not state)
        end)
        if toggleId then
            UI.ToggleCallbacks[toggleId] = setState
        end
        return setState
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
    local function CreateActionButton(parent, y, text, callback)
        local btn = New("TextButton", {
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.fromOffset(10, y),
            BackgroundColor3 = PURPLE,
            BackgroundTransparency = 0.18,
            BorderSizePixel = 0,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 250, 255),
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            ZIndex = 16,
        }, parent)
        Corner(btn, 8)
        btn.MouseButton1Click:Connect(callback)
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.05}, 0.15):Play()
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.18}, 0.15):Play()
        end)
        return btn
    end
    --// Dropdown helper: returns {Container, Header, List, setText, isOpen}
    local function BuildDropdown(parent, y, labelText, currentValue, options, onSelect)
        New("TextLabel", {
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.fromOffset(10, y),
            BackgroundTransparency = 1,
            Text = labelText,
            TextColor3 = Color3.fromRGB(200, 190, 215),
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 16,
        }, parent)
        local container = New("Frame", {
            Size = UDim2.new(1, -20, 0, 32),
            Position = UDim2.fromOffset(10, y + 24),
            BackgroundColor3 = Color3.fromRGB(22, 14, 32),
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            ZIndex = 16,
        }, parent)
        Corner(container, 8)
        Stroke(container, 0.85, 1, Color3.fromRGB(140, 90, 200))
        local header = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Color3.fromRGB(22, 14, 32),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Text = "  " .. currentValue .. "  ▼",
            TextColor3 = Color3.fromRGB(220, 215, 235),
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            ZIndex = 17,
        }, container)
        Corner(header, 8)
        -- List is a Frame parented to Main, positioned absolutely over the container
        local list = New("Frame", {
            Size = UDim2.fromOffset(0, 0),
            Position = UDim2.fromOffset(0, 0),
            BackgroundColor3 = Color3.fromRGB(18, 11, 27),
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            ZIndex = 100,
            ClipsDescendants = true,
            Visible = false,
        }, Main)
        Corner(list, 8)
        Stroke(list, 0.9, 1, Color3.fromRGB(140, 90, 200))
        local open = false
        local itemHeight = 26
        local itemGap = 2
        local padding = 4
        local totalHeight = #options * itemHeight + (#options - 1) * itemGap + padding * 2
        local optionButtons = {}
        for i, optText in ipairs(options) do
            local btn = New("TextButton", {
                Size = UDim2.new(1, -padding * 2, 0, itemHeight),
                Position = UDim2.fromOffset(padding, padding + (i - 1) * (itemHeight + itemGap)),
                BackgroundColor3 = Color3.fromRGB(30, 20, 42),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = optText,
                TextColor3 = Color3.fromRGB(180, 170, 200),
                TextSize = 11,
                Font = Enum.Font.GothamMedium,
                AutoButtonColor = false,
                ZIndex = 101,
            }, list)
            Corner(btn, 4)
            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundTransparency = 0.3, TextColor3 = Color3.fromRGB(235, 220, 255)}, 0.15):Play()
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180, 170, 200)}, 0.15):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                onSelect(optText)
                header.Text = "  " .. optText .. "  ▼"
                open = false
                Tween(list, {Size = UDim2.fromOffset(container.AbsoluteSize.X, 0)}, 0.2):Play()
                task.delay(0.2, function()
                    if not open then list.Visible = false end
                end)
            end)
            optionButtons[i] = btn
        end
        local function updatePosition()
            local absPos = container.AbsolutePosition
            local absSize = container.AbsoluteSize
            list.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 2)
        end
        header.MouseButton1Click:Connect(function()
            open = not open
            if open then
                updatePosition()
                list.Visible = true
                header.Text = "  " .. currentValue .. "  ▲"
                Tween(list, {Size = UDim2.fromOffset(container.AbsoluteSize.X, math.min(140, totalHeight))}, 0.2):Play()
            else
                header.Text = "  " .. currentValue .. "  ▼"
                Tween(list, {Size = UDim2.fromOffset(container.AbsoluteSize.X, 0)}, 0.2):Play()
                task.delay(0.2, function()
                    if not open then list.Visible = false end
                end)
            end
        end)
        return {
            Container = container,
            Header = header,
            List = list,
            IsOpen = function() return open end,
            Close = function()
                open = false
                header.Text = "  " .. currentValue .. "  ▼"
                Tween(list, {Size = UDim2.fromOffset(container.AbsoluteSize.X, 0)}, 0.2):Play()
                task.delay(0.2, function()
                    if not open then list.Visible = false end
                end)
            end,
            SetValue = function(v)
                currentValue = v
                header.Text = "  " .. v .. "  ▼"
            end,
        }
    end
    --// COMBAT PAGE
    local CombatPage = Pages.Combat
    PageTitle(CombatPage, "Combat", "Frame teleport shoot, rapid fire, and hotkeys.")
    local CombatCard = CreateCard(CombatPage, UDim2.fromOffset(10, 72), UDim2.new(1, -20, 0, 140))
    CreateToggle(CombatCard, 14, "Frame TP Shoot", Config.FrameTP, "FrameTP", true, function(v)
        Config.FrameTP = v
    end)
    CreateToggle(CombatCard, 50, "One-Frame Delay", Config.OneFrameDelay, "OneFrameDelay", true, function(v)
        Config.OneFrameDelay = v
    end)
    CreateToggle(CombatCard, 86, "Rapid Fire", Config.RapidFire, "RapidFire", true, function(v)
        Config.RapidFire = v
    end)

    --// VISUALS PAGE
    local VisualsPage = Pages.Visuals
    PageTitle(VisualsPage, "Visuals", "FOV, tracers, hitmarkers, and target highlighting.")
    local VisualsCard = CreateCard(VisualsPage, UDim2.fromOffset(10, 72), UDim2.new(1, -20, 0, 236))
    CreateToggle(VisualsCard, 14, "FOV Circle", Config.FOV_Enabled, "FOV_Enabled", false, function(v)
        Config.FOV_Enabled = v
    end)
    CreateSlider(VisualsCard, 50, "FOV Radius", 50, 600, Config.FOV_Radius, function(v)
        Config.FOV_Radius = v
    end)
    CreateToggle(VisualsCard, 110, "Tracers", Config.Tracers, "Tracers", false, function(v)
        Config.Tracers = v
    end)
    CreateToggle(VisualsCard, 146, "Highlights", Config.Highlights, "Highlights", false, function(v)
        Config.Highlights = v
    end)
    CreateToggle(VisualsCard, 182, "Hitmarkers", Config.Hitmarkers, "Hitmarkers", false, function(v)
        Config.Hitmarkers = v
    end)

    --// TARGET PAGE
    local TargetPage = Pages.Target
    PageTitle(TargetPage, "Target", "Player selection, part targeting, and spectate.")
    local TargetCard = CreateCard(TargetPage, UDim2.fromOffset(10, 72), UDim2.new(1, -20, 0, 310))
    local targetPartDropdown = BuildDropdown(TargetCard, 14, "Target Part", Config.TargetPart,
        {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "LeftLeg", "RightLeg"},
        function(v) Config.TargetPart = v end)
    CreateActionButton(TargetCard, 76, "TP to Target", function()
        if UI.Targeting and UI.Targeting.TeleportToTarget then
            UI.Targeting.TeleportToTarget()
        end
    end)
    local mainSpectateSetState = CreateToggle(TargetCard, 114, "Spectate Target", Config.Spectate, "Spectate", true, function(v)
        Config.Spectate = v
        if not v then
            UI.Targeting.StopSpectate()
        end
    end)
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.fromOffset(10, 152),
        BackgroundTransparency = 1,
        Text = "Player List",
        TextColor3 = Color3.fromRGB(160, 150, 175),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, TargetCard)
    local PlayerList = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 0, 120),
        Position = UDim2.fromOffset(10, 172),
        BackgroundColor3 = Color3.fromRGB(12, 8, 18),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(100, 70, 150),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 16,
    }, TargetCard)
    Corner(PlayerList, 8)
    New("UIListLayout", {Padding = UDim.new(0, 2), Parent = PlayerList})
        --// MISC PAGE
    local MiscPage = Pages.Misc
    PageTitle(MiscPage, "Misc", "AntiStomp, teleport spam, auto armor, and utility features.")
    local MiscScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -72),
        Position = UDim2.fromOffset(10, 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(100, 70, 150),
        CanvasSize = UDim2.new(0, 0, 0, 710),
        ZIndex = 14,
    }, MiscPage)

    local MiscCard = CreateCard(MiscScroll, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 700))

    --// AntiStomp
    CreateToggle(MiscCard, 14, "AntiStomp", Config.AntiStomp, "AntiStomp", true, function(v)
        Config.AntiStomp = v
        if UI.Misc then
            UI.Misc.SetAntiStomp(v)
        end
    end)
    local antiStompDropdown = BuildDropdown(MiscCard, 54, "AntiStomp Mode", Config.AntiStompMode or "Void",
        {"Void", "Force Reset"},
        function(v) Config.AntiStompMode = v end)

    --// Divider
    New("Frame", {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.fromOffset(10, 118),
        BackgroundColor3 = Color3.fromRGB(60, 40, 80),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 16,
    }, MiscCard)

    --// Teleport Spam
    CreateToggle(MiscCard, 132, "Teleport Spam", Config.SpamEnabled, "SpamEnabled", true, function(v)
        Config.SpamEnabled = v
        if UI.Misc then
            UI.Misc.ToggleSpam(v)
        end
    end)
    local spamRangeDropdown = BuildDropdown(MiscCard, 172, "Spam Range", Config.SpamRange or "Close",
        {"Close", "Far"},
        function(v) Config.SpamRange = v end)
    CreateSlider(MiscCard, 244, "Close Height", 50, 1000, Config.SpamCloseHeight or 350, function(v)
        Config.SpamCloseHeight = v
    end)
    CreateSlider(MiscCard, 300, "Close Radius", 50, 1000, Config.SpamCloseRadius or 250, function(v)
        Config.SpamCloseRadius = v
    end)
    CreateSlider(MiscCard, 356, "Far Jitter", 0, 50000, Config.SpamFarJitter or 5000, function(v)
        Config.SpamFarJitter = v
    end)
    CreateSlider(MiscCard, 412, "Spam Speed", 1, 10, Config.SpamSpeed or 1, function(v)
        Config.SpamSpeed = v
    end)

    --// Divider
    New("Frame", {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.fromOffset(10, 474),
        BackgroundColor3 = Color3.fromRGB(60, 40, 80),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 16,
    }, MiscCard)

        --// Auto Armor
    CreateToggle(MiscCard, 488, "Auto Armor", Config.AutoArmor, "AutoArmor", true, function(v)
        Config.AutoArmor = v
        if UI.Misc then
            UI.Misc.SetAutoArmor(v)
        end
    end)
    CreateToggle(MiscCard, 528, "Armor On Any Damage", Config.AutoArmorOnDamage, "AutoArmorOnDamage", true, function(v)
        Config.AutoArmorOnDamage = v
        if UI.Misc then
            UI.Misc.EvaluateHealthHook()
        end
    end)

    --// Position display + set button
    local armorPos = Config.AutoArmorPos or Vector3.new(0, 0, 0)
    local ArmorPosLabel = Instance.new("TextLabel")
    ArmorPosLabel.Size = UDim2.new(0.6, 0, 0, 16)
    ArmorPosLabel.Position = UDim2.new(0.05, 0, 0, 562)
    ArmorPosLabel.BackgroundTransparency = 1
    ArmorPosLabel.Text = string.format("Pos: %.0f, %.0f, %.0f", armorPos.X, armorPos.Y, armorPos.Z)
    ArmorPosLabel.TextColor3 = Color3.fromRGB(130, 130, 150)
    ArmorPosLabel.Font = Enum.Font.Gotham
    ArmorPosLabel.TextSize = 10
    ArmorPosLabel.TextXAlignment = Enum.TextXAlignment.Left
    ArmorPosLabel.Parent = MiscCard

    local SetPosBtn = Instance.new("TextButton")
    SetPosBtn.Size = UDim2.new(0.3, 0, 0, 20)
    SetPosBtn.Position = UDim2.new(0.65, 0, 0, 560)
    SetPosBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 120)
    SetPosBtn.Text = "Set Pos"
    SetPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SetPosBtn.Font = Enum.Font.GothamBold
    SetPosBtn.TextSize = 10
    SetPosBtn.Parent = MiscCard

    local SetPosCorner = Instance.new("UICorner")
    SetPosCorner.CornerRadius = UDim.new(0, 6)
    SetPosCorner.Parent = SetPosBtn

    SetPosBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = hrp.Position
                Config.AutoArmorPos = pos
                ArmorPosLabel.Text = string.format("Pos: %.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z)
                --// Also update the cached detector
                if UI.Misc then
                    UI.Misc.CacheArmorClickDetector()
                end
            end
        end
    end)

    CreateSlider(MiscCard, 588, "Trigger Health", 1, 100, Config.AutoArmorTriggerHealth or 50, function(v)
        Config.AutoArmorTriggerHealth = v
    end)
    CreateSlider(MiscCard, 644, "Cooldown", 1, 30, Config.AutoArmorCooldown or 5, function(v)
        Config.AutoArmorCooldown = v
    end)
    --// SPECTATE PANEL (middle-right, shows when spectating)
    local SpectatePanel = New("Frame", {
        Size = UDim2.fromOffset(200, 320),
        Position = UDim2.new(1, -220, 0.5, -160),
        BackgroundColor3 = Color3.fromRGB(9, 6, 15),
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ZIndex = 60,
        Visible = false,
    }, ScreenGui)
    Corner(SpectatePanel, 16)
    Stroke(SpectatePanel, 0.72, 1)
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        Text = "SPECTATE",
        TextColor3 = Color3.fromRGB(245, 240, 250),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 61,
    }, SpectatePanel)
    local panelSpectateSetState = CreateToggle(SpectatePanel, 42, "Spectate Target", Config.Spectate, "SpectatePanel", false, function(v)
        Config.Spectate = v
        if not v then
            UI.Targeting.StopSpectate()
            SpectatePanel.Visible = false
            SetGUIVisible(true)
        end
        if UI.ToggleCallbacks["Spectate"] then
            UI.ToggleCallbacks["Spectate"](v)
        end
    end)
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.fromOffset(10, 82),
        BackgroundTransparency = 1,
        Text = "Player List",
        TextColor3 = Color3.fromRGB(160, 150, 175),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 61,
    }, SpectatePanel)
    local PanelPlayerList = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -108),
        Position = UDim2.fromOffset(10, 102),
        BackgroundColor3 = Color3.fromRGB(12, 8, 18),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(100, 70, 150),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 61,
    }, SpectatePanel)
    Corner(PanelPlayerList, 8)
    New("UIListLayout", {Padding = UDim.new(0, 2), Parent = PanelPlayerList})

    --// Shared refresh for both player lists
    local function refreshAllLists()
        UI.Targeting.RefreshPlayerList(PlayerList, refreshAllLists)
        UI.Targeting.RefreshPlayerList(PanelPlayerList, refreshAllLists)
    end
    refreshAllLists()
    Players.PlayerAdded:Connect(refreshAllLists)
    Players.PlayerRemoving:Connect(refreshAllLists)

    --// Spectate mode handler
    local function SetSpectateMode(enabled)
        Config.Spectate = enabled
        if enabled then
            SetGUIVisible(false)
            SpectatePanel.Visible = true
        else
            UI.Targeting.StopSpectate()
            SpectatePanel.Visible = false
            SetGUIVisible(true)
        end
        if UI.ToggleCallbacks["Spectate"] then
            UI.ToggleCallbacks["Spectate"](enabled)
        end
        if UI.ToggleCallbacks["SpectatePanel"] then
            UI.ToggleCallbacks["SpectatePanel"](enabled)
        end
    end

    --// Override main spectate callback to use SetSpectateMode
    local origSpectateCallback = UI.ToggleCallbacks["Spectate"]
    UI.ToggleCallbacks["Spectate"] = function(enabled)
        origSpectateCallback(enabled)
        if enabled ~= SpectatePanel.Visible then
            SetSpectateMode(enabled)
        end
    end
    --// SETTINGS PAGE
    local SettingsPage = Pages.Settings
    PageTitle(SettingsPage, "Settings", "Interface customization and hotkey display.")
    local SettingsCard = CreateCard(SettingsPage, UDim2.fromOffset(10, 72), UDim2.new(1, -20, 0, 200))
    New("TextLabel", {
        Size = UDim2.new(1, -140, 0, 25),
        Position = UDim2.fromOffset(15, 14),
        BackgroundTransparency = 1,
        Text = "Menu Toggle Key",
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
        Position = UDim2.new(1, -130, 0, 14),
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
    CreateToggle(SettingsCard, 90, "Show Hotkeys", Config.ShowHotkeys, "ShowHotkeys", false, function(v)
        Config.ShowHotkeys = v
        UI.UpdateHotkeyDisplay()
    end)

    --// Hotkey Display
    local HotkeyDisplay = New("Frame", {
        Name = "HotkeyDisplay",
        Size = UDim2.fromOffset(155, 36),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -20, 0, 20),
        BackgroundColor3 = Color3.fromRGB(15, 9, 23),
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
    }, ScreenGui)
    Corner(HotkeyDisplay, 10)
    Stroke(HotkeyDisplay, 0.88, 1)
    UI.HotkeyDisplay = HotkeyDisplay

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
        -- close all dropdowns on tab switch
        if targetPartDropdown and targetPartDropdown.IsOpen() then
            targetPartDropdown.Close()
        end
        if antiStompDropdown and antiStompDropdown.IsOpen() then
            antiStompDropdown.Close()
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
    UI.ListeningKey = nil
    KeybindButton.MouseButton1Click:Connect(function()
        if UI.ListeningKey then return end
        UI.ListeningKey = "Toggle"
        KeybindButton.Text = "PRESS KEY"
        Tween(KeybindButton, {BackgroundTransparency = 0}, 0.2):Play()
    end)

    --// GUI Toggle
    local function SetGUIVisible(visible)
        UI.GUIVisible = visible
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
                if not UI.GUIVisible then
                    Main.Visible = false
                    Background.Visible = false
                end
            end)
        end
        UI.UpdateHotkeyDisplay()
    end
    UI.SetGUIVisible = SetGUIVisible

    --// Input Handler
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if UI.ListeningKey then
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Backspace then
                    if UI.ListeningKey == "Toggle" then
                        -- cannot unbind menu toggle
                    else
                        Config[UI.ListeningKey .. "Key"] = nil
                        local btn = UI.KeybindButtons[UI.ListeningKey]
                        if btn then btn.Text = "—" end
                    end
                else
                    if UI.ListeningKey == "Toggle" then
                        Config.ToggleKey = input.KeyCode
                        KeybindButton.Text = Config.ToggleKey.Name
                    elseif UI.ToggleCallbacks[UI.ListeningKey] then
                        Config[UI.ListeningKey .. "Key"] = input.KeyCode
                        local btn = UI.KeybindButtons[UI.ListeningKey]
                        if btn then btn.Text = input.KeyCode.Name end
                    end
                end
                UI.ListeningKey = nil
                Tween(KeybindButton, {BackgroundTransparency = 0.18}, 0.2):Play()
                for _, btn in pairs(UI.KeybindButtons) do
                    Tween(btn, {BackgroundTransparency = 0.2}, 0.2):Play()
                end
                UI.UpdateHotkeyDisplay()
            end
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Config.ToggleKey then
                SetGUIVisible(not UI.GUIVisible)
                return
            end
            for toggleId, callback in pairs(UI.ToggleCallbacks) do
                local key = Config[toggleId .. "Key"]
                if key and input.KeyCode == key then
                    callback(not Config[toggleId])
                    return
                end
            end
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

return UI