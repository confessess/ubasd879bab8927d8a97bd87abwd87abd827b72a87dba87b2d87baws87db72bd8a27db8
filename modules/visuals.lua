local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Visuals = {
    Config = nil,
    Targeting = nil,
}

-- ═════════════════════════════════════════════════════════════════════════════
-- DRAWING LIFECYCLE (Legacy — FOV, Tracer, Hitmarker)
-- ═════════════════════════════════════════════════════════════════════════════
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
    Visible = false, Thickness = 1.2, Color = Color3.fromRGB(255, 80, 80),
    Transparency = 0.6, Filled = false, NumSides = 64,
})
local Tracer = DrawingNew("Line", {
    Visible = false, Thickness = 1, Color = Color3.fromRGB(255, 60, 60), Transparency = 0.5,
})
local Hitmarker = DrawingNew("Text", {
    Visible = false, Size = 20, Center = true, Outline = true,
    Color = Color3.fromRGB(255, 255, 255), Text = "✕",
})

-- ═════════════════════════════════════════════════════════════════════════════
-- ESP UTILITIES (Pouncing.exe style — GetExtentsSize)
-- ═════════════════════════════════════════════════════════════════════════════
local ESPDrawingObjects = {}
local ESPRenderConnection = nil
local ESPPlayerAddedConnection = nil
local ESPPlayerRemovingConnection = nil
local ESPCharacterAddedConnections = {}

local function MakeDrawing(type, props)
    local s, obj = pcall(Drawing.new, type)
    if not s or not obj then return nil end
    for k, v in pairs(props or {}) do pcall(function() obj[k] = v end) end
    return obj
end

local function SetDrawing(obj, key, value)
    if obj then pcall(function() obj[key] = value end) end
end

local function RemoveDrawing(obj)
    if obj then pcall(function() obj:Remove() end) end
end

local function W2S(position)
    local s, x, y, z = pcall(function()
        local v = Camera:WorldToViewportPoint(position)
        return v.X, v.Y, v.Z
    end)
    if s and z and z > 0 then return Vector2.new(x, y), true, z end
    return Vector2.new(-999, -999), false, 0
end

local function GetBoxData(character)
    local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    if not root then return nil end
    local s, extents = pcall(function() return character:GetExtentsSize() end)
    if not s or not extents then return nil end
    local size = extents * 1.1
    local topPos = root.Position + Vector3.new(0, size.Y / 2, 0)
    local botPos = root.Position - Vector3.new(0, size.Y / 2, 0)
    local topScr, topVis, topZ = W2S(topPos)
    local botScr, botVis, botZ = W2S(botPos)
    if (not topVis and not botVis) or topZ <= 0 or botZ <= 0 then return nil end
    local h = math.abs(botScr.Y - topScr.Y)
    local w = h * 0.6
    if h <= 1 or w <= 1 then return nil end
    return {
        TL = Vector2.new(topScr.X - w / 2, topScr.Y),
        BR = Vector2.new(topScr.X + w / 2, botScr.Y),
        Size = Vector2.new(w, h),
        Center = Vector2.new(topScr.X, (topScr.Y + botScr.Y) / 2),
        Pos = root.Position,
        Extents = extents
    }
end

local function Get3DCorners(character)
    local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    if not root then return nil end
    local s, extents = pcall(function() return character:GetExtentsSize() end)
    if not s or not extents then return nil end
    local p = root.Position
    local hx, hy, hz = extents.X / 2, extents.Y / 2, extents.Z / 2
    local corners = {
        p + Vector3.new(-hx, -hy, -hz), p + Vector3.new(hx, -hy, -hz),
        p + Vector3.new(hx, -hy, hz), p + Vector3.new(-hx, -hy, hz),
        p + Vector3.new(-hx, hy, -hz), p + Vector3.new(hx, hy, -hz),
        p + Vector3.new(hx, hy, hz), p + Vector3.new(-hx, hy, hz)
    }
    local screenCorners = {}
    for i = 1, 8 do
        local sp, vis, z = W2S(corners[i])
        if not vis or z <= 0 then return nil end
        screenCorners[i] = sp
    end
    return screenCorners
