local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Farm = {
    Config = nil,
    Targeting = nil,
    HeartbeatConn = nil,
    OriginalCFrame = nil,
    TargetHighlight = nil,
    NotificationGui = nil,
}

--// ==================== UTILS ====================
local function GetHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetTargetHRP(player)
    if not player then return nil end
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetTargetHead(player)
    if not player then return nil end
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("Head")
end

local function GetTargetHumanoid(player)
    if not player then return nil end
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

--// ==================== NOTIFICATIONS ====================
function Farm.Notify(text, color)
    color = color or Color3.fromRGB(100, 200, 150)

    if not Farm.NotificationGui then
        local sg = Instance.new("ScreenGui")
        sg.Name = "ENIFarmNotifs"
        sg.ResetOnSpawn = false
        sg.Parent = game.CoreGui
        Farm.NotificationGui = sg
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 32)
    frame.Position = UDim2.new(0.5, -130, 0, -40)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    frame.Parent = Farm.NotificationGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(235, 235, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    frame:TweenPosition(UDim2.new(0.5, -130, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)

    task.delay(2, function()
        frame:TweenPosition(UDim2.new(0.5, -130, 0, -40), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
        task.wait(0.35)
        if frame then frame:Destroy() end
    end)
end

--// ==================== TARGET MANAGEMENT ====================
function Farm.GetSelectedTarget()
    if Farm.Targeting and Farm.Targeting.SelectedTarget then
        -- SelectedTarget might be a Player object or a Part
        local target = Farm.Targeting.SelectedTarget
        if typeof(target) == "Instance" then
            if target:IsA("Player") then
                return target
            elseif target:IsA("BasePart") and target.Parent then
                return Players:GetPlayerFromCharacter(target.Parent)
            end
        end
    end
    return nil
end

function Farm.SaveTargetPosition()
    local target = Farm.GetSelectedTarget()
    if not target then
        Farm.OriginalCFrame = nil
        return
    end
    local hrp = GetTargetHRP(target)
    if hrp then
        Farm.OriginalCFrame = hrp.CFrame
        Farm.HighlightTarget(target)
    end
end

function Farm.RestoreTarget()
    if Farm.OriginalCFrame then
        local target = Farm.GetSelectedTarget()
        if target then
            local hrp = GetTargetHRP(target)
            if hrp and hrp.Parent then
                hrp.CFrame = Farm.OriginalCFrame
                -- Let physics take over — do NOT zero velocity
            end
        end
    end
    Farm.OriginalCFrame = nil
    Farm.ClearHighlight()
end

function Farm.IsTargetAlive()
    local target = Farm.GetSelectedTarget()
    if not target then return false end
    local hum = GetTargetHumanoid(target)
    if not hum then return false end
    return hum.Health > 0
end

--// ==================== HIGHLIGHT ====================
function Farm.HighlightTarget(player)
    Farm.ClearHighlight()
    if not player then return end
    local char = player.Character
    if not char then return end

    local hl = Instance.new("Highlight")
    hl.Name = "ENI_FarmHighlight"
    hl.FillColor = Color3.fromRGB(145, 75, 255)
    hl.OutlineColor = Color3.fromRGB(255, 200, 255)
    hl.FillTransparency = 0.3
    hl.OutlineTransparency = 0
    hl.Parent = char
    hl.Adornee = char
    Farm.TargetHighlight = hl
end

function Farm.ClearHighlight()
    if Farm.TargetHighlight then
        Farm.TargetHighlight:Destroy()
        Farm.TargetHighlight = nil
    end
end

--// ==================== CORE FARM LOGIC ====================
function Farm.GetCrosshairWorldPos()
    local camPos = Camera.CFrame.Position
    local forward = Camera.CFrame.LookVector
    return camPos + (forward * (Farm.Config.FarmDistance or 12)) + Vector3.new(0, Farm.Config.FarmVerticalOffset or 0, 0)
end

function Farm.PullTarget()
    if not Farm.Config or not Farm.Config.FarmEnabled then return end

    local target = Farm.GetSelectedTarget()
    if not target then return end

    -- Check if target died
    if not Farm.IsTargetAlive() then
        Farm.Notify("Target died", Color3.fromRGB(200, 150, 100))
        Farm.RestoreTarget()
        return
    end

    local targetHRP = GetTargetHRP(target)
    local targetHead = GetTargetHead(target)
    local myHRP = GetHRP()
    if not targetHRP or not myHRP then return end

    -- Save original position if not saved yet
    if not Farm.OriginalCFrame then
        Farm.OriginalCFrame = targetHRP.CFrame
        Farm.HighlightTarget(target)
    end

    -- Calculate where their HEAD should be
    local headTargetPos = Farm.GetCrosshairWorldPos()

    -- Calculate offset from HRP to Head
    local headOffset = Vector3.new(0, 1.5, 0)
    if targetHead and targetHRP then
        headOffset = targetHead.Position - targetHRP.Position
    end

    local newHRPPos = headTargetPos - headOffset
    local fakeCF = CFrame.new(newHRPPos, myHRP.Position)

    local pullSpeed = Farm.Config.FarmPullSpeed or 1
    if pullSpeed <= 1 then
        targetHRP.CFrame = fakeCF
    else
        local current = targetHRP.CFrame
        local lerped = current:Lerp(fakeCF, 1 / pullSpeed)
        targetHRP.CFrame = lerped
    end

    -- Zero velocity so they stay put while farm is ON
    targetHRP.Velocity = Vector3.new(0, 0, 0)
    targetHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    targetHRP.RotVelocity = Vector3.new(0, 0, 0)
end

--// ==================== CONTROL ====================
function Farm.Start()
    if Farm.HeartbeatConn then Farm.HeartbeatConn:Disconnect() end
    Farm.SaveTargetPosition()
    Farm.HeartbeatConn = RunService.Heartbeat:Connect(Farm.PullTarget)

    local target = Farm.GetSelectedTarget()
    if target then
        Farm.Notify("Farming " .. target.DisplayName, Color3.fromRGB(145, 75, 255))
    else
        Farm.Notify("Farm ON — select a target in Target tab", Color3.fromRGB(145, 75, 255))
    end
end

function Farm.Stop()
    if Farm.HeartbeatConn then
        Farm.HeartbeatConn:Disconnect()
        Farm.HeartbeatConn = nil
    end
    Farm.RestoreTarget()
    print("[ENI Farm] STOPPED — Target restored")
end

function Farm.SetEnabled(enabled)
    if not Farm.Config then return end
    Farm.Config.FarmEnabled = enabled
    if enabled then
        Farm.Start()
    else
        Farm.Stop()
    end
end

function Farm.Toggle()
    if not Farm.Config then return end
    Farm.SetEnabled(not Farm.Config.FarmEnabled)
end

function Farm.SetConfig(config)
    Farm.Config = config
end

function Farm.SetTargeting(targeting)
    Farm.Targeting = targeting
end

--// Cleanup on respawn
LocalPlayer.CharacterAdded:Connect(function()
    if Farm.Config and Farm.Config.FarmEnabled then
        task.wait(0.5)
        Farm.SaveTargetPosition()
    end
end)

return Farm