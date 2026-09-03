local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Combat = {
    ModifiedTools = {},
    Config = nil,
    Targeting = nil,
    Visuals = nil,

    -- Aimbot state
    AimbotConnection = nil,
    FOVCircle = nil,
    TargetCircle = nil,
    Aiming = false,
    CurrentTarget = nil,
    StickyLostTime = 0,
}

function Combat.SetConfig(config)
    Combat.Config = config
end

function Combat.SetTargeting(targeting)
    Combat.Targeting = targeting
end

function Combat.SetVisuals(visuals)
    Combat.Visuals = visuals
end

-- ═════════════════════════════════════════════════════════════════════════════
-- AIMBOT
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
    if player == LocalPlayer then return true end
    if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then return true end
    if LocalPlayer.TeamColor and player.TeamColor and LocalPlayer.TeamColor == player.TeamColor then return true end
    return false
end

local function GetDistance(position)
    return (position - Camera.CFrame.Position).Magnitude
end

local function GetTargetPart(character, partName)
    return character:FindFirstChild(partName)
        or character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")
end

local function GetFOVRadiusPixels()
    local Config = Combat.Config
    local fovAngle = math.rad((Config.Aimbot_FOV or 60) / 2)
    local camFov = math.rad(Camera.FieldOfView / 2)
    if camFov <= 0 then return 9999 end
    local radius = math.tan(fovAngle) / math.tan(camFov) * (Camera.ViewportSize.Y / 2)
    return math.min(radius, Camera.ViewportSize.Y * 0.8)
end

