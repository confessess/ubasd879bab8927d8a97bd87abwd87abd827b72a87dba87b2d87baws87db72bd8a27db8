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
    Connections = {},
}

local Themes = {
    Palettes = {
        Purple = {
            Accent = Color3.fromRGB(145, 75, 255),
            AccentLight = Color3.fromRGB(195, 140, 255),
            BgMain = Color3.fromRGB(9, 6, 15),
            BgCard = Color3.fromRGB(18, 11, 27),
            BgSidebar = Color3.fromRGB(16, 10, 24),
            BgBackdrop = Color3.fromRGB(4, 3, 9),
            BgHotkey = Color3.fromRGB(15, 9, 23),
            BgPicker = Color3.fromRGB(14, 9, 22),
            BgList = Color3.fromRGB(12, 8, 18),
            TextTitle = Color3.fromRGB(245, 238, 250),
            TextSubtitle = Color3.fromRGB(145, 125, 165),
            TextPageTitle = Color3.fromRGB(245, 240, 250),
            TextPageDesc = Color3.fromRGB(135, 120, 150),
            TextLabel = Color3.fromRGB(200, 190, 215),
            TextSection = Color3.fromRGB(245, 220, 255),
            TextTabInactive = Color3.fromRGB(145, 135, 160),
            TextTabActive = Color3.fromRGB(235, 220, 255),
            TextHotkey = Color3.fromRGB(195, 175, 220),
            StrokeMain = Color3.fromRGB(180, 120, 255),
            StrokeCard = Color3.fromRGB(140, 90, 200),
            StrokeInput = Color3.fromRGB(80, 60, 100),
            ToggleOff = Color3.fromRGB(50, 50, 60),
            SliderTrack = Color3.fromRGB(40, 40, 50),
            CloseBtn = Color3.fromRGB(145, 45, 175),
            PanicBtn = Color3.fromRGB(200, 50, 50),
            KeybindBg = Color3.fromRGB(45, 65, 110),
            UnbindBg = Color3.fromRGB(80, 80, 90),
            DropdownBg = Color3.fromRGB(22, 14, 32),
            DropdownItem = Color3.fromRGB(30, 20, 42),
            Gradient0 = Color3.fromRGB(22, 8, 38),
            Gradient50 = Color3.fromRGB(5, 3, 10),
            Gradient100 = Color3.fromRGB(27, 7, 45),
            Stars = Color3.fromRGB(220, 195, 255),
            Scrollbar = Color3.fromRGB(145, 75, 255),
            Separator = Color3.fromRGB(60, 40, 80),
            DropdownText = Color3.fromRGB(220, 215, 235),
            DropdownOption = Color3.fromRGB(180, 170, 200),
            DropdownHover = Color3.fromRGB(235, 220, 255),
            PickerLabel = Color3.fromRGB(160, 150, 175),
            ArmorPos = Color3.fromRGB(130, 130, 150),
            SetPosBtn = Color3.fromRGB(80, 60, 120),
            ActionBtnText = Color3.fromRGB(255, 250, 255),
            CloseBtnText = Color3.fromRGB(255, 245, 255),
            KeybindText = Color3.fromRGB(180, 180, 200),
            UnbindText = Color3.fromRGB(200, 200, 210),
            HelpText = Color3.fromRGB(140, 130, 155),
            ErrorRed = Color3.fromRGB(255, 80, 80),
            SuccessGreen = Color3.fromRGB(80, 255, 80),
        },
        Monochrome = {
            Accent = Color3.fromRGB(255, 255, 255),
            AccentLight = Color3.fromRGB(255, 255, 255),
            BgMain = Color3.fromRGB(0, 0, 0),
            BgCard = Color3.fromRGB(0, 0, 0),
            BgSidebar = Color3.fromRGB(0, 0, 0),
            BgBackdrop = Color3.fromRGB(0, 0, 0),
            BgHotkey = Color3.fromRGB(0, 0, 0),
            BgPicker = Color3.fromRGB(0, 0, 0),
            BgList = Color3.fromRGB(0, 0, 0),
            TextTitle = Color3.fromRGB(255, 255, 255),
            TextSubtitle = Color3.fromRGB(150, 150, 150),
            TextPageTitle = Color3.fromRGB(255, 255, 255),
            TextPageDesc = Color3.fromRGB(150, 150, 150),
            TextLabel = Color3.fromRGB(200, 200, 200),
            TextSection = Color3.fromRGB(255, 255, 255),
            TextTabInactive = Color3.fromRGB(160, 160, 160),
            TextTabActive = Color3.fromRGB(255, 255, 255),
            TextHotkey = Color3.fromRGB(180, 180, 180),
            StrokeMain = Color3.fromRGB(255, 255, 255),
            StrokeCard = Color3.fromRGB(200, 200, 200),
            StrokeInput = Color3.fromRGB(120, 120, 120),
            ToggleOff = Color3.fromRGB(80, 80, 80),
            SliderTrack = Color3.fromRGB(50, 50, 50),
            CloseBtn = Color3.fromRGB(255, 255, 255),
            PanicBtn = Color3.fromRGB(200, 50, 50),
            KeybindBg = Color3.fromRGB(255, 255, 255),
            UnbindBg = Color3.fromRGB(120, 120, 120),
            DropdownBg = Color3.fromRGB(0, 0, 0),
            DropdownItem = Color3.fromRGB(0, 0, 0),
            Gradient0 = Color3.fromRGB(0, 0, 0),
            Gradient50 = Color3.fromRGB(0, 0, 0),
            Gradient100 = Color3.fromRGB(0, 0, 0),
            Stars = Color3.fromRGB(255, 255, 255),
            Scrollbar = Color3.fromRGB(255, 255, 255),
            Separator = Color3.fromRGB(255, 255, 255),
            DropdownText = Color3.fromRGB(255, 255, 255),
            DropdownOption = Color3.fromRGB(180, 180, 180),
            DropdownHover = Color3.fromRGB(255, 255, 255),
            PickerLabel = Color3.fromRGB(160, 160, 160),
            ArmorPos = Color3.fromRGB(140, 140, 140),
            SetPosBtn = Color3.fromRGB(255, 255, 255),
            ActionBtnText = Color3.fromRGB(0, 0, 0),
            CloseBtnText = Color3.fromRGB(0, 0, 0),
            KeybindText = Color3.fromRGB(0, 0, 0),
            UnbindText = Color3.fromRGB(0, 0, 0),
            HelpText = Color3.fromRGB(150, 150, 150),
            ErrorRed = Color3.fromRGB(255, 80, 80),
            SuccessGreen = Color3.fromRGB(80, 255, 80),
        },
    },
    Names = {"Purple", "Monochrome"},
}

function Themes.Get(name)
    return Themes.Palettes[name] or Themes.Palettes.Purple
end

local BackgroundTextures = {
    None = nil,
    ["Catgirl Black"] = "rbxassetid://100444103656384",
    ["Catgirl Pink"] = "rbxassetid://74265591038566",
    ["2 Catgirls"] = "rbxassetid://135809148867647",
}

local BackgroundTextureNames = {"None", "Catgirl Black", "Catgirl Pink", "2 Catgirls"}

local Theme = nil

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
        Color = color or Theme.StrokeMain,
        Transparency = transparency or 0.72,
        Thickness = thickness or 1,
    }, parent)
end

local function Tween(object, properties, duration, style, direction)
    local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    return TweenService:Create(object, info, properties)
end

local function FormatKeyName(key)
    if not key then return "—" end
    if typeof(key) == "EnumItem" then
        if key.EnumType == Enum.KeyCode then
            return key.Name
        elseif key.EnumType == Enum.UserInputType then
            if key == Enum.UserInputType.MouseButton1 then return "MB1"
            elseif key == Enum.UserInputType.MouseButton2 then return "MB2"
            elseif key == Enum.UserInputType.MouseButton3 then return "MB3"
            else return key.Name end
        end
    end
    return tostring(key)
end

local function IsSameKey(input, storedKey)
    if not storedKey then return false end
    if typeof(storedKey) == "EnumItem" and storedKey.EnumType == Enum.KeyCode then
        return input.KeyCode == storedKey
    elseif typeof(storedKey) == "EnumItem" and storedKey.EnumType == Enum.UserInputType then
        return input.UserInputType == storedKey
    end
    return false
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

function UI.SetFarm(farm)
    UI.Farm = farm
end

function UI.SetMovement(movement)
    UI.Movement = movement
end

function UI.SetVisuals(visuals)
    UI.Visuals = visuals
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
            TextColor3 = Theme.TextHotkey,
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
            addLine(name .. "  •  " .. FormatKeyName(key))
        end
    end
    local aimKey = Config.Aimbot_EnabledKey
    if aimKey then
        addLine("AIMBOT  •  " .. FormatKeyName(aimKey))
    end
    UI.HotkeyDisplay.Size = UDim2.fromOffset(155, math.max(36, y + 4))
end

