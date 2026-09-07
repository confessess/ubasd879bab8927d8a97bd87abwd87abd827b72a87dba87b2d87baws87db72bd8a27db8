local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Targeting = {
    SelectedTarget = nil,
    SelectedTargets = {},
    MultiTargetEnabled = false,
    CurrentTargetIndex = 0,
    HighlightBox = nil,
    Config = nil,
}

function Targeting.SetConfig(config)
    Targeting.Config = config
end

function Targeting.AddTarget(player)
    if not player then return end
    for _, p in ipairs(Targeting.SelectedTargets) do
        if p == player then return end
    end
    table.insert(Targeting.SelectedTargets, player)
end

function Targeting.RemoveTarget(player)
    for i, p in ipairs(Targeting.SelectedTargets) do
        if p == player then
            table.remove(Targeting.SelectedTargets, i)
            return
        end
    end
end

function Targeting.IsTargetSelected(player)
    for _, p in ipairs(Targeting.SelectedTargets) do
        if p == player then return true end
    end
    return false
end

function Targeting.ClearTargets()
    Targeting.SelectedTargets = {}
    Targeting.CurrentTargetIndex = 0
end

function Targeting.GetNextValidTarget()
    if not Targeting.MultiTargetEnabled or #Targeting.SelectedTargets == 0 then
        local t = Targeting.SelectedTarget
        if t and t.Parent and t.Character then
            local hum = t.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return t
            end
        end
        return nil
    end
    -- Build valid list WITHOUT mutating SelectedTargets
    -- so dead/respawning players stay in the hit-list
    local valid = {}
    for _, plr in ipairs(Targeting.SelectedTargets) do
        if plr and plr.Parent and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                table.insert(valid, plr)
            end
        end
    end
    if #valid == 0 then
        Targeting.CurrentTargetIndex = 0
        return nil
    end
    Targeting.CurrentTargetIndex = (Targeting.CurrentTargetIndex or 0) + 1
    if Targeting.CurrentTargetIndex > #valid then
        Targeting.CurrentTargetIndex = 1
    end
    return valid[Targeting.CurrentTargetIndex]
end

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
    local Config = Targeting.Config
    if not Config then return nil end

    if Targeting.MultiTargetEnabled then
        local mt = Targeting.GetNextValidTarget()
        if mt then
            local char = mt.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    return getCharacterPart(char, Config.TargetPart)
                end
            end
        end
        return nil
    end

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

function Targeting.TeleportToTarget()
    local Config = Targeting.Config
    if not Config then return end
    local target = Targeting.GetTarget()
    if not target or not target.Parent then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local hrp = myChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local targetHrp = target.Parent:FindFirstChild("HumanoidRootPart")
    if targetHrp then
        hrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
    else
        hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
    end
end

function Targeting.UpdateHighlight(target)
    local Config = Targeting.Config
    if not Config then return end
    if not Config.Highlights then
        if Targeting.HighlightBox then Targeting.HighlightBox:Destroy() end
        Targeting.HighlightBox = nil
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
    local Config = Targeting.Config
    if not Config or not Config.Spectate then return end
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
            btn.Position = UDim2.fromOffset(0, y)

            local isSelected = false
            if Targeting.MultiTargetEnabled then
                isSelected = Targeting.IsTargetSelected(plr)
            else
                isSelected = (Targeting.SelectedTarget == plr)
            end

            btn.BackgroundColor3 = isSelected and Color3.fromRGB(70, 100, 160) or Color3.fromRGB(35, 35, 45)
            btn.Text = plr.DisplayName
            btn.TextColor3 = Color3.fromRGB(200, 200, 215)
            btn.TextSize = 11
            btn.Font = Enum.Font.Gotham
            btn.Parent = container
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = btn
            btn.MouseButton1Click:Connect(function()
                if Targeting.MultiTargetEnabled then
                    if Targeting.IsTargetSelected(plr) then
                        Targeting.RemoveTarget(plr)
                    else
                        Targeting.AddTarget(plr)
                    end
                else
                    Targeting.SelectedTarget = plr
                    Targeting.Config.TargetMode = "Selected"
                end
                onSelect()
            end)
            y = y + 26
        end
    end
    container.CanvasSize = UDim2.new(0, 0, 0, y)
end

return Targeting