end

local Box3DEdges = {
    {1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}
}

local SkeletonConnections = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}, {"Torso", "Head"}
}

-- ═════════════════════════════════════════════════════════════════════════════
-- ESP STATE
-- ═════════════════════════════════════════════════════════════════════════════
local function GetESPConfig()
    local Config = Visuals.Config
    if not Config then return nil end
    return {
        Enabled = Config.ESP_Enabled,
        Boxes = Config.ESP_Boxes,
        Box3D = Config.ESP_Box3D,
        Names = Config.ESP_Names,
        Distance = Config.ESP_Distance,
        Health = Config.ESP_Health,
        Skeleton = Config.ESP_Skeleton,
        Chams = Config.ESP_Chams,
        Tracers = false,
        HeadDot = Config.ESP_HeadDot,
        WeaponNames = Config.ESP_WeaponNames,
        TeamCheck = Config.ESP_TeamCheck,
        DistanceToggle = Config.ESP_DistanceToggle,
        MaxDistance = Config.ESP_MaxDistance,
        TargetMode = Config.ESP_TargetMode,
        BoxThickness = Config.ESP_BoxThickness,
        HeadDotThickness = Config.ESP_HeadDotThickness,
        HeadDotSize = Config.ESP_HeadDotSize,
        Colors = Config.ESP_Colors,
    }
end

local function InitPlayer(player)
    if player == LocalPlayer or ESPDrawingObjects[player] then return end
    local skel = {}
    for i = 1, #SkeletonConnections do
        table.insert(skel, MakeDrawing("Line", {Visible = false, Thickness = 1.5, Color = Color3.fromRGB(255,255,255), Transparency = 0.8}))
        table.insert(skel, MakeDrawing("Line", {Visible = false, Thickness = 3, Color = Color3.fromRGB(0,0,0), Transparency = 0.5}))
    end
    local b3d, b3do = {}, {}
    for i = 1, 12 do
        table.insert(b3d, MakeDrawing("Line", {Visible = false, Thickness = 1.5, Color = Color3.fromRGB(255,105,180), Transparency = 0.9}))
        table.insert(b3do, MakeDrawing("Line", {Visible = false, Thickness = 3, Color = Color3.fromRGB(0,0,0), Transparency = 0.5}))
    end
    ESPDrawingObjects[player] = {
        Box = MakeDrawing("Square", {Visible = false, Thickness = 1, Color = Color3.fromRGB(255,105,180), Transparency = 0.9, Filled = false}),
        B3D = b3d, B3DO = b3do,
        Name = MakeDrawing("Text", {Visible = false, Text = player.Name, Size = 16, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Color = Color3.fromRGB(255,255,255)}),
        HB = MakeDrawing("Square", {Visible = false, Thickness = 1, Filled = true, Color = Color3.fromRGB(0,255,100)}),
        HBO = MakeDrawing("Square", {Visible = false, Thickness = 1, Filled = true, Color = Color3.fromRGB(0,0,0)}),
        HT = MakeDrawing("Text", {Visible = false, Text = "100", Size = 13, Center = false, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Color = Color3.fromRGB(255,255,255)}),
        Skel = skel,
        Dist = MakeDrawing("Text", {Visible = false, Text = "", Size = 14, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Color = Color3.fromRGB(200,200,200)}),
        Tracer = MakeDrawing("Line", {Visible = false, Thickness = 1.5, Color = Color3.fromRGB(255,105,180), Transparency = 0.7}),
        TracerO = MakeDrawing("Line", {Visible = false, Thickness = 3, Color = Color3.fromRGB(0,0,0), Transparency = 0.4}),
        HeadDot = MakeDrawing("Circle", {Visible = false, Thickness = 1, Color = Color3.fromRGB(255,255,255), Transparency = 0.9, NumSides = 16, Filled = true}),
        HeadDotO = MakeDrawing("Circle", {Visible = false, Thickness = 2, Color = Color3.fromRGB(0,0,0), Transparency = 0.5, NumSides = 16, Filled = false}),
        Weapon = MakeDrawing("Text", {Visible = false, Text = "", Size = 13, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Color = Color3.fromRGB(255,200,100)}),
    }