function UI.Build()
    local Config = UI.Config
    Theme = Themes.Get(Config.GUIThemeName or "Purple")
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
        BackgroundColor3 = Theme.BgBackdrop,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        ZIndex = 1,
        Visible = false,
    }, ScreenGui)
    New("UIGradient", {
        Rotation = 35,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Gradient0),
            ColorSequenceKeypoint.new(0.5, Theme.Gradient50),
            ColorSequenceKeypoint.new(1, Theme.Gradient100),
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
            BackgroundColor3 = Theme.Stars,
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
        BackgroundColor3 = Theme.BgMain,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ZIndex = 10,
        Visible = false,
        ClipsDescendants = true,
    }, ScreenGui)
    UI.Main = Main
    UI.Background = Background
    Corner(Main, 20)
    Stroke(Main, 0.72, 1)
    New("Frame", {
        Size = UDim2.new(1, -40, 0, 1),
        Position = UDim2.fromOffset(20, 1),
        BackgroundColor3 = Theme.AccentLight,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 11,
    }, Main)
    local TopBar = New("Frame", {
        Size = UDim2.new(1, -30, 0, 62),
        Position = UDim2.fromOffset(15, 10),
        BackgroundTransparency = 1,
        ZIndex = 12,
        Active = true, -- Enable drag
    }, Main)

    -- Drag functionality for window mode
    local dragging = false
    local dragStart = nil
    local startPos = nil

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Config.GUIWindow then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    New("TextLabel", {
        Size = UDim2.fromOffset(400, 27),
        Position = UDim2.fromOffset(8, 3),
        BackgroundTransparency = 1,
        Text = "Stars.cc",
        TextColor3 = Theme.TextTitle,
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
        TextColor3 = Theme.TextSubtitle,
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
    }, TopBar)
    local CloseBtn = New("TextButton", {
        Size = UDim2.fromOffset(34, 34),
        Position = UDim2.new(1, -34, 0, 7),
        BackgroundColor3 = Theme.CloseBtn,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Theme.CloseBtnText,
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
        BackgroundColor3 = Theme.BgSidebar,
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
    local TabNames = {"Combat", "Visuals", "Target", "Farm", "Misc", "World", "Movement", "Settings"}
    local TabButtons = {}
    local Pages = {}
    for index, name in ipairs(TabNames) do
        local button = New("TextButton", {
            Size = UDim2.new(1, -32, 0, 43),
            Position = UDim2.fromOffset(22, 12 + ((index - 1) * 50)),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = Theme.TextTabInactive,
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
            BackgroundColor3 = Theme.AccentLight,
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

    local function ApplyBackgroundImage()
        local textureName = Config.GUIBackgroundImage or "None"
        local textureId = BackgroundTextures[textureName]
        for name, page in pairs(Pages) do
            local existing = page:FindFirstChild("BGImage")
            if existing then
                existing:Destroy()
            end
            if textureId then
                New("ImageLabel", {
                    Name = "BGImage",
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Image = textureId,
                    ImageTransparency = 0.6,
                    ImageColor3 = Color3.fromRGB(255, 255, 255),
                    ScaleType = Enum.ScaleType.Stretch,
                    ZIndex = 1,
                }, page)
            end
        end
    end
    UI.ApplyBackgroundImage = ApplyBackgroundImage

    local function PageTitle(page, title, description)
        New("TextLabel", {
            Size = UDim2.new(1, -20, 0, 28),
            Position = UDim2.fromOffset(10, 7),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Theme.TextPageTitle,
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
            TextColor3 = Theme.TextPageDesc,
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 15,
        }, page)
    end
    local function CreateSeparator(parent, y)
        New("Frame", {
            Size = UDim2.new(1, -20, 0, 1),
            Position = UDim2.fromOffset(10, y),
            BackgroundColor3 = Theme.Separator,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            ZIndex = 16,
        }, parent)
    end

    local function CreateCard(page, position, size)
        local card = New("Frame", {
            Size = size,
            Position = position,
            BackgroundColor3 = Theme.BgCard,
            BackgroundTransparency = 0.35,
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
            TextColor3 = Theme.TextLabel,
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
                BackgroundColor3 = Theme.KeybindBg,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Text = keybindKey and FormatKeyName(keybindKey) or "—",
                TextColor3 = Theme.KeybindText,
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

            -- Unbind button
            local unbindBtn = New("TextButton", {
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.new(1, -126, 0.5, -10),
                BackgroundColor3 = Theme.UnbindBg,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                Text = "−",
                TextColor3 = Theme.UnbindText,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                ZIndex = 17,
            }, frame)
            Corner(unbindBtn, 5)
            unbindBtn.MouseButton1Click:Connect(function()
                Config[toggleId .. "Key"] = nil
                keyBtn.Text = "—"
                UI.UpdateHotkeyDisplay()
            end)
        end
        local toggle = New("TextButton", {
            Size = UDim2.fromOffset(44, 22),
            Position = UDim2.new(1, -50, 0.5, -11),
            BackgroundColor3 = default and Theme.Accent or Theme.ToggleOff,
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
            Tween(toggle, {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff}, 0.2):Play()
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
            TextColor3 = Theme.TextLabel,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 17,
        }, frame)
        local track = New("Frame", {
            Size = UDim2.new(1, 0, 0, 5),
            Position = UDim2.new(0, 0, 0, 30),
            BackgroundColor3 = Theme.SliderTrack,
            BorderSizePixel = 0,
            ZIndex = 17,
        }, frame)
        Corner(track, 3)
        local fill = New("Frame", {
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = Theme.Accent,
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
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.18,
            BorderSizePixel = 0,
            Text = text,
            TextColor3 = Theme.ActionBtnText,
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

    local function BuildDropdown(parent, y, labelText, currentValue, options, onSelect)
        New("TextLabel", {
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.fromOffset(10, y),
            BackgroundTransparency = 1,
            Text = labelText,
            TextColor3 = Theme.TextLabel,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 16,
        }, parent)
        local container = New("Frame", {
            Size = UDim2.new(1, -20, 0, 32),
            Position = UDim2.fromOffset(10, y + 24),
            BackgroundColor3 = Theme.DropdownBg,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            ZIndex = 16,
        }, parent)
        Corner(container, 8)
        Stroke(container, 0.85, 1, Theme.StrokeCard)
        local header = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.DropdownBg,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Text = "  " .. currentValue .. "  ▼",
            TextColor3 = Theme.DropdownText,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            ZIndex = 17,
        }, container)
        Corner(header, 8)

        local open = false
        local itemHeight = 28
        local maxVisible = 8
        local listHeight = math.min(#options, maxVisible) * itemHeight

        -- Parent to same card, position below header — scrolls with page
        local list = New("ScrollingFrame", {
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.fromOffset(10, y + 24 + 32 + 2),
            BackgroundColor3 = Theme.BgCard,
            BackgroundTransparency = 0.02,
            BorderSizePixel = 0,
            ZIndex = 100,
            ClipsDescendants = true,
            Visible = false,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, #options * itemHeight),
        }, parent)
        Corner(list, 8)
        Stroke(list, 0.85, 1, Theme.StrokeCard)

        local optionButtons = {}
        for i, optText in ipairs(options) do
            local btn = New("TextButton", {
                Size = UDim2.new(1, -16, 0, itemHeight - 2),
                Position = UDim2.fromOffset(4, 4 + (i - 1) * itemHeight),
                BackgroundColor3 = Theme.DropdownItem,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = "  " .. optText,
                TextColor3 = Theme.DropdownOption,
                TextSize = 11,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                ZIndex = 101,
            }, list)
            Corner(btn, 4)
            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundTransparency = 0.3, TextColor3 = Theme.TextTabActive}, 0.15):Play()
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundTransparency = 1, TextColor3 = Theme.DropdownOption}, 0.15):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                onSelect(optText)
                header.Text = "  " .. optText .. "  ▼"
                open = false
                Tween(list, {Size = UDim2.new(1, -20, 0, 0)}, 0.2):Play()
                task.delay(0.2, function()
                    if not open then list.Visible = false end
                end)
            end)
            optionButtons[i] = btn
        end

        header.MouseButton1Click:Connect(function()
            open = not open
            if open then
                list.Visible = true
                header.Text = "  " .. currentValue .. "  ▲"
                Tween(list, {Size = UDim2.new(1, -20, 0, listHeight)}, 0.2):Play()
            else
                header.Text = "  " .. currentValue .. "  ▼"
                Tween(list, {Size = UDim2.new(1, -20, 0, 0)}, 0.2):Play()
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
                Tween(list, {Size = UDim2.new(1, -20, 0, 0)}, 0.2):Play()
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

    -- COLOR PICKER (Centered Popup)
    local ActiveColorPicker = nil

    local ColorPickerFrame = New("Frame", {
        Name = "ColorPicker",
        Size = UDim2.fromOffset(300, 300),
        Position = UDim2.new(0.5, -150, 0.5, -150),
        BackgroundColor3 = Theme.BgPicker,
        BackgroundTransparency = 0.03,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 200,
    }, ScreenGui)
    Corner(ColorPickerFrame, 16)
    Stroke(ColorPickerFrame, 0.85, 1.5, Theme.StrokeCard)

    New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.92,
        BorderSizePixel = 0,
        ZIndex = 0,
    }, ColorPickerFrame)

    local CPTitle = New("TextLabel", {
        Size = UDim2.new(1, -48, 0, 30),
        Position = UDim2.fromOffset(18, 10),
        BackgroundTransparency = 1,
        Text = "Color",
        TextColor3 = Theme.TextPageTitle,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 201,
    }, ColorPickerFrame)

    local CPClose = New("TextButton", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -38, 0, 10),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Theme.DropdownOption,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        ZIndex = 201,
    }, ColorPickerFrame)

    local CPState = {
        Hue = 0, Sat = 1, Val = 1,
        Callback = nil, IsOpen = false, JustOpened = false, Dragging = nil,
    }
    local CPUpdatingHex = false
    local CPUI = {}

    local function CPUpdateColor(skipCallback)
        local color = Color3.fromHSV(CPState.Hue, CPState.Sat, CPState.Val)
        if CPUI.Preview then CPUI.Preview.BackgroundColor3 = color end
        if CPUI.HexBox and not CPUpdatingHex then
            CPUpdatingHex = true
            local r = math.floor(color.R * 255 + 0.5)
            local g = math.floor(color.G * 255 + 0.5)
            local b = math.floor(color.B * 255 + 0.5)
            CPUI.HexBox.Text = string.format("#%02X%02X%02X", r, g, b)
            CPUpdatingHex = false
        end
        if CPUI.SatGrad then
            CPUI.SatGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(CPState.Hue, 0, CPState.Val)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(CPState.Hue, 1, CPState.Val))
            })
        end
        if CPUI.ValGrad then
            CPUI.ValGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(CPState.Hue, CPState.Sat, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(CPState.Hue, CPState.Sat, 1))
            })
        end
        if not skipCallback and CPState.Callback then CPState.Callback(color) end
    end

    local function CPMakeSlider(y, labelText)
        New("TextLabel", {
            Size = UDim2.fromOffset(100, 16),
            Position = UDim2.fromOffset(18, y),
            BackgroundTransparency = 1,
            Text = labelText,
            TextColor3 = Theme.PickerLabel,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            ZIndex = 201,
        }, ColorPickerFrame)

        local track = New("Frame", {
            Size = UDim2.new(1, -36, 0, 6),
            Position = UDim2.fromOffset(18, y + 18),
            BackgroundColor3 = Theme.SliderTrack,
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            ZIndex = 201,
        }, ColorPickerFrame)
        Corner(track, 3)

        local gradient = New("UIGradient", {}, track)

        local knob = New("Frame", {
            Size = UDim2.fromOffset(14, 14),
            Position = UDim2.new(0, -7, 0.5, -7),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 203,
        }, track)
        Corner(knob, 7)

        New("UIStroke", {
            Color = Theme.Accent,
            Thickness = 2.5,
        }, knob)

        local function SetKnobPos(v)
            knob.Position = UDim2.new(math.clamp(v, 0, 1), -7, 0.5, -7)
        end
        return gradient, SetKnobPos, track
    end

    local hueGrad, SetHuePos, hueTrack = CPMakeSlider(46, "Hue")
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.1667, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.3333, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.6667, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.8333, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })

    local satGrad, SetSatPos, satTrack = CPMakeSlider(88, "Saturation")
    local valGrad, SetValPos, valTrack = CPMakeSlider(130, "Brightness")
    CPUI.SatGrad = satGrad
    CPUI.ValGrad = valGrad

    New("TextLabel", {
        Size = UDim2.fromOffset(60, 16),
        Position = UDim2.fromOffset(18, 174),
        BackgroundTransparency = 1,
        Text = "Preview",
        TextColor3 = Theme.PickerLabel,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ZIndex = 201,
    }, ColorPickerFrame)

    local previewBox = New("Frame", {
        Size = UDim2.fromOffset(56, 28),
        Position = UDim2.fromOffset(18, 192),
        BackgroundColor3 = Color3.fromHSV(0, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 201,
    }, ColorPickerFrame)
    Corner(previewBox, 8)
    Stroke(previewBox, 0.2, 1, Theme.StrokeCard)
    CPUI.Preview = previewBox

    New("TextLabel", {
        Size = UDim2.fromOffset(60, 16),
        Position = UDim2.fromOffset(88, 174),
        BackgroundTransparency = 1,
        Text = "Hex",
        TextColor3 = Theme.PickerLabel,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ZIndex = 201,
    }, ColorPickerFrame)

    local hexBox = New("TextBox", {
        Size = UDim2.fromOffset(130, 28),
        Position = UDim2.fromOffset(88, 192),
        BackgroundColor3 = Theme.DropdownItem,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Text = "#FF69B4",
        TextColor3 = Theme.TextPageTitle,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 201,
    }, ColorPickerFrame)
    Corner(hexBox, 8)
    Stroke(hexBox, 0.6, 1, Theme.StrokeInput)
    CPUI.HexBox = hexBox

    local function CPGetSliderPos(track)
        local size = track.AbsoluteSize.X
        if size <= 0 then return nil end
        local mousePos = UserInputService:GetMouseLocation()
        return math.clamp((mousePos.X - track.AbsolutePosition.X) / size, 0, 1)
    end

    local function CPEnsureVisibleColor()
        if CPState.Sat < 0.05 then
            CPState.Sat = 0.5
            SetSatPos(0.5)
        end
    end

    local cpDragConn = nil
    local function CPStartDrag(which)
        CPState.Dragging = which
        if cpDragConn then cpDragConn:Disconnect() end
        cpDragConn = game:GetService("RunService").RenderStepped:Connect(function()
            if CPState.Dragging == "hue" then
                local pos = CPGetSliderPos(hueTrack)
                if pos then CPState.Hue = pos; SetHuePos(pos); CPEnsureVisibleColor(); CPUpdateColor() end
            elseif CPState.Dragging == "sat" then
                local pos = CPGetSliderPos(satTrack)
                if pos then CPState.Sat = pos; SetSatPos(pos); CPUpdateColor() end
            elseif CPState.Dragging == "val" then
                local pos = CPGetSliderPos(valTrack)
                if pos then CPState.Val = pos; SetValPos(pos); CPUpdateColor() end
            end
        end)
    end

    local function CPEndDrag()
        CPState.Dragging = nil
        if cpDragConn then cpDragConn:Disconnect() cpDragConn = nil end
    end

    hueTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then CPStartDrag("hue") end
    end)
    satTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then CPStartDrag("sat") end
    end)
    valTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then CPStartDrag("val") end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then CPEndDrag() end
    end)

    local function CPParseHex()
        local text = hexBox.Text:gsub("#", ""):upper()
        if #text == 3 then
            text = text:sub(1,1):rep(2) .. text:sub(2,2):rep(2) .. text:sub(3,3):rep(2)
        end
        if #text ~= 6 then return nil end
        local r = tonumber(text:sub(1,2), 16)
        local g = tonumber(text:sub(3,4), 16)
        local b = tonumber(text:sub(5,6), 16)
        if not r or not g or not b then return nil end
        return Color3.fromRGB(r, g, b)
    end

    local function CPApplyHexColor()
        local color = CPParseHex()
        if not color then
            hexBox:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(255, 80, 80)
            task.delay(0.3, function()
                local s = hexBox:FindFirstChildOfClass("UIStroke")
                if s then s.Color = Theme.StrokeInput end
            end)
            return
        end
        local h, s, v = Color3.toHSV(color)
        CPState.Hue, CPState.Sat, CPState.Val = h, s, v
        SetHuePos(h)
        SetSatPos(s)
        SetValPos(v)
        CPUpdateColor()
        hexBox:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(80, 255, 80)
        task.delay(0.3, function()
            local st = hexBox:FindFirstChildOfClass("UIStroke")
            if st then st.Color = Theme.StrokeInput end
        end)
    end

    hexBox.FocusLost:Connect(CPApplyHexColor)

    local hexTypingConn = nil
    hexBox:GetPropertyChangedSignal("Text"):Connect(function()
        if CPUpdatingHex then return end
        if hexTypingConn then hexTypingConn:Disconnect() end
        hexTypingConn = task.delay(0.5, function()
            hexTypingConn = nil
            CPApplyHexColor()
        end)
    end)

    CPClose.MouseButton1Click:Connect(function()
        ColorPickerFrame.Visible = false
        CPState.IsOpen = false
        CPEndDrag()
        ActiveColorPicker = nil
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if CPState.JustOpened then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 and CPState.IsOpen then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = ColorPickerFrame.AbsolutePosition
            local frameSize = ColorPickerFrame.AbsoluteSize
            if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
               mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                ColorPickerFrame.Visible = false
                CPState.IsOpen = false
                CPEndDrag()
                ActiveColorPicker = nil
            end
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Escape and CPState.IsOpen then
            ColorPickerFrame.Visible = false
            CPState.IsOpen = false
            CPEndDrag()
            ActiveColorPicker = nil
        end
    end)

    local function OpenColorPicker(setCallback, setDefaultColor, setTitle)
        CPState.Callback = setCallback
        CPTitle.Text = setTitle or "Color"
        if setDefaultColor then
            local h, s, v = Color3.toHSV(setDefaultColor)
            CPState.Hue, CPState.Sat, CPState.Val = h, s, v
        end
        SetHuePos(CPState.Hue)
        SetSatPos(CPState.Sat)
        SetValPos(CPState.Val)
        CPUpdateColor(true)
        ColorPickerFrame.Visible = true
        CPState.IsOpen = true
        CPState.JustOpened = true
        ActiveColorPicker = ColorPickerFrame
        task.delay(0.2, function() CPState.JustOpened = false end)
    end

    local function CreateColorButton(parent, y, colorKey, labelText)
        local colorValue = Config.ESP_Colors[colorKey] or Color3.fromRGB(255, 255, 255)
        local circle = New("TextButton", {
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.new(1, -90, 0, y + 8),
            BackgroundColor3 = colorValue,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 17,
        }, parent)
        Corner(circle, 8)
        Stroke(circle, 0.3, 1.5, Color3.fromRGB(255, 255, 255))

        circle.MouseButton1Click:Connect(function()
            if CPState.IsOpen and ActiveColorPicker == ColorPickerFrame then
                ColorPickerFrame.Visible = false
                CPState.IsOpen = false
                CPEndDrag()
                ActiveColorPicker = nil
            else
                OpenColorPicker(function(c)
                    Config.ESP_Colors[colorKey] = c
                    circle.BackgroundColor3 = c
                end, circle.BackgroundColor3, labelText .. " Color")
            end
        end)

        return circle
    end
    -- COMBAT PAGE
    local CombatPage = Pages.Combat
    PageTitle(CombatPage, "Combat", "Aimbot, frame teleport shoot, rapid fire, and hotkeys.")
    local CombatScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -72),
        Position = UDim2.fromOffset(10, 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 14,
    }, CombatPage)
    local CombatCard = CreateCard(CombatScroll, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 990))
    CombatScroll.CanvasSize = UDim2.new(0, 0, 0, 1010)

    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        Text = "Aimbot",
        TextColor3 = Theme.TextSection,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, CombatCard)
    CreateToggle(CombatCard, 34, "Enable Aimbot", Config.Aimbot_Enabled, "Aimbot_Enabled", true, function(v)
        Config.Aimbot_Enabled = v
    end)
    UI.ToggleCallbacks["Aimbot_Enabled"] = nil
    CreateToggle(CombatCard, 70, "Toggle Mode", Config.Aimbot_ToggleMode, "Aimbot_ToggleMode", false, function(v)
        Config.Aimbot_ToggleMode = v
    end)
    CreateToggle(CombatCard, 106, "Sticky Target", Config.Aimbot_StickyTarget, "Aimbot_StickyTarget", false, function(v)
        Config.Aimbot_StickyTarget = v
    end)
    CreateToggle(CombatCard, 142, "Team Check", Config.Aimbot_TeamCheck, "Aimbot_TeamCheck", false, function(v)
        Config.Aimbot_TeamCheck = v
    end)
    CreateToggle(CombatCard, 178, "Wall Check", Config.Aimbot_WallCheck, "Aimbot_WallCheck", false, function(v)
        Config.Aimbot_WallCheck = v
    end)
    CreateToggle(CombatCard, 214, "Show FOV", Config.Aimbot_ShowFOV, "Aimbot_ShowFOV", false, function(v)
        Config.Aimbot_ShowFOV = v
    end)
    CreateSlider(CombatCard, 250, "Smoothness", 0, 100, Config.Aimbot_Smoothness, function(v)
        Config.Aimbot_Smoothness = v
    end)
    CreateSlider(CombatCard, 296, "FOV", 10, 300, Config.Aimbot_FOV, function(v)
        Config.Aimbot_FOV = v
    end)
    local aimbotPartDropdown = BuildDropdown(CombatCard, 342, "Target Part", Config.Aimbot_TargetPart or "Head",
        {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "LeftLeg", "RightLeg"},
        function(v) Config.Aimbot_TargetPart = v end)
    local aimbotPriorityDropdown = BuildDropdown(CombatCard, 400, "Priority", Config.Aimbot_Priority or "Closest to Mouse",
        {"Closest to Mouse", "Closest to Player", "Lowest HP", "Highest HP"},
        function(v) Config.Aimbot_Priority = v end)

    CreateSeparator(CombatCard, 456)

    -- Silent Aim Section
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 466),
        BackgroundTransparency = 1,
        Text = "Silent Aim",
        TextColor3 = Theme.TextSection,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, CombatCard)

    CreateToggle(CombatCard, 490, "Enable Silent Aim", Config.SilentAim_Enabled, "SilentAim_Enabled", true, function(v)
        Config.SilentAim_Enabled = v
        if UI.Combat then
            UI.Combat.SetSilentAimEnabled(v)
        end
    end)

    CreateSlider(CombatCard, 526, "Silent Aim FOV", 30, 300, Config.SilentAim_FOV or 120, function(v)
        Config.SilentAim_FOV = v
    end)

    CreateSlider(CombatCard, 572, "Hit Chance %", 1, 100, Config.SilentAim_HitChance or 100, function(v)
        Config.SilentAim_HitChance = v
    end)

    local silentAimPartDropdown = BuildDropdown(CombatCard, 618, "Target Part", Config.SilentAim_TargetPart or "Head",
        {"Head", "HumanoidRootPart", "Torso", "UpperTorso"},
        function(v) Config.SilentAim_TargetPart = v end)

    CreateToggle(CombatCard, 676, "Wall Check", Config.SilentAim_WallCheck, "SilentAim_WallCheck", false, function(v)
        Config.SilentAim_WallCheck = v
    end)

    CreateToggle(CombatCard, 712, "Team Check", Config.SilentAim_TeamCheck, "SilentAim_TeamCheck", false, function(v)
        Config.SilentAim_TeamCheck = v
    end)

    CreateToggle(CombatCard, 748, "Show FOV", Config.SilentAim_ShowFOV, "SilentAim_ShowFOV", false, function(v)
        Config.SilentAim_ShowFOV = v
    end)

    CreateSeparator(CombatCard, 784)

    -- Combat Section
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 794),
        BackgroundTransparency = 1,
        Text = "Combat",
        TextColor3 = Theme.TextSection,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, CombatCard)

    CreateToggle(CombatCard, 818, "Frame TP Shoot", Config.FrameTP, "FrameTP", true, function(v)
        Config.FrameTP = v
    end)
    CreateToggle(CombatCard, 854, "One-Frame Delay", Config.OneFrameDelay, "OneFrameDelay", true, function(v)
        Config.OneFrameDelay = v
    end)
    CreateToggle(CombatCard, 890, "Rapid Fire", Config.RapidFire, "RapidFire", true, function(v)
        Config.RapidFire = v
    end)
    CreateToggle(CombatCard, 926, "Karma", Config.Karma_Enabled, "Karma_Enabled", true, function(v)
        Config.Karma_Enabled = v
        if UI.Combat then
            UI.Combat.SetKarmaEnabled(v)
        end
    end)

    -- VISUALS PAGE
    local VisualsPage = Pages.Visuals
    PageTitle(VisualsPage, "Visuals", "FOV, ESP suite, tracers, hitmarkers, and target highlighting.")
    local VisualsScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -72),
        Position = UDim2.fromOffset(10, 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 14,
    }, VisualsPage)
    local VisualsCard = CreateCard(VisualsScroll, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 1000))
    VisualsScroll.CanvasSize = UDim2.new(0, 0, 0, 1020)

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

    CreateSeparator(VisualsCard, 226)
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 236),
        BackgroundTransparency = 1,
        Text = "ESP Suite",
        TextColor3 = Theme.TextSection,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, VisualsCard)

    CreateToggle(VisualsCard, 264, "ESP Master", Config.ESP_Enabled, "ESP_Enabled", false, function(v)
        Config.ESP_Enabled = v
    end)
    CreateToggle(VisualsCard, 300, "Boxes", Config.ESP_Boxes, "ESP_Boxes", false, function(v)
        Config.ESP_Boxes = v
    end)
    CreateColorButton(VisualsCard, 300, "Box", "Box")
    CreateToggle(VisualsCard, 336, "3D Boxes", Config.ESP_Box3D, "ESP_Box3D", false, function(v)
        Config.ESP_Box3D = v
    end)
    CreateToggle(VisualsCard, 372, "Names", Config.ESP_Names, "ESP_Names", false, function(v)
        Config.ESP_Names = v
    end)
    CreateColorButton(VisualsCard, 372, "Name", "Name")
    CreateToggle(VisualsCard, 408, "Distance Text", Config.ESP_Distance, "ESP_Distance", false, function(v)
        Config.ESP_Distance = v
    end)
    CreateColorButton(VisualsCard, 408, "Distance", "Distance")
    CreateToggle(VisualsCard, 444, "Health Bar", Config.ESP_Health, "ESP_Health", false, function(v)
        Config.ESP_Health = v
    end)
    CreateColorButton(VisualsCard, 444, "Health", "Health")
    CreateToggle(VisualsCard, 480, "Skeleton", Config.ESP_Skeleton, "ESP_Skeleton", false, function(v)
        Config.ESP_Skeleton = v
    end)
    CreateColorButton(VisualsCard, 480, "Skeleton", "Skeleton")
    CreateToggle(VisualsCard, 516, "Chams", Config.ESP_Chams, "ESP_Chams", false, function(v)
        Config.ESP_Chams = v
    end)
    CreateColorButton(VisualsCard, 516, "ChamsFill", "Chams")
    CreateToggle(VisualsCard, 552, "Head Dot", Config.ESP_HeadDot, "ESP_HeadDot", false, function(v)
        Config.ESP_HeadDot = v
    end)
    CreateColorButton(VisualsCard, 552, "HeadDot", "Head Dot")
    CreateToggle(VisualsCard, 588, "Weapon Names", Config.ESP_WeaponNames, "ESP_WeaponNames", false, function(v)
        Config.ESP_WeaponNames = v
    end)
    CreateToggle(VisualsCard, 624, "Team Check", Config.ESP_TeamCheck, "ESP_TeamCheck", false, function(v)
        Config.ESP_TeamCheck = v
    end)
    CreateToggle(VisualsCard, 660, "Target Mode Only", Config.ESP_TargetMode, "ESP_TargetMode", false, function(v)
        Config.ESP_TargetMode = v
    end)
    CreateToggle(VisualsCard, 696, "Distance Limit", Config.ESP_DistanceToggle, "ESP_DistanceToggle", false, function(v)
        Config.ESP_DistanceToggle = v
    end)
    CreateSlider(VisualsCard, 732, "Max ESP Distance", 50, 5000, Config.ESP_MaxDistance, function(v)
        Config.ESP_MaxDistance = v
    end)
    CreateSlider(VisualsCard, 788, "Box Thickness", 1, 5, Config.ESP_BoxThickness, function(v)
        Config.ESP_BoxThickness = v
    end)
    CreateSlider(VisualsCard, 844, "Head Dot Size", 1, 30, math.floor(Config.ESP_HeadDotSize * 10), function(v)
        Config.ESP_HeadDotSize = v / 10
    end)
    -- TARGET PAGE
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
    CreateToggle(TargetCard, 114, "Spectate Target", Config.Spectate, "Spectate", true, function(v)
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
        TextColor3 = Theme.PickerLabel,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, TargetCard)
    local PlayerList = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 0, 120),
        Position = UDim2.fromOffset(10, 172),
        BackgroundColor3 = Theme.BgList,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 16,
    }, TargetCard)
    Corner(PlayerList, 8)
    New("UIListLayout", {Padding = UDim.new(0, 2), Parent = PlayerList})

    -- FARM PAGE
    local FarmPage = Pages.Farm
    PageTitle(FarmPage, "Farm", "Pull selected target to your crosshair aim point.")
    local FarmScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -72),
        Position = UDim2.fromOffset(10, 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 470),
        ZIndex = 14,
    }, FarmPage)
    local FarmCard = CreateCard(FarmScroll, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 450))
    CreateToggle(FarmCard, 14, "Enable Farm", Config.FarmEnabled, "FarmEnabled", true, function(v)
        Config.FarmEnabled = v
        if UI.Farm then
            UI.Farm.SetEnabled(v)
        end
    end)
    CreateSlider(FarmCard, 50, "Distance (studs)", 3, 30, Config.FarmDistance or 12, function(v)
        Config.FarmDistance = v
    end)
    CreateSlider(FarmCard, 96, "Vertical Offset", -10, 10, Config.FarmVerticalOffset or 0, function(v)
        Config.FarmVerticalOffset = v
    end)
    CreateSlider(FarmCard, 142, "Pull Speed", 1, 20, Config.FarmPullSpeed or 1, function(v)
        Config.FarmPullSpeed = v
    end)
    CreateSeparator(FarmCard, 184)
    CreateToggle(FarmCard, 196, "Ragebot", Config.RagebotEnabled, "RagebotEnabled", true, function(v)
        Config.RagebotEnabled = v
        if UI.Farm then
            UI.Farm.SetRagebotEnabled(v)
        end
    end)
    local ragebotMethodDropdown = BuildDropdown(FarmCard, 232, "Ragebot Method", Config.RagebotMethod or "FarmVoid",
        {"FarmVoid", "FrameTPStomp", "AntiBulletTP"},
        function(v) 
            Config.RagebotMethod = v
            if UI.Farm then
                UI.Farm.SetRagebotMethod(v)
            end
        end)
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.fromOffset(10, 300),
        BackgroundTransparency = 1,
        Text = "Select a target in the Target tab first. Their head will align to your crosshair when Farm is ON. Toggle OFF to restore them.",
        TextColor3 = Theme.HelpText,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, FarmCard)

        -- MISC PAGE
    local MiscPage = Pages.Misc
    PageTitle(MiscPage, "Misc", "AntiStomp, teleport spam, auto armor, and utility features.")
    local MiscScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -72),
        Position = UDim2.fromOffset(10, 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 900),
        ZIndex = 14,
    }, MiscPage)
    local MiscCard = CreateCard(MiscScroll, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 880))

    -- AntiStomp Section
    CreateToggle(MiscCard, 14, "AntiStomp", Config.AntiStomp, "AntiStomp", true, function(v)
        Config.AntiStomp = v
        if UI.Misc then
            UI.Misc.SetAntiStomp(v)
        end
    end)
    local antiStompDropdown = BuildDropdown(MiscCard, 50, "AntiStomp Mode", Config.AntiStompMode or "Void",
        {"Void", "Force Reset"},
        function(v) Config.AntiStompMode = v end)

    CreateSeparator(MiscCard, 122)

    -- Auto Stomp Section
    CreateToggle(MiscCard, 134, "Auto Stomp", Config.AutoStompEnabled, "AutoStompEnabled", true, function(v)
        Config.AutoStompEnabled = v
        if UI.Misc then
            UI.Misc.SetAutoStompEnabled(v)
        end
    end)

    CreateSeparator(MiscCard, 174)

    -- Teleport Spam Section
    CreateToggle(MiscCard, 186, "Teleport Spam", Config.SpamEnabled, "SpamEnabled", true, function(v)
        Config.SpamEnabled = v
        if UI.Misc then
            UI.Misc.ToggleSpam(v)
        end
    end)
    local spamRangeDropdown = BuildDropdown(MiscCard, 226, "Spam Range", Config.SpamRange or "Close",
        {"Close", "Far"},
        function(v) Config.SpamRange = v end)
    CreateSlider(MiscCard, 290, "Close Height", 50, 1000, Config.SpamCloseHeight or 350, function(v)
        Config.SpamCloseHeight = v
    end)
    CreateSlider(MiscCard, 346, "Close Radius", 50, 1000, Config.SpamCloseRadius or 250, function(v)
        Config.SpamCloseRadius = v
    end)
    CreateSlider(MiscCard, 402, "Far Jitter", 0, 50000, Config.SpamFarJitter or 5000, function(v)
        Config.SpamFarJitter = v
    end)
    CreateSlider(MiscCard, 458, "Spam Speed", 1, 10, Config.SpamSpeed or 1, function(v)
        Config.SpamSpeed = v
    end)

    CreateSeparator(MiscCard, 514)

    -- Auto Armor Section
    CreateToggle(MiscCard, 526, "Auto Armor", Config.AutoArmor, "AutoArmor", true, function(v)
        Config.AutoArmor = v
        if UI.Misc then
            UI.Misc.SetAutoArmor(v)
        end
    end)
    CreateToggle(MiscCard, 566, "Armor On Any Damage", Config.AutoArmorOnDamage, "AutoArmorOnDamage", true, function(v)
        Config.AutoArmorOnDamage = v
        if UI.Misc then
            UI.Misc.EvaluateHealthHook()
        end
    end)
    local armorPos = Config.AutoArmorPos or Vector3.new(0, 0, 0)
    local ArmorPosLabel = Instance.new("TextLabel")
    ArmorPosLabel.Size = UDim2.new(0.6, 0, 0, 16)
    ArmorPosLabel.Position = UDim2.new(0.05, 0, 0, 600)
    ArmorPosLabel.BackgroundTransparency = 1
    ArmorPosLabel.Text = string.format("Pos: %.0f, %.0f, %.0f", armorPos.X, armorPos.Y, armorPos.Z)
    ArmorPosLabel.TextColor3 = Theme.ArmorPos
    ArmorPosLabel.Font = Enum.Font.Gotham
    ArmorPosLabel.TextSize = 10
    ArmorPosLabel.TextXAlignment = Enum.TextXAlignment.Left
    ArmorPosLabel.Parent = MiscCard
    local SetPosBtn = Instance.new("TextButton")
    SetPosBtn.Size = UDim2.new(0.3, 0, 0, 20)
    SetPosBtn.Position = UDim2.new(0.65, 0, 0, 598)
    SetPosBtn.BackgroundColor3 = Theme.SetPosBtn
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
                if UI.Misc then
                    UI.Misc.CacheArmorDetector()
                end
            end
        end
    end)
    CreateSlider(MiscCard, 626, "Trigger Health", 1, 100, Config.AutoArmorTriggerHealth or 50, function(v)
        Config.AutoArmorTriggerHealth = v
    end)
    CreateSlider(MiscCard, 682, "Cooldown", 1, 30, Config.AutoArmorCooldown or 5, function(v)
        Config.AutoArmorCooldown = v
    end)

    -- Bottom padding
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.fromOffset(0, 740),
        BackgroundTransparency = 1,
        ZIndex = 16,
    }, MiscCard)
