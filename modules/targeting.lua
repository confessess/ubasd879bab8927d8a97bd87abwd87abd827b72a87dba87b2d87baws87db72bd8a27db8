local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Targeting = {
    Config = nil,
    SelectedTarget = nil,
    TargetHighlight = nil,
    TargetGui = nil,
    RenderConn = nil,
}

-- ═════════════════════════════════════════════════════════════════════════════
-- UTILITIES
-- ═════════════════════════════════════════════════════════════════════════════

local function GetCharacter(player)
    return player and player.Character
end

local function GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function IsAlive(character)
    local hum = GetHumanoid(character)
    return hum and hum.Health > 0
end

local function IsTeammate(player)
    if player == Players.LocalPlayer then return true end
    if Players.LocalPlayer.Team and player.Team and Players.LocalPlayer.Team == player.Team then return true end
    if Players.LocalPlayer.TeamColor and player.TeamColor and Players.LocalPlayer.TeamColor == player.TeamColor then return true end
    return false
end

local function GetDistance(position)
    return (position - Workspace.CurrentCamera.CFrame.Position).Magnitude
end

local function GetTargetPart(character, partName)
    return character:FindFirstChild(partName)
        or character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")
end

-- ═════════════════════════════════════════════════════════════════════════════
-- TARGET SELECTION
-- ═════════════════════════════════════════════════════════════════════════════

function Targeting.GetTarget()
    if Targeting.SelectedTarget then
        if typeof(Targeting.SelectedTarget) == "Instance" then
            if Targeting.SelectedTarget:IsA("Player") then
                local char = Targeting.SelectedTarget.Character
                if char and IsAlive(char) then
                    local partName = Targeting.Config and Targeting.Config.TargetPart or "Head"
                    local part = GetTargetPart(char, partName)
                    if part then
                        return part
                    end
                end
            elseif Targeting.SelectedTarget:IsA("BasePart") then
                return Targeting.SelectedTarget
            end
        end
    end
    return nil
end

function Targeting.GetTargetPlayer()
    if not Targeting.SelectedTarget then return nil end
    if typeof(Targeting.SelectedTarget) == "Instance" then
        if Targeting.SelectedTarget:IsA("Player") then
            return Targeting.SelectedTarget
        elseif Targeting.SelectedTarget:IsA("BasePart") and Targeting.SelectedTarget.Parent then
            return Players:GetPlayerFromCharacter(Targeting.SelectedTarget.Parent)
        end
    end
    return nil
end

function Targeting.SetTarget(target)
    Targeting.ClearTarget()
    Targeting.SelectedTarget = target
    if target then
        Targeting.HighlightTarget()
        Targeting.ShowTargetGui()
    end
end

function Targeting.ClearTarget()
    Targeting.SelectedTarget = nil
    if Targeting.TargetHighlight then
        Targeting.TargetHighlight:Destroy()
        Targeting.TargetHighlight = nil
    end
    if Targeting.TargetGui then
        Targeting.TargetGui:Destroy()
        Targeting.TargetGui = nil
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- HIGHLIGHT
-- ═════════════════════════════════════════════════════════════════════════════

function Targeting.HighlightTarget()
    if Targeting.TargetHighlight then
        Targeting.TargetHighlight:Destroy()
        Targeting.TargetHighlight = nil
    end

    local target = Targeting.SelectedTarget
    if not target then return end

    local char = nil
    if typeof(target) == "Instance" then
        if target:IsA("Player") then
            char = target.Character
        elseif target:IsA("BasePart") and target.Parent then
            char = target.Parent
        end
    end

    if not char then return end

    local hl = Instance.new("Highlight")
    hl.Name = "StarsTarget"
    hl.FillColor = Color3.fromRGB(255, 50, 50)
    hl.OutlineColor = Color3.fromRGB(255, 200, 200)
    hl.FillTransparency = 0.3
    hl.OutlineTransparency = 0
    hl.Parent = char
    hl.Adornee = char
    Targeting.TargetHighlight = hl
end

-- ═════════════════════════════════════════════════════════════════════════════
-- TARGET GUI
-- ═════════════════════════════════════════════════════════════════════════════

function Targeting.ShowTargetGui()
    if Targeting.TargetGui then
        Targeting.TargetGui:Destroy()
        Targeting.TargetGui = nil
    end

    local targetPlayer = Targeting.GetTargetPlayer()
    if not targetPlayer then return end

    local sg = Instance.new("ScreenGui")
    sg.Name = "StarsTargetGui"
    sg.ResetOnSpawn = false
    sg.Parent = game.CoreGui
    Targeting.TargetGui = sg

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 60)
    frame.Position = UDim2.new(0.5, -100, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    frame.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 50, 50)
    stroke.Thickness = 1
    stroke.Parent = frame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -16, 0, 24)
    nameLabel.Position = UDim2.new(0, 8, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Target: " .. (targetPlayer.DisplayName or targetPlayer.Name)
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, -16, 0, 20)
    distLabel.Position = UDim2.new(0, 8, 0, 28)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "Distance: --"
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    distLabel.Parent = frame

    Targeting.DistLabel = distLabel
end

-- ═════════════════════════════════════════════════════════════════════════════
-- RENDER UPDATE
-- ═════════════════════════════════════════════════════════════════════════════

local function OnRender()
    local targetPlayer = Targeting.GetTargetPlayer()
    if not targetPlayer then
        Targeting.ClearTarget()
        return
    end

    local char = targetPlayer.Character
    if not char or not IsAlive(char) then
        Targeting.ClearTarget()
        return
    end

    if Targeting.DistLabel then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dist = math.floor(GetDistance(hrp.Position))
            Targeting.DistLabel.Text = "Distance: " .. dist .. " studs"
        end
    end

    if Targeting.TargetHighlight and not Targeting.TargetHighlight.Parent then
        Targeting.HighlightTarget()
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- SPECTATE
-- ═════════════════════════════════════════════════════════════════════════════

function Targeting.SetSpectate(enabled)
    if not Targeting.Config then return end
    Targeting.Config.Spectate = enabled
    if enabled then
        local targetPlayer = Targeting.GetTargetPlayer()
        if targetPlayer and targetPlayer.Character then
            Workspace.CurrentCamera.CameraSubject = targetPlayer.Character:FindFirstChildOfClass("Humanoid") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
    else
        local myChar = Players.LocalPlayer.Character
        if myChar then
            Workspace.CurrentCamera.CameraSubject = myChar:FindFirstChildOfClass("Humanoid") or myChar:FindFirstChild("HumanoidRootPart")
        end
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- LIFECYCLE
-- ═════════════════════════════════════════════════════════════════════════════

function Targeting.SetConfig(config)
    Targeting.Config = config
end

function Targeting.Init()
    if Targeting.RenderConn then return end
    Targeting.RenderConn = RunService.RenderStepped:Connect(OnRender)
end

function Targeting.Cleanup()
    if Targeting.RenderConn then
        Targeting.RenderConn:Disconnect()
        Targeting.RenderConn = nil
    end
    Targeting.ClearTarget()
end

return Targeting