end

local function ClearPlayer(player)
    if not ESPDrawingObjects[player] then return end
    local o = ESPDrawingObjects[player]
    for k, v in pairs(o) do
        if k == "Skel" or k == "B3D" or k == "B3DO" then
            for _, line in pairs(v) do RemoveDrawing(line) end
        else
            RemoveDrawing(v)
        end
    end
    ESPDrawingObjects[player] = nil
    local char = player.Character
    if char then
        local h = char:FindFirstChild("Visuals_Chams")
        if h then h:Destroy() end
    end
    if ESPCharacterAddedConnections[player] then
        ESPCharacterAddedConnections[player]:Disconnect()
        ESPCharacterAddedConnections[player] = nil
    end
end

local function HideAll(o)
    SetDrawing(o.Box, "Visible", false)
    SetDrawing(o.Name, "Visible", false)
    SetDrawing(o.Dist, "Visible", false)
    SetDrawing(o.HB, "Visible", false)
    SetDrawing(o.HBO, "Visible", false)
    SetDrawing(o.HT, "Visible", false)
    SetDrawing(o.Tracer, "Visible", false)
    SetDrawing(o.TracerO, "Visible", false)
    SetDrawing(o.HeadDot, "Visible", false)
    SetDrawing(o.HeadDotO, "Visible", false)
    SetDrawing(o.Weapon, "Visible", false)
    for _, l in pairs(o.Skel) do SetDrawing(l, "Visible", false) end
    for _, l in pairs(o.B3D) do SetDrawing(l, "Visible", false) end
    for _, l in pairs(o.B3DO) do SetDrawing(l, "Visible", false) end
end

local function GetPlayerWeapon(player)
    local char = player.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool.Name end
    return nil
end

local function RefreshESPColors()
    local ESP = GetESPConfig()
    if not ESP then return end
    for player, o in pairs(ESPDrawingObjects) do
        if o.Box then SetDrawing(o.Box, "Color", ESP.Colors.Box); SetDrawing(o.Box, "Thickness", ESP.BoxThickness) end
        if o.Name then SetDrawing(o.Name, "Color", ESP.Colors.Name) end
        if o.Dist then SetDrawing(o.Dist, "Color", ESP.Colors.Distance) end
        if o.HeadDot then SetDrawing(o.HeadDot, "Color", ESP.Colors.HeadDot); SetDrawing(o.HeadDot, "Thickness", ESP.HeadDotThickness) end
        if o.HB then SetDrawing(o.HB, "Color", ESP.Colors.Health) end
        if o.Skel then
            for i = 1, #o.Skel, 2 do
                if o.Skel[i] then SetDrawing(o.Skel[i], "Color", ESP.Colors.Skeleton) end
            end
        end
        if o.B3D then
            for _, line in pairs(o.B3D) do
                if line then SetDrawing(line, "Color", ESP.Colors.Box) end
            end
        end
        local char = player.Character
        if char then
            local hl = char:FindFirstChild("Visuals_Chams")
            if hl then
                hl.FillColor = ESP.Colors.ChamsFill
                hl.OutlineColor = ESP.Colors.ChamsOutline
            end
        end
    end
end

local function ShouldShowESP(player)
    local ESP = GetESPConfig()
    if not ESP then return false end
    if not ESP.Enabled then return false end
    if player == LocalPlayer then return false end
    if ESP.TargetMode and Visuals.Targeting then
        local target = Visuals.Targeting.GetTarget()
        if target and target.Parent then
            local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
            if targetPlayer ~= player then return false end
        else
            return false
        end
    end
    return true