-- SPECTATE PANEL
    local SpectatePanel = New("Frame", {
        Size = UDim2.fromOffset(200, 320),
        Position = UDim2.new(1, -220, 0.5, -160),
        BackgroundColor3 = Theme.BgMain,
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
        TextColor3 = Theme.TextPageTitle,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 61,
    }, SpectatePanel)
    CreateToggle(SpectatePanel, 42, "Spectate Target", Config.Spectate, "SpectatePanel", false, function(v)
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
        TextColor3 = Theme.PickerLabel,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 61,
    }, SpectatePanel)
    local PanelPlayerList = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -108),
        Position = UDim2.fromOffset(10, 102),
        BackgroundColor3 = Theme.BgList,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 61,
    }, SpectatePanel)
    Corner(PanelPlayerList, 8)
    New("UIListLayout", {Padding = UDim.new(0, 2), Parent = PanelPlayerList})

    local function refreshAllLists()
        UI.Targeting.RefreshPlayerList(PlayerList, refreshAllLists)
        UI.Targeting.RefreshPlayerList(PanelPlayerList, refreshAllLists)
    end
    refreshAllLists()
    Players.PlayerAdded:Connect(refreshAllLists)
    Players.PlayerRemoving:Connect(refreshAllLists)

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
    local origSpectateCallback = UI.ToggleCallbacks["Spectate"]
    UI.ToggleCallbacks["Spectate"] = function(enabled)
        origSpectateCallback(enabled)
        if enabled ~= SpectatePanel.Visible then
            SetSpectateMode(enabled)
        end
    end

    -- WORLD PAGE
    local WorldPage = Pages.World
    PageTitle(WorldPage, "World", "Lighting, atmosphere, and visual modifiers.")
    local WorldScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -72),
        Position = UDim2.fromOffset(10, 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 14,
    }, WorldPage)
    local WorldCard = CreateCard(WorldScroll, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 620))
    WorldScroll.CanvasSize = UDim2.new(0, 0, 0, 640)

    CreateToggle(WorldCard, 14, "Full Bright", Config.World_Fullbright, "World_Fullbright", false, function(v)
        Config.World_Fullbright = v
    end)
    CreateToggle(WorldCard, 50, "No Fog", Config.World_NoFog, "World_NoFog", false, function(v)
        Config.World_NoFog = v
    end)
    CreateToggle(WorldCard, 86, "No Shadows", Config.World_NoShadows, "World_NoShadows", false, function(v)
        Config.World_NoShadows = v
    end)
    CreateToggle(WorldCard, 122, "No Atmosphere", Config.World_NoAtmosphere, "World_NoAtmosphere", false, function(v)
        Config.World_NoAtmosphere = v
    end)
    CreateToggle(WorldCard, 158, "No Sun Rays", Config.World_NoSunRays, "World_NoSunRays", false, function(v)
        Config.World_NoSunRays = v
    end)
    CreateToggle(WorldCard, 194, "No Color Correction", Config.World_NoColorCorrection, "World_NoColorCorrection", false, function(v)
        Config.World_NoColorCorrection = v
    end)
    CreateToggle(WorldCard, 230, "Low GFX", Config.World_LowGFX, "World_LowGFX", false, function(v)
        Config.World_LowGFX = v
    end)
    CreateToggle(WorldCard, 266, "Custom Time", Config.World_CustomTime, "World_CustomTime", false, function(v)
        Config.World_CustomTime = v
    end)
    CreateSlider(WorldCard, 302, "Time of Day", 0, 24, Config.World_TimeOfDay, function(v)
        Config.World_TimeOfDay = v
    end)
    CreateSlider(WorldCard, 348, "Brightness", 1, 20, Config.World_Brightness, function(v)
        Config.World_Brightness = v
    end)
    local skyThemeDropdown = BuildDropdown(WorldCard, 394, "Sky Theme", Config.World_SkyTheme or "Default",
        {"Default", "Night", "Light", "Blood", "Gray", "DarkNight", "Space", "Test", "Clouds", "Sunset2", "Galaxy2", "Nebula", "Storm2"},
        function(v) Config.World_SkyTheme = v end)
                -- MOVEMENT PAGE
    local MovementPage = Pages.Movement
    PageTitle(MovementPage, "Movement", "Speed, fly, jump, and collision modifiers.")
    local MovementScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -72),
        Position = UDim2.fromOffset(10, 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 750),
        ZIndex = 14,
    }, MovementPage)
    local MovementCard = CreateCard(MovementScroll, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 740))

    -- Speed Toggle
    CreateToggle(MovementCard, 14, "Speed", Config.Move_SpeedEnabled, "Move_SpeedEnabled", true, function(v)
        Config.Move_SpeedEnabled = v
        if UI.Movement then UI.Movement.SetSpeedEnabled(v) end
    end)

    -- Walk Speed Slider + Input
    New("TextLabel", {
        Size = UDim2.new(1, -140, 0, 20),
        Position = UDim2.fromOffset(10, 50),
        BackgroundTransparency = 1,
        Text = "Walk Speed",
        TextColor3 = Theme.TextLabel,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, MovementCard)
    local walkSpeedTrack = New("Frame", {
        Size = UDim2.new(1, -160, 0, 5),
        Position = UDim2.fromOffset(10, 80),
        BackgroundColor3 = Theme.SliderTrack,
        BorderSizePixel = 0,
        ZIndex = 16,
    }, MovementCard)
    Corner(walkSpeedTrack, 3)
    local walkSpeedFill = New("Frame", {
        Size = UDim2.new(math.clamp((Config.Move_Speed - 16) / 284, 0, 1), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 17,
    }, walkSpeedTrack)
    Corner(walkSpeedFill, 3)
    local walkSpeedInput = New("TextBox", {
        Size = UDim2.fromOffset(60, 24),
        Position = UDim2.new(1, -70, 0, 50),
        BackgroundColor3 = Theme.DropdownItem,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Text = tostring(Config.Move_Speed or 50),
        TextColor3 = Theme.TextPageTitle,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 16,
    }, MovementCard)
    Corner(walkSpeedInput, 6)
    Stroke(walkSpeedInput, 0.6, 1, Theme.StrokeInput)

    local walkSpeedDragging = false
    local function setWalkSpeed(val)
        val = math.max(math.floor(val), 16)
        Config.Move_Speed = val
        walkSpeedFill.Size = UDim2.new(math.clamp((val - 16) / 284, 0, 1), 0, 1, 0)
        walkSpeedInput.Text = tostring(val)
    end
    walkSpeedTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            walkSpeedDragging = true
            local pos = math.clamp((input.Position.X - walkSpeedTrack.AbsolutePosition.X) / walkSpeedTrack.AbsoluteSize.X, 0, 1)
            setWalkSpeed(16 + pos * 284)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if walkSpeedDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - walkSpeedTrack.AbsolutePosition.X) / walkSpeedTrack.AbsoluteSize.X, 0, 1)
            setWalkSpeed(16 + pos * 284)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then walkSpeedDragging = false end
    end)
    walkSpeedInput.FocusLost:Connect(function()
        local num = tonumber(walkSpeedInput.Text)
        if num then setWalkSpeed(num) end
    end)
    walkSpeedInput:GetPropertyChangedSignal("Text"):Connect(function()
        local num = tonumber(walkSpeedInput.Text)
        if num then
            Config.Move_Speed = math.max(math.floor(num), 16)
            walkSpeedFill.Size = UDim2.new(math.clamp((Config.Move_Speed - 16) / 284, 0, 1), 0, 1, 0)
        end
    end)

    -- High Jump Toggle
    CreateToggle(MovementCard, 106, "High Jump", Config.Move_HighJumpEnabled, "Move_HighJumpEnabled", true, function(v)
        Config.Move_HighJumpEnabled = v
        if UI.Movement then UI.Movement.SetHighJumpEnabled(v) end
    end)

    -- Jump Power Slider + Input
    New("TextLabel", {
        Size = UDim2.new(1, -140, 0, 20),
        Position = UDim2.fromOffset(10, 142),
        BackgroundTransparency = 1,
        Text = "Jump Power",
        TextColor3 = Theme.TextLabel,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, MovementCard)
    local jumpPowerTrack = New("Frame", {
        Size = UDim2.new(1, -160, 0, 5),
        Position = UDim2.fromOffset(10, 172),
        BackgroundColor3 = Theme.SliderTrack,
        BorderSizePixel = 0,
        ZIndex = 16,
    }, MovementCard)
    Corner(jumpPowerTrack, 3)
    local jumpPowerFill = New("Frame", {
        Size = UDim2.new(math.clamp((Config.Move_JumpPower - 50) / 250, 0, 1), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 17,
    }, jumpPowerTrack)
    Corner(jumpPowerFill, 3)
    local jumpPowerInput = New("TextBox", {
        Size = UDim2.fromOffset(60, 24),
        Position = UDim2.new(1, -70, 0, 142),
        BackgroundColor3 = Theme.DropdownItem,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Text = tostring(Config.Move_JumpPower or 100),
        TextColor3 = Theme.TextPageTitle,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 16,
    }, MovementCard)
    Corner(jumpPowerInput, 6)
    Stroke(jumpPowerInput, 0.6, 1, Theme.StrokeInput)

    local jumpPowerDragging = false
    local function setJumpPower(val)
        val = math.max(math.floor(val), 50)
        Config.Move_JumpPower = val
        jumpPowerFill.Size = UDim2.new(math.clamp((val - 50) / 250, 0, 1), 0, 1, 0)
        jumpPowerInput.Text = tostring(val)
    end
    jumpPowerTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            jumpPowerDragging = true
            local pos = math.clamp((input.Position.X - jumpPowerTrack.AbsolutePosition.X) / jumpPowerTrack.AbsoluteSize.X, 0, 1)
            setJumpPower(50 + pos * 250)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if jumpPowerDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - jumpPowerTrack.AbsolutePosition.X) / jumpPowerTrack.AbsoluteSize.X, 0, 1)
            setJumpPower(50 + pos * 250)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then jumpPowerDragging = false end
    end)
    jumpPowerInput.FocusLost:Connect(function()
        local num = tonumber(jumpPowerInput.Text)
        if num then setJumpPower(num) end
    end)
    jumpPowerInput:GetPropertyChangedSignal("Text"):Connect(function()
        local num = tonumber(jumpPowerInput.Text)
        if num then
            Config.Move_JumpPower = math.max(math.floor(num), 50)
            jumpPowerFill.Size = UDim2.new(math.clamp((Config.Move_JumpPower - 50) / 250, 0, 1), 0, 1, 0)
        end
    end)

    -- Bunny Hop Toggle
    CreateToggle(MovementCard, 198, "Bunny Hop", Config.Move_BunnyHop, "Move_BunnyHop", true, function(v)
        Config.Move_BunnyHop = v
        if UI.Movement then UI.Movement.SetBunnyHop(v) end
    end)

    -- Bunny Hop Speed Slider + Input
    New("TextLabel", {
        Size = UDim2.new(1, -140, 0, 20),
        Position = UDim2.fromOffset(10, 234),
        BackgroundTransparency = 1,
        Text = "Bunny Hop Speed",
        TextColor3 = Theme.TextLabel,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, MovementCard)
    local bhopSpeedTrack = New("Frame", {
        Size = UDim2.new(1, -160, 0, 5),
        Position = UDim2.fromOffset(10, 264),
        BackgroundColor3 = Theme.SliderTrack,
        BorderSizePixel = 0,
        ZIndex = 16,
    }, MovementCard)
    Corner(bhopSpeedTrack, 3)
    local bhopSpeedFill = New("Frame", {
        Size = UDim2.new(math.clamp(((Config.Move_BunnyHopSpeed or 60) - 16) / 284, 0, 1), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 17,
    }, bhopSpeedTrack)
    Corner(bhopSpeedFill, 3)
    local bhopSpeedInput = New("TextBox", {
        Size = UDim2.fromOffset(60, 24),
        Position = UDim2.new(1, -70, 0, 234),
        BackgroundColor3 = Theme.DropdownItem,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Text = tostring(Config.Move_BunnyHopSpeed or 60),
        TextColor3 = Theme.TextPageTitle,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 16,
    }, MovementCard)
    Corner(bhopSpeedInput, 6)
    Stroke(bhopSpeedInput, 0.6, 1, Theme.StrokeInput)

    local bhopSpeedDragging = false
    local function setBhopSpeed(val)
        val = math.max(math.floor(val), 16)
        Config.Move_BunnyHopSpeed = val
        bhopSpeedFill.Size = UDim2.new(math.clamp((val - 16) / 284, 0, 1), 0, 1, 0)
        bhopSpeedInput.Text = tostring(val)
    end
    bhopSpeedTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            bhopSpeedDragging = true
            local pos = math.clamp((input.Position.X - bhopSpeedTrack.AbsolutePosition.X) / bhopSpeedTrack.AbsoluteSize.X, 0, 1)
            setBhopSpeed(16 + pos * 284)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if bhopSpeedDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - bhopSpeedTrack.AbsolutePosition.X) / bhopSpeedTrack.AbsoluteSize.X, 0, 1)
            setBhopSpeed(16 + pos * 284)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then bhopSpeedDragging = false end
    end)
    bhopSpeedInput.FocusLost:Connect(function()
        local num = tonumber(bhopSpeedInput.Text)
        if num then setBhopSpeed(num) end
    end)
    bhopSpeedInput:GetPropertyChangedSignal("Text"):Connect(function()
        local num = tonumber(bhopSpeedInput.Text)
        if num then
            Config.Move_BunnyHopSpeed = math.max(math.floor(num), 16)
            bhopSpeedFill.Size = UDim2.new(math.clamp((Config.Move_BunnyHopSpeed - 16) / 284, 0, 1), 0, 1, 0)
        end
    end)

    -- No Jump Cooldown Toggle
    CreateToggle(MovementCard, 290, "No Jump Cooldown", Config.Move_NoJumpCooldown, "Move_NoJumpCooldown", true, function(v)
        Config.Move_NoJumpCooldown = v
        if UI.Movement then UI.Movement.SetNoJumpCooldown(v) end
    end)

    -- Infinite Jump Toggle
    CreateToggle(MovementCard, 326, "Infinite Jump", Config.Move_InfiniteJump, "Move_InfiniteJump", true, function(v)
        Config.Move_InfiniteJump = v
        if UI.Movement then UI.Movement.SetInfiniteJump(v) end
    end)

    -- NoClip Toggle
    CreateToggle(MovementCard, 362, "NoClip", Config.Move_NoClip, "Move_NoClip", true, function(v)
        Config.Move_NoClip = v
        if UI.Movement then UI.Movement.SetNoClip(v) end
    end)

    CreateSeparator(MovementCard, 406)

    -- Fly Section
    CreateToggle(MovementCard, 418, "Enable Fly", Config.Move_Fly, "Move_Fly", true, function(v)
        Config.Move_Fly = v
        if UI.Movement then UI.Movement.SetFly(v) end
    end)

    local flyMethodDropdown = BuildDropdown(MovementCard, 454, "Fly Method", Config.Move_FlyMethod or "Tween",
        {"Tween", "Velocity", "CFrame"},
        function(v) Config.Move_FlyMethod = v end)

    -- Fly Speed Slider + Input
    New("TextLabel", {
        Size = UDim2.new(1, -140, 0, 20),
        Position = UDim2.fromOffset(10, 526),
        BackgroundTransparency = 1,
        Text = "Fly Speed",
        TextColor3 = Theme.TextLabel,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, MovementCard)
    local flySpeedTrack = New("Frame", {
        Size = UDim2.new(1, -160, 0, 5),
        Position = UDim2.fromOffset(10, 556),
        BackgroundColor3 = Theme.SliderTrack,
        BorderSizePixel = 0,
        ZIndex = 16,
    }, MovementCard)
    Corner(flySpeedTrack, 3)
    local flySpeedFill = New("Frame", {
        Size = UDim2.new(math.clamp((Config.Move_FlySpeed - 10) / 290, 0, 1), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 17,
    }, flySpeedTrack)
    Corner(flySpeedFill, 3)
    local flySpeedInput = New("TextBox", {
        Size = UDim2.fromOffset(60, 24),
        Position = UDim2.new(1, -70, 0, 526),
        BackgroundColor3 = Theme.DropdownItem,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Text = tostring(Config.Move_FlySpeed or 50),
        TextColor3 = Theme.TextPageTitle,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 16,
    }, MovementCard)
    Corner(flySpeedInput, 6)
    Stroke(flySpeedInput, 0.6, 1, Theme.StrokeInput)

    local flySpeedDragging = false
    local function setFlySpeed(val)
        val = math.max(math.floor(val), 1)
        Config.Move_FlySpeed = val
        flySpeedFill.Size = UDim2.new(math.clamp((val - 10) / 290, 0, 1), 0, 1, 0)
        flySpeedInput.Text = tostring(val)
    end
    flySpeedTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            flySpeedDragging = true
            local pos = math.clamp((input.Position.X - flySpeedTrack.AbsolutePosition.X) / flySpeedTrack.AbsoluteSize.X, 0, 1)
            setFlySpeed(10 + pos * 290)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if flySpeedDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - flySpeedTrack.AbsolutePosition.X) / flySpeedTrack.AbsoluteSize.X, 0, 1)
            setFlySpeed(10 + pos * 290)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then flySpeedDragging = false end
    end)
    flySpeedInput.FocusLost:Connect(function()
        local num = tonumber(flySpeedInput.Text)
        if num then setFlySpeed(num) end
    end)
    flySpeedInput:GetPropertyChangedSignal("Text"):Connect(function()
        local num = tonumber(flySpeedInput.Text)
        if num then
            Config.Move_FlySpeed = math.max(math.floor(num), 1)
            flySpeedFill.Size = UDim2.new(math.clamp((Config.Move_FlySpeed - 10) / 290, 0, 1), 0, 1, 0)
        end
    end)

    -- WASD Help Text
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.fromOffset(10, 576),
        BackgroundTransparency = 1,
        Text = "WASD to move, Space up, Shift down",
        TextColor3 = Theme.HelpText,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, MovementCard)

    -- Bottom padding
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.fromOffset(0, 610),
        BackgroundTransparency = 1,
        ZIndex = 16,
    }, MovementCard)
    -- SETTINGS PAGE
    local SettingsPage = Pages.Settings
    PageTitle(SettingsPage, "Settings", "Interface customization, config management, and safety options.")
    local SettingsScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -72),
        Position = UDim2.fromOffset(10, 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 910),
        ZIndex = 14,
    }, SettingsPage)
    local SettingsCard = CreateCard(SettingsScroll, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 900))

    -- Keybinds Section
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        Text = "Keybinds",
        TextColor3 = Theme.TextSection,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)

    -- Menu Toggle Key
    New("TextLabel", {
        Size = UDim2.new(1, -140, 0, 25),
        Position = UDim2.fromOffset(15, 36),
        BackgroundTransparency = 1,
        Text = "Menu Toggle Key",
        TextColor3 = Theme.TextTabActive,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)

    local KeybindButton = New("TextButton", {
        Size = UDim2.fromOffset(115, 30),
        Position = UDim2.new(1, -130, 0, 34),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        Text = FormatKeyName(Config.ToggleKey),
        TextColor3 = Theme.ActionBtnText,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 17,
    }, SettingsCard)
    Corner(KeybindButton, 8)

    -- Panic Key
    New("TextLabel", {
        Size = UDim2.new(1, -140, 0, 25),
        Position = UDim2.fromOffset(15, 70),
        BackgroundTransparency = 1,
        Text = "Panic Key (disable all)",
        TextColor3 = Theme.TextTabActive,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)

    local PanicKeyButton = New("TextButton", {
        Size = UDim2.fromOffset(115, 30),
        Position = UDim2.new(1, -130, 0, 68),
        BackgroundColor3 = Theme.PanicBtn,
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        Text = Config.PanicKey and FormatKeyName(Config.PanicKey) or "—",
        TextColor3 = Theme.ActionBtnText,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 17,
    }, SettingsCard)
    Corner(PanicKeyButton, 8)

    PanicKeyButton.MouseButton1Click:Connect(function()
        if UI.ListeningKey then return end
        UI.ListeningKey = "PanicKey"
        PanicKeyButton.Text = "PRESS KEY"
        Tween(PanicKeyButton, {BackgroundTransparency = 0}, 0.2):Play()
    end)

    CreateSeparator(SettingsCard, 108)

    -- GUI Customization Section
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 120),
        BackgroundTransparency = 1,
        Text = "GUI Customization",
        TextColor3 = Theme.TextSection,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)

    -- GUI Scale Slider + Input
    New("TextLabel", {
        Size = UDim2.new(1, -140, 0, 20),
        Position = UDim2.fromOffset(10, 144),
        BackgroundTransparency = 1,
        Text = "GUI Scale",
        TextColor3 = Theme.TextLabel,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)

    local guiScaleTrack = New("Frame", {
        Size = UDim2.new(1, -160, 0, 5),
        Position = UDim2.fromOffset(10, 174),
        BackgroundColor3 = Theme.SliderTrack,
        BorderSizePixel = 0,
        ZIndex = 16,
    }, SettingsCard)
    Corner(guiScaleTrack, 3)

    local guiScaleFill = New("Frame", {
        Size = UDim2.new((Config.GUIScale - 0.5) / 1.5, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 17,
    }, guiScaleTrack)
    Corner(guiScaleFill, 3)

    local guiScaleInput = New("TextBox", {
        Size = UDim2.fromOffset(60, 24),
        Position = UDim2.new(1, -70, 0, 144),
        BackgroundColor3 = Theme.DropdownItem,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Text = string.format("%.1f", Config.GUIScale or 1.0),
        TextColor3 = Theme.TextPageTitle,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 16,
    }, SettingsCard)
    Corner(guiScaleInput, 6)
    Stroke(guiScaleInput, 0.6, 1, Theme.StrokeInput)

    local guiScaleDragging = false
    local function setGUIScale(val)
        val = math.clamp(val, 0.5, 2.0)
        Config.GUIScale = val
        guiScaleFill.Size = UDim2.new((val - 0.5) / 1.5, 0, 1, 0)
        guiScaleInput.Text = string.format("%.1f", val)
        if UI.Main then
            UI.Main.Size = UDim2.fromOffset(760 * val, 540 * val)
        end
    end

    guiScaleTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            guiScaleDragging = true
            local pos = math.clamp((input.Position.X - guiScaleTrack.AbsolutePosition.X) / guiScaleTrack.AbsoluteSize.X, 0, 1)
            setGUIScale(0.5 + pos * 1.5)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if guiScaleDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - guiScaleTrack.AbsolutePosition.X) / guiScaleTrack.AbsoluteSize.X, 0, 1)
            setGUIScale(0.5 + pos * 1.5)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then guiScaleDragging = false end
    end)
    guiScaleInput.FocusLost:Connect(function()
        local num = tonumber(guiScaleInput.Text)
        if num then setGUIScale(num) end
    end)

    -- Show Hotkeys Toggle
    CreateToggle(SettingsCard, 188, "Show Hotkeys", Config.ShowHotkeys, "ShowHotkeys", false, function(v)
        Config.ShowHotkeys = v
        UI.UpdateHotkeyDisplay()
    end)

    -- Auto-hide on Screenshot Toggle
    CreateToggle(SettingsCard, 224, "Auto-hide on Screenshot", Config.AutoHideOnScreenshot, "AutoHideOnScreenshot", false, function(v)
        Config.AutoHideOnScreenshot = v
    end)

    -- GUI Window Mode Toggle
    CreateToggle(SettingsCard, 260, "GUI Window Mode", Config.GUIWindow, "GUIWindow", false, function(v)
        Config.GUIWindow = v
        if UI.Main then
            if v then
                UI.Main.Size = UDim2.fromOffset(500 * (Config.GUIScale or 1), 400 * (Config.GUIScale or 1))
                UI.Main.Position = UDim2.new(0.5, -250 * (Config.GUIScale or 1), 0.5, -200 * (Config.GUIScale or 1))
                UI.Main.AnchorPoint = Vector2.new(0, 0)
            else
                UI.Main.Size = UDim2.fromOffset(760 * (Config.GUIScale or 1), 540 * (Config.GUIScale or 1))
                UI.Main.Position = UDim2.fromScale(0.5, 0.5)
                UI.Main.AnchorPoint = Vector2.new(0.5, 0.5)
            end
        end
        if UI.Background then
            UI.Background.Visible = not v and UI.GUIVisible
        end
    end)

    CreateSeparator(SettingsCard, 298)

    -- Performance Section
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 310),
        BackgroundTransparency = 1,
        Text = "Performance",
        TextColor3 = Theme.TextSection,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)

    -- FPS Cap Slider + Input
    New("TextLabel", {
        Size = UDim2.new(1, -140, 0, 20),
        Position = UDim2.fromOffset(10, 334),
        BackgroundTransparency = 1,
        Text = "FPS Cap (0 = uncapped)",
        TextColor3 = Theme.TextLabel,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)

    local fpsTrack = New("Frame", {
        Size = UDim2.new(1, -160, 0, 5),
        Position = UDim2.fromOffset(10, 364),
        BackgroundColor3 = Theme.SliderTrack,
        BorderSizePixel = 0,
        ZIndex = 16,
    }, SettingsCard)
    Corner(fpsTrack, 3)

    local fpsFill = New("Frame", {
        Size = UDim2.new(math.clamp((Config.FPSCap or 0) / 480, 0, 1), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 17,
    }, fpsTrack)
    Corner(fpsFill, 3)

    local fpsInput = New("TextBox", {
        Size = UDim2.fromOffset(60, 24),
        Position = UDim2.new(1, -70, 0, 334),
        BackgroundColor3 = Theme.DropdownItem,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Text = tostring(Config.FPSCap or 0),
        TextColor3 = Theme.TextPageTitle,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 16,
    }, SettingsCard)
    Corner(fpsInput, 6)
    Stroke(fpsInput, 0.6, 1, Theme.StrokeInput)

    local fpsDragging = false
    local function setFPSCap(val)
        val = math.clamp(math.floor(val), 0, 480)
        Config.FPSCap = val
        fpsFill.Size = UDim2.new(val / 480, 0, 1, 0)
        fpsInput.Text = tostring(val)
        if setfpscap then
            setfpscap(val > 0 and val or 480)
        end
    end

    fpsTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            fpsDragging = true
            local pos = math.clamp((input.Position.X - fpsTrack.AbsolutePosition.X) / fpsTrack.AbsoluteSize.X, 0, 1)
            setFPSCap(pos * 480)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if fpsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - fpsTrack.AbsolutePosition.X) / fpsTrack.AbsoluteSize.X, 0, 1)
            setFPSCap(pos * 480)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then fpsDragging = false end
    end)
    fpsInput.FocusLost:Connect(function()
        local num = tonumber(fpsInput.Text)
        if num then setFPSCap(num) end
    end)

    CreateSeparator(SettingsCard, 378)

    -- Notifications Section
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 390),
        BackgroundTransparency = 1,
        Text = "Notifications",
        TextColor3 = Theme.TextSection,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)

    -- Show Notifications Toggle
    CreateToggle(SettingsCard, 414, "Show Notifications", Config.ShowNotifications, "ShowNotifications", false, function(v)
        Config.ShowNotifications = v
    end)

    -- Notification Duration Slider + Input
    New("TextLabel", {
        Size = UDim2.new(1, -140, 0, 20),
        Position = UDim2.fromOffset(10, 450),
        BackgroundTransparency = 1,
        Text = "Notification Duration",
        TextColor3 = Theme.TextLabel,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)

    local notifTrack = New("Frame", {
        Size = UDim2.new(1, -160, 0, 5),
        Position = UDim2.fromOffset(10, 480),
        BackgroundColor3 = Theme.SliderTrack,
        BorderSizePixel = 0,
        ZIndex = 16,
    }, SettingsCard)
    Corner(notifTrack, 3)

    local notifFill = New("Frame", {
        Size = UDim2.new(math.clamp((Config.NotificationDuration or 2.5) / 10, 0, 1), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 17,
    }, notifTrack)
    Corner(notifFill, 3)

    local notifInput = New("TextBox", {
        Size = UDim2.fromOffset(60, 24),
        Position = UDim2.new(1, -70, 0, 450),
        BackgroundColor3 = Theme.DropdownItem,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Text = string.format("%.1f", Config.NotificationDuration or 2.5),
        TextColor3 = Theme.TextPageTitle,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 16,
    }, SettingsCard)
    Corner(notifInput, 6)
    Stroke(notifInput, 0.6, 1, Theme.StrokeInput)

    local notifDragging = false
    local function setNotifDuration(val)
        val = math.clamp(val, 0.5, 10)
        Config.NotificationDuration = val
        notifFill.Size = UDim2.new(val / 10, 0, 1, 0)
        notifInput.Text = string.format("%.1f", val)
    end

    notifTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            notifDragging = true
            local pos = math.clamp((input.Position.X - notifTrack.AbsolutePosition.X) / notifTrack.AbsoluteSize.X, 0, 1)
            setNotifDuration(0.5 + pos * 9.5)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if notifDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - notifTrack.AbsolutePosition.X) / notifTrack.AbsoluteSize.X, 0, 1)
            setNotifDuration(0.5 + pos * 9.5)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then notifDragging = false end
    end)
    notifInput.FocusLost:Connect(function()
        local num = tonumber(notifInput.Text)
        if num then setNotifDuration(num) end
    end)

    CreateSeparator(SettingsCard, 494)

    -- Config Management Section
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 506),
        BackgroundTransparency = 1,
        Text = "Config Management",
        TextColor3 = Theme.TextSection,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)

    -- Save Config Button
    CreateActionButton(SettingsCard, 530, "Save Config", function()
        if writefile then
            local configData = {}
            for k, v in pairs(Config) do
                if typeof(v) == "EnumItem" then
                    configData[k] = {type = "Enum", value = v.Name}
                elseif typeof(v) == "Color3" then
                    configData[k] = {type = "Color3", r = v.R, g = v.G, b = v.B}
                elseif typeof(v) == "Vector3" then
                    configData[k] = {type = "Vector3", x = v.X, y = v.Y, z = v.Z}
                else
                    configData[k] = {type = typeof(v), value = v}
                end
            end
            local success, err = pcall(function()
                writefile("starscc_config.json", game:GetService("HttpService"):JSONEncode(configData))
            end)
            if success then
                print("[Stars.cc] Config saved!")
            else
                print("[Stars.cc] Failed to save: " .. tostring(err))
            end
        else
            print("[Stars.cc] writefile not supported")
        end
    end)

    -- Load Config Button
    CreateActionButton(SettingsCard, 566, "Load Config", function()
        if readfile then
            local success, err = pcall(function()
                local data = readfile("starscc_config.json")
                local configData = game:GetService("HttpService"):JSONDecode(data)
                for k, v in pairs(configData) do
                    if v.type == "Enum" then
                        Config[k] = Enum.KeyCode[v.value]
                    elseif v.type == "Color3" then
                        Config[k] = Color3.new(v.r, v.g, v.b)
                    elseif v.type == "Vector3" then
                        Config[k] = Vector3.new(v.x, v.y, v.z)
                    else
                        Config[k] = v.value
                    end
                end
            end)
            if success then
                print("[Stars.cc] Config loaded! Restart script to apply.")
            else
                print("[Stars.cc] Failed to load: " .. tostring(err))
            end
        else
            print("[Stars.cc] readfile not supported")
        end
    end)

    -- Reset to Defaults Button
    CreateActionButton(SettingsCard, 602, "Reset to Defaults", function()
        for k, v in pairs(Config) do
            if typeof(v) == "boolean" then
                Config[k] = false
            elseif typeof(v) == "number" then
                if k == "Aimbot_FOV" then Config[k] = 60
                elseif k == "Aimbot_Smoothness" then Config[k] = 15
                elseif k == "FOV_Radius" then Config[k] = 250
                elseif k == "ESP_MaxDistance" then Config[k] = 2000
                elseif k == "Move_Speed" then Config[k] = 50
                elseif k == "Move_JumpPower" then Config[k] = 100
                elseif k == "Move_FlySpeed" then Config[k] = 50
                elseif k == "Move_BunnyHopSpeed" then Config[k] = 60
                elseif k == "FarmDistance" then Config[k] = 12
                elseif k == "GUIScale" then Config[k] = 1.0
                elseif k == "FPSCap" then Config[k] = 0
                elseif k == "NotificationDuration" then Config[k] = 2.5
                else Config[k] = 0 end
            elseif typeof(v) == "string" then
                if k == "Aimbot_TargetPart" then Config[k] = "Head"
                elseif k == "Aimbot_Priority" then Config[k] = "Closest to Mouse"
                elseif k == "TargetPart" then Config[k] = "Head"
                elseif k == "AntiStompMode" then Config[k] = "Void"
                elseif k == "SpamRange" then Config[k] = "Close"
                elseif k == "Move_FlyMethod" then Config[k] = "Tween"
                elseif k == "World_SkyTheme" then Config[k] = "Default"
                elseif k == "RagebotMethod" then Config[k] = "FarmVoid"
                else Config[k] = "" end
            end
        end
        Config.ToggleKey = Enum.KeyCode.RightShift
        Config.PanicKey = nil
        print("[Stars.cc] Config reset to defaults! Restart script to apply.")
    end)


    -- Theme Selector
    CreateSeparator(SettingsCard, 640)
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 652),
        BackgroundTransparency = 1,
        Text = "Theme",
        TextColor3 = Theme.TextSection,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)
    local themeDropdown = BuildDropdown(SettingsCard, 676, "GUI Theme", Config.GUIThemeName or "Purple",
        {"Purple", "Monochrome"},
        function(v)
            Config.GUIThemeName = v
            UI.ApplyTheme(v)
        end)


    -- Background Image Selector
    CreateSeparator(SettingsCard, 736)
    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 748),
        BackgroundTransparency = 1,
        Text = "Background Image",
        TextColor3 = Theme.TextSection,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
    }, SettingsCard)
    local bgImageDropdown = BuildDropdown(SettingsCard, 772, "Texture", Config.GUIBackgroundImage or "None",
        BackgroundTextureNames,
        function(v)
            Config.GUIBackgroundImage = v
            ApplyBackgroundImage()
        end)

    -- Bottom padding
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.fromOffset(0, 832),
        BackgroundTransparency = 1,
        ZIndex = 16,
    }, SettingsCard)
