local BASE_URL = "https://raw.githubusercontent.com/confessess/zee-hvh/main/"

local function loadModule(path)
    local url = BASE_URL .. path
    local src = game:HttpGet(url, true)
    if not src or src == "" then
        error("Failed to fetch: " .. url)
    end
    return loadstring(src)()
end

-- ═════════════════════════════════════════════════════════════════════════════
-- INLINED AUTH MODULE
-- ═════════════════════════════════════════════════════════════════════════════
local Auth = {
    Validated = false,
    Key = nil,
    HWID = nil,
    AuthURL = "http://localhost:3000/api/validate",
    FallbackKeys = {},
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Auth.GenerateHWID()
    local hwid = nil
    if syn and syn.get_hwid then hwid = syn.get_hwid()
    elseif krnl and krnl.get_hwid then hwid = krnl.get_hwid()
    elseif gethwid then hwid = gethwid()
    elseif fluxus and fluxus.get_hwid then hwid = fluxus.get_hwid()
    elseif codex and codex.get_hwid then hwid = codex.get_hwid()
    elseif delta and delta.get_hwid then hwid = delta.get_hwid()
    elseif electron and electron.get_hwid then hwid = electron.get_hwid()
    elseif oxy and oxy.get_hwid then hwid = oxy.get_hwid()
    elseif trigon and trigon.get_hwid then hwid = trigon.get_hwid()
    elseif vega and vega.get_hwid then hwid = vega.get_hwid()
    elseif hydrogen and hydrogen.get_hwid then hwid = hydrogen.get_hwid()
    elseif arceus and arceus.get_hwid then hwid = arceus.get_hwid()
    elseif celery and celery.get_hwid then hwid = celery.get_hwid()
    elseif macsploit and macsploit.get_hwid then hwid = macsploit.get_hwid()
    elseif solara and solara.get_hwid then hwid = solara.get_hwid()
    elseif xeno and xeno.get_hwid then hwid = xeno.get_hwid()
    elseif identifyexecutor then
        local name = identifyexecutor()
        if name then
            hwid = "POTASSIUM-" .. tostring(LocalPlayer.UserId) .. "-" .. name:gsub("%s+", "-")
        end
    end
    if not hwid or #hwid < 8 then
        local fingerprint = tostring(LocalPlayer.UserId)
        pcall(function()
            local version = game:HttpGet("https://setup.rbxcdn.com/version", true)
            if version then fingerprint = fingerprint .. version:sub(1, 20) end
        end)
        -- Use bit32 for Luau compatibility (Lua 5.1 / Roblox)
        local hash = 0
        for i = 1, #fingerprint do
            hash = bit32.bor(bit32.lshift(hash, 5), bit32.band(bit32.arshift(hash, 27), 0x1F))
            hash = bit32.band(hash + string.byte(fingerprint, i), 0xFFFFFFFF)
        end
        hwid = string.format("FALLBACK-%08X-%08X", hash, LocalPlayer.UserId)
    end
    Auth.HWID = hwid
    return hwid
end

function Auth.ValidateKey(inputKey)
    local hwid = Auth.GenerateHWID()
    
    if Auth.FallbackKeys[inputKey] then
        Auth.Validated = true
        Auth.Key = inputKey
        return true, "fallback"
    end
    
    local payload = HttpService:JSONEncode({ key = inputKey, hwid = hwid })
    local url = Auth.AuthURL
    local response = nil
    local usedMethod = "none"
    
    -- Try every known executor request method
    local methods = {
        function()
            usedMethod = "game:HttpPost"
            return game:HttpPost(url, payload, false, "application/json")
        end,
        function()
            usedMethod = "request()"
            local res = request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
            return res and res.Body
        end,
        function()
            usedMethod = "syn.request"
            local res = syn.request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
            return res and res.Body
        end,
        function()
            usedMethod = "fluxus.request"
            local res = fluxus.request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
            return res and res.Body
        end,
        function()
            usedMethod = "krnl.request"
            local res = krnl.request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
            return res and res.Body
        end,
        function()
            usedMethod = "http.request"
            local res = http.request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
            return res and res.Body
        end,
        function()
            usedMethod = "game:HttpGet with query (GET fallback)"
            local getUrl = url .. "?key=" .. HttpService:UrlEncode(inputKey) .. "&hwid=" .. HttpService:UrlEncode(hwid)
            return game:HttpGet(getUrl, true)
        end,
    }
    
    for i, method in ipairs(methods) do
        local success, result = pcall(method)
        if success and result and #result > 0 then
            response = result
            print("[ZeeAuth] Success via " .. usedMethod)
            break
        else
            print("[ZeeAuth] Method " .. i .. " (" .. usedMethod .. ") failed: " .. tostring(result))
        end
    end
    
    if not response then
        return false, "connection_failed"
    end
    
    local parseOk, parsed = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if not parseOk then
        print("[ZeeAuth] JSON parse failed: " .. tostring(parsed))
        print("[ZeeAuth] Raw response: " .. response:sub(1, 200))
        return false, "bad_response"
    end
    
    if parsed and parsed.valid then
        Auth.Validated = true
        Auth.Key = inputKey
        return true, parsed.hwid_status or "remote"
    else
        return false, parsed.reason or "unknown"
    end
end

function Auth.IsValidated() return Auth.Validated end
function Auth.GetKey() return Auth.Key end
function Auth.GetHWID()
    if not Auth.HWID then Auth.GenerateHWID() end
    return Auth.HWID
end

-- ═════════════════════════════════════════════════════════════════════════════
-- INLINED KEYGATE MODULE
-- ═════════════════════════════════════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local KeyGate = { ScreenGui = nil, OnSuccess = nil }
local PURPLE = Color3.fromRGB(145, 75, 255)

local function New(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do object[property] = value end
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

function KeyGate.Build(authModule, onSuccessCallback)
    KeyGate.OnSuccess = onSuccessCallback
    local oldGui = PlayerGui:FindFirstChild("ZeeHoodKeyGate")
    if oldGui then oldGui:Destroy() end
    local ScreenGui = New("ScreenGui", {
        Name = "ZeeHoodKeyGate",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, PlayerGui)
    KeyGate.ScreenGui = ScreenGui
    local Background = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(4, 3, 9),
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        ZIndex = 1,
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
    local Main = New("Frame", {
        Size = UDim2.fromOffset(440, 340),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(9, 6, 15),
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ZIndex = 10,
    }, ScreenGui)
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
    New("TextLabel", {
        Size = UDim2.fromOffset(400, 32),
        Position = UDim2.fromOffset(20, 18),
        BackgroundTransparency = 1,
        Text = "Stars.cc",
        TextColor3 = Color3.fromRGB(245, 238, 250),
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    }, Main)
    New("TextLabel", {
        Size = UDim2.fromOffset(400, 20),
        Position = UDim2.fromOffset(21, 50),
        BackgroundTransparency = 1,
        Text = "HWID-Locked Authentication",
        TextColor3 = Color3.fromRGB(145, 125, 165),
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    }, Main)
    local hwid = authModule.GetHWID and authModule.GetHWID() or "unknown"
    local shortHWID = #hwid > 24 and hwid:sub(1, 12) .. "..." .. hwid:sub(-8) or hwid
    New("TextLabel", {
        Size = UDim2.new(1, -40, 0, 16),
        Position = UDim2.fromOffset(20, 74),
        BackgroundTransparency = 1,
        Text = "HWID: " .. shortHWID,
        TextColor3 = Color3.fromRGB(100, 90, 115),
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    }, Main)
    local InputFrame = New("Frame", {
        Size = UDim2.new(1, -40, 0, 44),
        Position = UDim2.fromOffset(20, 100),
        BackgroundColor3 = Color3.fromRGB(18, 11, 27),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 12,
    }, Main)
    Corner(InputFrame, 12)
    Stroke(InputFrame, 0.85, 1, Color3.fromRGB(140, 90, 200))
    local InputBox = New("TextBox", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Enter your access key...",
        TextColor3 = Color3.fromRGB(220, 215, 235),
        PlaceholderColor3 = Color3.fromRGB(100, 90, 115),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 13,
    }, InputFrame)
    local StatusLabel = New("TextLabel", {
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.fromOffset(20, 152),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 80, 80),
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    }, Main)
    local SubmitBtn = New("TextButton", {
        Size = UDim2.new(1, -40, 0, 40),
        Position = UDim2.fromOffset(20, 185),
        BackgroundColor3 = PURPLE,
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        Text = "Authenticate",
        TextColor3 = Color3.fromRGB(255, 250, 255),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 12,
    }, Main)
    Corner(SubmitBtn, 10)
    local InfoFrame = New("Frame", {
        Size = UDim2.new(1, -40, 0, 60),
        Position = UDim2.fromOffset(20, 238),
        BackgroundColor3 = Color3.fromRGB(14, 9, 22),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 12,
    }, Main)
    Corner(InfoFrame, 10)
    Stroke(InfoFrame, 0.9, 1, Color3.fromRGB(100, 70, 150))
    New("TextLabel", {
        Size = UDim2.new(1, -16, 1, -8),
        Position = UDim2.fromOffset(8, 4),
        BackgroundTransparency = 1,
        Text = "Your HWID is locked to this key. Each key supports a limited number of devices. Contact support to reset your device slots.",
        TextColor3 = Color3.fromRGB(130, 120, 145),
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
    }, InfoFrame)
    SubmitBtn.MouseEnter:Connect(function()
        Tween(SubmitBtn, {BackgroundTransparency = 0.05}, 0.15):Play()
    end)
    SubmitBtn.MouseLeave:Connect(function()
        Tween(SubmitBtn, {BackgroundTransparency = 0.18}, 0.15):Play()
    end)
    local function Shake()
        local originalPos = Main.Position
        for i = 1, 8 do
            local offset = math.sin(i * 1.5) * 6
            Main.Position = originalPos + UDim2.fromOffset(offset, 0)
            task.wait(0.03)
        end
        Main.Position = originalPos
    end
    local function TryAuth()
        local key = InputBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if #key == 0 then
            StatusLabel.Text = "Please enter a key."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 140, 60)
            Shake()
            return
        end
        StatusLabel.Text = "Validating..."
        StatusLabel.TextColor3 = Color3.fromRGB(180, 170, 200)
        task.spawn(function()
            local valid, source = authModule.ValidateKey(key)
            if valid then
                StatusLabel.Text = "Authenticated!"
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 140)
                Tween(Main, {BackgroundTransparency = 1}, 0.4):Play()
                Tween(Background, {BackgroundTransparency = 1}, 0.5):Play()
                task.wait(0.5)
                ScreenGui:Destroy()
                if KeyGate.OnSuccess then
                    KeyGate.OnSuccess(key, source)
                end
            else
                local reasonMap = {
                    invalid = "Invalid key.",
                    key_not_found = "Key not found.",
                    key_revoked = "Key has been revoked.",
                    key_expired = "Key has expired.",
                    no_uses_left = "No uses remaining.",
                    hwid_limit_reached = "Device limit reached for this key.",
                    connection_failed = "Failed to reach auth server.",
                }
                StatusLabel.Text = reasonMap[source] or ("Error: " .. tostring(source))
                StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                Shake()
            end
        end)
    end
    SubmitBtn.MouseButton1Click:Connect(TryAuth)
    InputBox.FocusLost:Connect(function(entered)
        if entered then TryAuth() end
    end)
    Main.Size = UDim2.fromOffset(440, 0)
    Tween(Main, {Size = UDim2.fromOffset(440, 340)}, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    return ScreenGui
end

-- ═════════════════════════════════════════════════════════════════════════════
-- MAIN ENTRY
-- ═════════════════════════════════════════════════════════════════════════════

KeyGate.Build(Auth, function(key, source)
    print("[ZeeHood] Key validated: " .. key .. " (" .. source .. ")")

    local Config = loadModule("config.lua")
    local Targeting = loadModule("modules/targeting.lua")
    Targeting.SetConfig(Config)

    local Visuals = loadModule("modules/visuals.lua")
    Visuals.SetConfig(Config)
    Visuals.SetTargeting(Targeting)

    local Combat = loadModule("modules/combat.lua")
    Combat.SetConfig(Config)
    Combat.SetTargeting(Targeting)
    Combat.SetVisuals(Visuals)

    local Misc = loadModule("modules/misc.lua")
    Misc.SetConfig(Config)
    Misc.Start()

    local Farm = loadModule("modules/farm.lua")
    Farm.SetConfig(Config)
    Farm.SetTargeting(Targeting)

    local UI = loadModule("modules/ui.lua")
    UI.SetConfig(Config)
    UI.SetTargeting(Targeting)
    UI.SetCombat(Combat)
    UI.SetMisc(Misc)
    UI.SetFarm(Farm)
    UI.Build()

    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    RunService.RenderStepped:Connect(function()
        local anyVisuals = Config.FOV_Enabled or Config.Tracers or Config.Highlights or Config.Spectate or Config.Hitmarkers
        if anyVisuals then
            Visuals.Update()
        else
            Visuals.Clear()
        end

        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                if Config.RapidFire then
                    Combat.SetupFullAuto(tool)
                end
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
        local savedTarget = Targeting.SelectedTarget
        local savedPlayer = nil
        if savedTarget and savedTarget.Parent then
            savedPlayer = Players:GetPlayerFromCharacter(savedTarget.Parent)
        end

        Combat.Reset()
        Config.Spectate = false
        Targeting.StopSpectate()
        Misc.Reset()

        task.delay(0.5, function()
            if savedPlayer then
                if savedPlayer.Character then
                    local targetPart = savedPlayer.Character:FindFirstChild(Config.TargetPart or "Head")
                    if targetPart then
                        Targeting.SelectedTarget = targetPart
                    end
                end
            elseif savedTarget and savedTarget.Parent then
                Targeting.SelectedTarget = savedTarget
            end
        end)
    end)

    print("[ZeeHood] Stars.cc loaded")
    print("[ZeeHood] Toggle UI with " .. Config.ToggleKey.Name)
end)