end

local function UpdateChams(player, char, ESP)
    if not ESP.Chams then
        local old = char:FindFirstChild("Visuals_Chams")
        if old then old.Enabled = false end
        return
    end

    local hl = char:FindFirstChild("Visuals_Chams")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "Visuals_Chams"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
    end

    pcall(function()
        hl.FillColor = ESP.Colors.ChamsFill
        hl.OutlineColor = ESP.Colors.ChamsOutline
    end)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0.2
    hl.Enabled = true
end

local function UpdateESPPlayer(player)
    local ESP = GetESPConfig()
    if not ESP then return end
    local o = ESPDrawingObjects[player]
    if not o then return end
    if not ShouldShowESP(player) then 
        HideAll(o) 
        local char = player.Character
        if char then
            local hl = char:FindFirstChild("Visuals_Chams")
            if hl then hl.Enabled = false end
        end
        return 
    end
    local char = player.Character
    if not char then HideAll(o) return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if not hum or not root or hum.Health <= 0 then 
        HideAll(o) 
        local hl = char:FindFirstChild("Visuals_Chams")
        if hl then hl.Enabled = false end
        return 
    end
    if ESP.TeamCheck then
        local isTeammate = false
        if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then isTeammate = true end
        if LocalPlayer.TeamColor and player.TeamColor and LocalPlayer.TeamColor == player.TeamColor then isTeammate = true end
        if isTeammate then 
            HideAll(o) 
            local hl = char:FindFirstChild("Visuals_Chams")
            if hl then hl.Enabled = false end
            return 
        end
    end
    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if ESP.DistanceToggle and dist > ESP.MaxDistance then 
        HideAll(o) 
        local hl = char:FindFirstChild("Visuals_Chams")
        if hl then hl.Enabled = false end
        return 
    end

    -- Update Chams
    UpdateChams(player, char, ESP)

    local box = GetBoxData(char)
    if not box then 
        HideAll(o) 
        return 
    end

    -- No smoothing - 100% accurate tracking

    SetDrawing(o.Box, "Thickness", ESP.BoxThickness)
    if ESP.Boxes and not ESP.Box3D then
        SetDrawing(o.Box, "Size", box.Size)
        SetDrawing(o.Box, "Position", box.TL)
        SetDrawing(o.Box, "Color", ESP.Colors.Box)
        SetDrawing(o.Box, "Thickness", ESP.BoxThickness)
        SetDrawing(o.Box, "Visible", true)
    else
        SetDrawing(o.Box, "Visible", false)
    end
    if ESP.Boxes and ESP.Box3D then
        local c = Get3DCorners(char)
        if c then
            for i, e in ipairs(Box3DEdges) do
                SetDrawing(o.B3D[i], "From", c[e[1]])
                SetDrawing(o.B3D[i], "To", c[e[2]])
                SetDrawing(o.B3D[i], "Color", ESP.Colors.Box)
                SetDrawing(o.B3D[i], "Visible", true)
                SetDrawing(o.B3DO[i], "From", c[e[1]])
                SetDrawing(o.B3DO[i], "To", c[e[2]])
                SetDrawing(o.B3DO[i], "Visible", true)
            end
        else
            for _, l in pairs(o.B3D) do SetDrawing(l, "Visible", false) end
            for _, l in pairs(o.B3DO) do SetDrawing(l, "Visible", false) end
        end
    else
        for _, l in pairs(o.B3D) do SetDrawing(l, "Visible", false) end
        for _, l in pairs(o.B3DO) do SetDrawing(l, "Visible", false) end
    end
    if ESP.Names then
        SetDrawing(o.Name, "Position", Vector2.new(box.Center.X, box.TL.Y - 16))
        SetDrawing(o.Name, "Text", player.Name)
        SetDrawing(o.Name, "Color", ESP.Colors.Name)
        SetDrawing(o.Name, "Visible", true)
    else
        SetDrawing(o.Name, "Visible", false)
    end
    if ESP.Distance then
        SetDrawing(o.Dist, "Position", Vector2.new(box.Center.X, box.BR.Y + 4))
        SetDrawing(o.Dist, "Text", math.floor(dist) .. "m")
        SetDrawing(o.Dist, "Color", ESP.Colors.Distance)
        SetDrawing(o.Dist, "Visible", true)
    else
        SetDrawing(o.Dist, "Visible", false)
    end
    if ESP.Health then
        local ok = pcall(function()
            local mh = hum.MaxHealth
            local ch = hum.Health
            if not mh or mh <= 0 or not ch or ch < 0 then
                SetDrawing(o.HB, "Visible", false)
                SetDrawing(o.HBO, "Visible", false)
                SetDrawing(o.HT, "Visible", false)
                return
            end
            local pct = math.clamp(ch / mh, 0, 1)
            local bh = math.max(box.Size.Y * pct, 2)
            local bw = 4
            if box.Size.Y <= 0 then
                SetDrawing(o.HB, "Visible", false)
                SetDrawing(o.HBO, "Visible", false)
                SetDrawing(o.HT, "Visible", false)
                return
            end
            SetDrawing(o.HBO, "Size", Vector2.new(bw + 2, box.Size.Y + 2))
            SetDrawing(o.HBO, "Position", Vector2.new(box.TL.X - bw - 6, box.TL.Y - 1))
            SetDrawing(o.HBO, "Visible", true)
            SetDrawing(o.HB, "Size", Vector2.new(bw, bh))
            SetDrawing(o.HB, "Position", Vector2.new(box.TL.X - bw - 5, box.BR.Y - bh))
            local fullColor = ESP.Colors.Health
            local emptyColor = Color3.fromRGB(255, 0, 0)
            local healthColor = emptyColor:Lerp(fullColor, pct)
            SetDrawing(o.HB, "Color", healthColor)
            SetDrawing(o.HB, "Visible", true)
            SetDrawing(o.HT, "Position", Vector2.new(box.TL.X - bw - 28, box.BR.Y - bh - 6))
            SetDrawing(o.HT, "Text", math.floor(ch))
            SetDrawing(o.HT, "Visible", true)
        end)
        if not ok then
            SetDrawing(o.HB, "Visible", false)
            SetDrawing(o.HBO, "Visible", false)
            SetDrawing(o.HT, "Visible", false)
        end
    else
        SetDrawing(o.HB, "Visible", false)
        SetDrawing(o.HBO, "Visible", false)
        SetDrawing(o.HT, "Visible", false)
    end
    if ESP.Skeleton then
        local idx = 1
        for _, conn in ipairs(SkeletonConnections) do
            local p1 = char:FindFirstChild(conn[1])
            local p2 = char:FindFirstChild(conn[2])
            local line = o.Skel[idx]
            local outline = o.Skel[idx + 1]
            idx = idx + 2
            if p1 and p2 and line and outline then
                local s1, v1 = W2S(p1.Position)
                local s2, v2 = W2S(p2.Position)
                if v1 and v2 then
                    SetDrawing(line, "From", s1)
                    SetDrawing(line, "To", s2)
                    SetDrawing(line, "Color", ESP.Colors.Skeleton)
                    SetDrawing(line, "Visible", true)
                    SetDrawing(outline, "From", s1)
                    SetDrawing(outline, "To", s2)
                    SetDrawing(outline, "Visible", true)
                else
                    SetDrawing(line, "Visible", false)
                    SetDrawing(outline, "Visible", false)
                end
            else
                if line then SetDrawing(line, "Visible", false) end
                if outline then SetDrawing(outline, "Visible", false) end
            end
        end
    else
        for _, l in pairs(o.Skel) do SetDrawing(l, "Visible", false) end
    end
    if ESP.HeadDot then
        local head = char:FindFirstChild("Head")
        if head then
            local headPos, onScreen = W2S(head.Position)
            if onScreen then
                local radius = math.clamp(3000 / dist, 3, 12) * ESP.HeadDotSize
                SetDrawing(o.HeadDot, "Position", headPos)
                SetDrawing(o.HeadDot, "Radius", radius)
                SetDrawing(o.HeadDot, "Color", ESP.Colors.HeadDot)
                SetDrawing(o.HeadDot, "Thickness", ESP.HeadDotThickness)
                SetDrawing(o.HeadDot, "Visible", true)
                SetDrawing(o.HeadDotO, "Position", headPos)
                SetDrawing(o.HeadDotO, "Radius", radius + 1)
                SetDrawing(o.HeadDotO, "Thickness", ESP.HeadDotThickness + 1)
                SetDrawing(o.HeadDotO, "Visible", true)
            else
                SetDrawing(o.HeadDot, "Visible", false)
                SetDrawing(o.HeadDotO, "Visible", false)
            end
        else
            SetDrawing(o.HeadDot, "Visible", false)
            SetDrawing(o.HeadDotO, "Visible", false)
        end
    else
        SetDrawing(o.HeadDot, "Visible", false)
        SetDrawing(o.HeadDotO, "Visible", false)
    end
    if ESP.WeaponNames then
        local weapon = GetPlayerWeapon(player)
        if weapon then
            SetDrawing(o.Weapon, "Position", Vector2.new(box.Center.X, box.BR.Y + 18))
            SetDrawing(o.Weapon, "Text", "[" .. weapon .. "]")
            SetDrawing(o.Weapon, "Visible", true)
        else
            SetDrawing(o.Weapon, "Visible", false)
        end
    else
        SetDrawing(o.Weapon, "Visible", false)
    end