-- Hotkey Display
    local HotkeyDisplay = New("Frame", {
        Name = "HotkeyDisplay",
        Size = UDim2.fromOffset(155, 36),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -20, 0, 20),
        BackgroundColor3 = Theme.BgHotkey,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
    }, ScreenGui)
    Corner(HotkeyDisplay, 10)
    Stroke(HotkeyDisplay, 0.88, 1)
    UI.HotkeyDisplay = HotkeyDisplay

    -- Tab System
    local ActiveTab = nil
    local function SelectTab(name)
        ActiveTab = name
        for tabName, data in pairs(TabButtons) do
            local active = tabName == name
            Tween(data.Button, {
                BackgroundTransparency = active and 0.84 or 1,
                TextColor3 = active and Theme.TextTabActive or Theme.TextTabInactive,
            }, 0.2):Play()
            Tween(data.Indicator, {BackgroundTransparency = active and 0 or 1}, 0.2):Play()
        end
        for pageName, page in pairs(Pages) do
            page.Visible = pageName == name
        end
        if targetPartDropdown and targetPartDropdown.IsOpen() then targetPartDropdown.Close() end
        if aimbotPartDropdown and aimbotPartDropdown.IsOpen() then aimbotPartDropdown.Close() end
        if aimbotPriorityDropdown and aimbotPriorityDropdown.IsOpen() then aimbotPriorityDropdown.Close() end
        if flyMethodDropdown and flyMethodDropdown.IsOpen() then flyMethodDropdown.Close() end
        if skyThemeDropdown and skyThemeDropdown.IsOpen() then skyThemeDropdown.Close() end
        if antiStompDropdown and antiStompDropdown.IsOpen() then antiStompDropdown.Close() end
        if spamRangeDropdown and spamRangeDropdown.IsOpen() then spamRangeDropdown.Close() end
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

    -- Keybind Changing
    UI.ListeningKey = nil
    KeybindButton.MouseButton1Click:Connect(function()
        if UI.ListeningKey then return end
        UI.ListeningKey = "Toggle"
        KeybindButton.Text = "PRESS KEY"
        Tween(KeybindButton, {BackgroundTransparency = 0}, 0.2):Play()
    end)

    -- Ensure RightShift is default
    if not Config.ToggleKey then
        Config.ToggleKey = Enum.KeyCode.RightShift
    end
    KeybindButton.Text = FormatKeyName(Config.ToggleKey)

    -- GUI Toggle
    local function SetGUIVisible(visible)
        UI.GUIVisible = visible
        if visible then
            Main.Visible = true
            Background.Visible = true
            Body.Visible = true
            Sidebar.Visible = true
            Content.Visible = true
            -- Restore active tab
            if ActiveTab then
                SelectTab(ActiveTab)
            end
            Tween(Main, {
                Size = UDim2.fromOffset(GUI_WIDTH, GUI_HEIGHT),
                BackgroundTransparency = 0.04,
            }, 0.4):Play()
            Tween(Blur, {Size = 12}, 0.35):Play()
        else
            -- Closing animation — shrink and fade
            Tween(Main, {
                Size = UDim2.fromOffset(GUI_WIDTH * (Config.GUIScale or 1), 0),
                BackgroundTransparency = 1,
            }, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()
            Tween(Blur, {Size = 0}, 0.25):Play()

            -- Hide after animation completes
            task.delay(0.25, function()
                if not UI.GUIVisible then
                    Main.Visible = false
                    Background.Visible = false
                    Body.Visible = false
                    Sidebar.Visible = false
                    Content.Visible = false
                    for _, page in pairs(Pages) do
                        page.Visible = false
                    end
                end
            end)
        end
        UI.UpdateHotkeyDisplay()
    end
    UI.SetGUIVisible = SetGUIVisible

    -- Input Handler
    local mainInputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if UI.ListeningKey then
            local captured = nil
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Backspace then
                    captured = "clear"
                else
                    captured = input.KeyCode
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.MouseButton2
                or input.UserInputType == Enum.UserInputType.MouseButton3 then
                captured = input.UserInputType
            end

            if captured then
                if captured == "clear" then
                    if UI.ListeningKey == "Toggle" then
                    elseif UI.ListeningKey == "PanicKey" then
                        Config.PanicKey = nil
                        PanicKeyButton.Text = "—"
                    else
                        Config[UI.ListeningKey .. "Key"] = nil
                        local btn = UI.KeybindButtons[UI.ListeningKey]
                        if btn then btn.Text = "—" end
                    end
                else
                    if UI.ListeningKey == "Toggle" then
                        Config.ToggleKey = captured
                        KeybindButton.Text = FormatKeyName(captured)
                    elseif UI.ListeningKey == "PanicKey" then
                        Config.PanicKey = captured
                        PanicKeyButton.Text = FormatKeyName(captured)
                    elseif UI.ToggleCallbacks[UI.ListeningKey] or UI.KeybindButtons[UI.ListeningKey] then
                        Config[UI.ListeningKey .. "Key"] = captured
                        local btn = UI.KeybindButtons[UI.ListeningKey]
                        if btn then btn.Text = FormatKeyName(captured) end
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
        if IsSameKey(input, Config.ToggleKey) then
            SetGUIVisible(not UI.GUIVisible)
            return
        end

        -- Panic Key — disable everything
        if Config.PanicKey and IsSameKey(input, Config.PanicKey) then
            -- Disable all toggles
            for toggleId, callback in pairs(UI.ToggleCallbacks) do
                if Config[toggleId] then
                    callback(false)
                end
            end
            -- Hide GUI
            SetGUIVisible(false)
            print("[Stars.cc] PANIC — All features disabled!")
            return
        end

        -- Screenshot detection (PrintScreen key)
        if Config.AutoHideOnScreenshot and input.KeyCode == Enum.KeyCode.PrintScreen then
            SetGUIVisible(false)
            task.delay(0.1, function()
                SetGUIVisible(true)
            end)
            return
        end
        for toggleId, callback in pairs(UI.ToggleCallbacks) do
            local key = Config[toggleId .. "Key"]
            if key and IsSameKey(input, key) then
                callback(not Config[toggleId])
                return
            end
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            if CPState.IsOpen and ColorPickerFrame.Visible then
                local framePos = ColorPickerFrame.AbsolutePosition
                local frameSize = ColorPickerFrame.AbsoluteSize
                if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
                   mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                    ColorPickerFrame.Visible = false
                    CPState.IsOpen = false
                    CPEndDrag()
                    ActiveColorPicker = nil
                end
            end
        end
    end)
    table.insert(UI.Connections, mainInputConn)

    CloseBtn.MouseButton1Click:Connect(function()
        SetGUIVisible(not UI.GUIVisible)
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

    ApplyBackgroundImage()
    Main.Size = UDim2.fromOffset(GUI_WIDTH, 0)
    SetGUIVisible(true)
    return ScreenGui
end


function UI.ApplyTheme(themeName)
    local Config = UI.Config
    if not Config then return end
    Config.GUIThemeName = themeName
    Theme = Themes.Get(themeName)

    -- Disconnect all stored input connections to prevent duplicates
    for _, conn in pairs(UI.Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    UI.Connections = {}

    -- Rebuild the entire UI with new theme
    if UI.ScreenGui then
        UI.ScreenGui:Destroy()
    end
    local oldBlur = Lighting:FindFirstChild("ZeeHoodBlur")
    if oldBlur then oldBlur:Destroy() end
    UI.Build()
end

return UI