local function IsInFOV(targetPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if not onScreen then return false, math.huge end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
    return distFromCenter <= GetFOVRadiusPixels(), distFromCenter
end

local function CanSee(targetPos, targetCharacter)
    local Config = Combat.Config
    if not Config.Aimbot_WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPos - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(origin, direction, raycastParams)
    if not result then return true end
    local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
    return hitModel and hitModel == targetCharacter
end

local function IsTargetValidSticky(target)
    if not target then return false end
    if not target.Player or not target.Character then return false end
    if not IsAlive(target.Character) then return false end
    local Config = Combat.Config
    if Config.Aimbot_TeamCheck and IsTeammate(target.Player) then return false end
    local part = target.Character:FindFirstChild(target.Part.Name)
    if not part then return false end
    local dist = GetDistance(part.Position)
    if dist > (Config.Aimbot_MaxDistance or 1000) then return false end
    return true
end

local function IsTargetValidStrict(target)
    if not IsTargetValidSticky(target) then return false end
    local part = target.Character:FindFirstChild(target.Part.Name)
    if not part then return false end
    local inFOV = IsInFOV(part.Position)
    if not inFOV then return false end
    if not CanSee(part.Position, target.Character) then return false end
    return true
end

local function GetBestTarget()
    local Config = Combat.Config
    if not Config.Aimbot_Enabled then return nil end

    -- Sticky target: keep following current target briefly if they go out of FOV
    if Config.Aimbot_StickyTarget and Combat.CurrentTarget and Combat.Aiming then
        if IsTargetValidSticky(Combat.CurrentTarget) then
            local part = Combat.CurrentTarget.Character:FindFirstChild(Combat.CurrentTarget.Part.Name)
            if part then
                if IsTargetValidStrict(Combat.CurrentTarget) then
                    Combat.StickyLostTime = 0
                    Combat.CurrentTarget.Part = part
                    Combat.CurrentTarget.Position = part.Position
                    return Combat.CurrentTarget
                else
                    -- Briefly out of FOV/distance, grace period
                    if Combat.StickyLostTime == 0 then
                        Combat.StickyLostTime = tick()
                    elseif tick() - Combat.StickyLostTime < 0.6 then
                        Combat.CurrentTarget.Part = part
                        Combat.CurrentTarget.Position = part.Position
                        return Combat.CurrentTarget
                    end
                end
            end
        end
        Combat.CurrentTarget = nil
        Combat.StickyLostTime = 0
    end

    local bestTarget = nil
    local bestScore = math.huge
    local targetPartName = Config.Aimbot_TargetPart or "Head"
    local maxDist = Config.Aimbot_MaxDistance or 1000
    local priority = Config.Aimbot_Priority or "Closest to Mouse"

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.Aimbot_TeamCheck and IsTeammate(player) then continue end

        local character = GetCharacter(player)
        if not character or not IsAlive(character) then continue end

        local targetPart = GetTargetPart(character, targetPartName)
        if not targetPart then continue end

        local targetPos = targetPart.Position
        local dist = GetDistance(targetPos)
        if dist > maxDist then continue end

        local inFOV, fovDist = IsInFOV(targetPos)
        if not inFOV then continue end

        if not CanSee(targetPos, character) then continue end

        local score = math.huge
        local hum = GetHumanoid(character)

        if priority == "Closest to Mouse" then
            score = fovDist
        elseif priority == "Closest to Player" then
            score = dist
        elseif priority == "Lowest HP" then
            score = (hum and hum.Health or 100) + (fovDist * 0.1)
        elseif priority == "Highest HP" then
            score = -(hum and hum.Health or 100) + (fovDist * 0.1)
        else
            score = fovDist + (dist * 0.02)
        end

        if score < bestScore then
            bestScore = score
            bestTarget = {
                Player = player,
                Character = character,
                Part = targetPart,
                Position = targetPos,
                Distance = dist,
            }
        end
    end
    return bestTarget
end

local function AimAt(target)
    if not target or not target.Part then return end
    local Config = Combat.Config
    local smoothness = Config.Aimbot_Smoothness or 15
    local aimPos = target.Part.Position
    local targetCF = CFrame.new(Camera.CFrame.Position, aimPos)

    if smoothness <= 0 then
        Camera.CFrame = targetCF
    else
        local alpha = math.clamp(math.exp(-smoothness * 0.045), 0.002, 1)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
    end
end

local function UpdateFOVCircle()
    local Config = Combat.Config
    if not Combat.FOVCircle then return end
    if Config.Aimbot_Enabled and (Config.Aimbot_ShowFOV ~= false) then
        local radius = GetFOVRadiusPixels()
        Combat.FOVCircle.Visible = true
        Combat.FOVCircle.Radius = radius
        Combat.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        Combat.FOVCircle.Color = Config.Aimbot_FOVColor or Color3.fromRGB(255, 105, 180)
    else
        Combat.FOVCircle.Visible = false
    end
end

local function UpdateTargetCircle()
    if not Combat.TargetCircle then return end
    if Combat.CurrentTarget and Combat.CurrentTarget.Part then
        local screenPos, onScreen = Camera:WorldToViewportPoint(Combat.CurrentTarget.Part.Position)
        if onScreen then
            Combat.TargetCircle.Visible = true
            Combat.TargetCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
        else
            Combat.TargetCircle.Visible = false
        end
    else
        Combat.TargetCircle.Visible = false
    end
end

local function OnAimbotRender()
    local Config = Combat.Config
    if not Config.Aimbot_Enabled then
        Combat.CurrentTarget = nil
        Combat.StickyLostTime = 0
        if Combat.FOVCircle then Combat.FOVCircle.Visible = false end
        if Combat.TargetCircle then Combat.TargetCircle.Visible = false end
        return
    end

    local target = GetBestTarget()
    Combat.CurrentTarget = target

    if target and Combat.Aiming then
        AimAt(target)
    end

    UpdateFOVCircle()
    UpdateTargetCircle()
end

local function StartAimbot()
    if Combat.AimbotConnection then return end
    Combat.FOVCircle = Drawing.new("Circle")
    Combat.FOVCircle.Visible = false
    Combat.FOVCircle.Thickness = 1.5
    Combat.FOVCircle.Color = Combat.Config.Aimbot_FOVColor or Color3.fromRGB(255, 105, 180)
    Combat.FOVCircle.Transparency = 0.5
    Combat.FOVCircle.NumSides = 64
    Combat.FOVCircle.Filled = false

    Combat.TargetCircle = Drawing.new("Circle")
    Combat.TargetCircle.Visible = false
    Combat.TargetCircle.Thickness = 2
    Combat.TargetCircle.Color = Color3.fromRGB(255, 0, 255)
    Combat.TargetCircle.Transparency = 0.7
    Combat.TargetCircle.NumSides = 32
    Combat.TargetCircle.Filled = false
    Combat.TargetCircle.Radius = 8

    Combat.AimbotConnection = RunService.RenderStepped:Connect(OnAimbotRender)
end

local function StopAimbot()
    Combat.Aiming = false
    Combat.CurrentTarget = nil
    Combat.StickyLostTime = 0
    if Combat.AimbotConnection then
        Combat.AimbotConnection:Disconnect()
        Combat.AimbotConnection = nil
    end
    if Combat.FOVCircle then
        Combat.FOVCircle.Visible = false
        Combat.FOVCircle:Remove()
        Combat.FOVCircle = nil
    end
    if Combat.TargetCircle then
        Combat.TargetCircle.Visible = false
        Combat.TargetCircle:Remove()
        Combat.TargetCircle = nil
    end
end

-- Input handling for aimbot — supports both keyboard keys and mouse buttons
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local Config = Combat.Config
    if not Config or not Config.Aimbot_Enabled then return end
    local aimKey = Config.Aimbot_EnabledKey

    local matched = (input.KeyCode == aimKey) or (input.UserInputType == aimKey)
    if not matched then return end

    if Config.Aimbot_ToggleMode then
        Combat.Aiming = not Combat.Aiming
    else
        Combat.Aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    local Config = Combat.Config
    if not Config or not Config.Aimbot_Enabled then return end
    if Config.Aimbot_ToggleMode then return end -- toggle mode ignores release

    local aimKey = Config.Aimbot_EnabledKey
    local matched = (input.KeyCode == aimKey) or (input.UserInputType == aimKey)
    if not matched then return end

    Combat.Aiming = false
end)

-- ═════════════════════════════════════════════════════════════════════════════
-- EXISTING COMBAT FEATURES
-- ═════════════════════════════════════════════════════════════════════════════

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
    local Config = Combat.Config
    local Targeting = Combat.Targeting
    local Visuals = Combat.Visuals

    if not Config or not Targeting or not Visuals then
        tool:Activate()
        return
    end

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

-- ═════════════════════════════════════════════════════════════════════════════
-- LIFECYCLE
-- ═════════════════════════════════════════════════════════════════════════════

function Combat.Init()
    StartAimbot()
end

function Combat.Cleanup()
    StopAimbot()
end

return Combat