end

local function ESPUpdate()
    local ESP = GetESPConfig()
    if not ESP or not ESP.Enabled then
        for player, o in pairs(ESPDrawingObjects) do
            HideAll(o)
            local c = player.Character
            if c then local h = c:FindFirstChild("Visuals_Chams"); if h then h.Enabled = false end end
        end
        return
    end
    for _, p in pairs(Players:GetPlayers()) do
        pcall(function() UpdateESPPlayer(p) end)
    end
end

local function ESPInit()
    for _, p in pairs(Players:GetPlayers()) do
        InitPlayer(p)
        -- Set up CharacterAdded for chams persistence
        if not ESPCharacterAddedConnections[p] then
            ESPCharacterAddedConnections[p] = p.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                local ESP = GetESPConfig()
                if ESP and ESP.Chams then
                    local hl = Instance.new("Highlight")
                    hl.Name = "Visuals_Chams"
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = char
                    pcall(function()
                        hl.FillColor = ESP.Colors.ChamsFill
                        hl.OutlineColor = ESP.Colors.ChamsOutline
                    end)
                    hl.FillTransparency = 0.6
                    hl.OutlineTransparency = 0.2
                    hl.Enabled = true
                end
            end)
        end
    end
    ESPPlayerAddedConnection = Players.PlayerAdded:Connect(function(p)
        InitPlayer(p)
        ESPCharacterAddedConnections[p] = p.CharacterAdded:Connect(function(char)
            task.wait(0.1)
            local ESP = GetESPConfig()
            if ESP and ESP.Chams then
                local hl = Instance.new("Highlight")
                hl.Name = "Visuals_Chams"
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char
                pcall(function()
                    hl.FillColor = ESP.Colors.ChamsFill
                    hl.OutlineColor = ESP.Colors.ChamsOutline
                end)
                hl.FillTransparency = 0.6
                hl.OutlineTransparency = 0.2
                hl.Enabled = true
            end
        end)
    end)
    ESPPlayerRemovingConnection = Players.PlayerRemoving:Connect(function(p)
        ClearPlayer(p)
    end)
end

local function ESPDisable()
    local ESP = GetESPConfig()
    if ESP then ESP.Enabled = false end
    if ESPRenderConnection then ESPRenderConnection:Disconnect(); ESPRenderConnection = nil end
    for player, o in pairs(ESPDrawingObjects) do
        HideAll(o)
        local c = player.Character
        if c then local h = c:FindFirstChild("Visuals_Chams"); if h then h.Enabled = false end end
    end
end

local function ESPCleanup()
    ESPDisable()
    if ESPPlayerAddedConnection then ESPPlayerAddedConnection:Disconnect(); ESPPlayerAddedConnection = nil end
    if ESPPlayerRemovingConnection then ESPPlayerRemovingConnection:Disconnect(); ESPPlayerRemovingConnection = nil end
    for player, conn in pairs(ESPCharacterAddedConnections) do
        if conn then conn:Disconnect() end
    end
    ESPCharacterAddedConnections = {}
    for player, _ in pairs(ESPDrawingObjects) do
        ClearPlayer(player)
    end
    ESPDrawingObjects = {}
end

-- ═════════════════════════════════════════════════════════════════════════════
-- LEGACY VISUALS (FOV, Tracer, Hitmarker — Stars.cc interface)
-- ═════════════════════════════════════════════════════════════════════════════
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
    FOV_Circle.Color = Config.FOV_Color
    local target = Targeting.GetTarget()
    if Config.Tracers and target then
        local sp, onScreen = Camera:WorldToViewportPoint(target.Position)
        if onScreen then
            Tracer.Visible = true
            Tracer.From = mousePos
            Tracer.To = Vector2.new(sp.X, sp.Y)
            Tracer.Color = Config.Tracer_Color
        else
            Tracer.Visible = false
        end
    else
        Tracer.Visible = false
    end
    Targeting.UpdateHighlight(target)
    Targeting.UpdateSpectate()
    if Config.ESP_Enabled then
        if not ESPRenderConnection then
            ESPRenderConnection = RunService.RenderStepped:Connect(ESPUpdate)
        end
    else
        if ESPRenderConnection then
            ESPRenderConnection:Disconnect()
            ESPRenderConnection = nil
        end
        for player, o in pairs(ESPDrawingObjects) do
            HideAll(o)
            local c = player.Character
            if c then local h = c:FindFirstChild("Visuals_Chams"); if h then h.Enabled = false end end
        end
    end
end

function Visuals.Clear()
    FOV_Circle.Visible = false
    Tracer.Visible = false
    Hitmarker.Visible = false
    if Visuals.Targeting then
        Visuals.Targeting.UpdateHighlight(nil)
    end
    for player, o in pairs(ESPDrawingObjects) do
        HideAll(o)
        local c = player.Character
        if c then local h = c:FindFirstChild("Visuals_Chams"); if h then h.Enabled = false end end
    end
end

function Visuals.PlayHitmarker()
    if not Visuals.Config or not Visuals.Config.Hitmarkers then return end
    Hitmarker.Position = UserInputService:GetMouseLocation() + Vector2.new(0, -15)
    Hitmarker.Visible = true
    Hitmarker.Color = Color3.fromRGB(255, 80, 80)
    delay(0.2, function() Hitmarker.Visible = false end)
end

function Visuals.Init(config)
    Visuals.Config = config
    if config.ESP_Enabled then
        ESPInit()
    end
end

function Visuals.Cleanup()
    ESPCleanup()
    for _, conn in pairs(Visuals.Connections or {}) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    Visuals.Connections = {}
end

function Visuals.ShowHitmarker()
    if not Visuals.Config or not Visuals.Config.Hitmarkers then return end
    Hitmarker.Position = UserInputService:GetMouseLocation() + Vector2.new(0, -15)
    Hitmarker.Visible = true
    Hitmarker.Color = Color3.fromRGB(255, 80, 80)
    delay(0.2, function() Hitmarker.Visible = false end)
end

ESPInit()

return Visuals