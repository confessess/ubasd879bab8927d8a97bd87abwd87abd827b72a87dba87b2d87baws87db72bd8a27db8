local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Movement = {
    Config = nil,
    Connection = nil,
    OriginalValues = {},
    State = {
        Flying = false,
        NoClipping = false,
    },
}

function Movement.SetConfig(config)
    Movement.Config = config
end

-- ═════════════════════════════════════════════════════════════════════════════
-- SPEED
-- ═════════════════════════════════════════════════════════════════════════════

local function DoSpeed()
    local Config = Movement.Config
    if not Config.Move_SpeedEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Movement.OriginalValues.WalkSpeed == nil then
        Movement.OriginalValues.WalkSpeed = hum.WalkSpeed
    end
    hum.WalkSpeed = Config.Move_Speed or 50
end

local function ResetSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Movement.OriginalValues.WalkSpeed ~= nil then
        hum.WalkSpeed = Movement.OriginalValues.WalkSpeed
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- HIGH JUMP
-- ═════════════════════════════════════════════════════════════════════════════

local function DoHighJump()
    local Config = Movement.Config
    if not Config.Move_HighJumpEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Movement.OriginalValues.JumpPower == nil then
        Movement.OriginalValues.JumpPower = hum.JumpPower
    end
    hum.JumpPower = Config.Move_JumpPower or 100
end

local function ResetHighJump()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Movement.OriginalValues.JumpPower ~= nil then
        hum.JumpPower = Movement.OriginalValues.JumpPower
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- BUNNY HOP
-- ═════════════════════════════════════════════════════════════════════════════

local function DoBunnyHop()
    local Config = Movement.Config
    if not Config.Move_BunnyHop then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- INFINITE JUMP
-- ═════════════════════════════════════════════════════════════════════════════

local function DoInfiniteJump()
    local Config = Movement.Config
    if not Config.Move_InfiniteJump then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if hum.FloorMaterial == Enum.Material.Air then
            root.Velocity = Vector3.new(root.Velocity.X, Config.Move_JumpPower or 100, root.Velocity.Z)
        end
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- NOCLIP
-- ═════════════════════════════════════════════════════════════════════════════

local function DoNoClip()
    local Config = Movement.Config
    if not Config.Move_NoClip then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end

local function ResetNoClip()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- FLY — Input helper
-- ═════════════════════════════════════════════════════════════════════════════

local function GetFlyInput()
    local Config = Movement.Config
    local speed = Config.Move_FlySpeed or 50
    local move = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + (Camera.CFrame.LookVector * speed) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - (Camera.CFrame.LookVector * speed) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - (Camera.CFrame.RightVector * speed) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + (Camera.CFrame.RightVector * speed) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, speed, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, speed, 0) end
    return move
end

-- ── Method 1: Tween (most server-undetected) ──
local function DoFly_Tween()
    if not Movement.State.Flying then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local move = GetFlyInput()
    if move.Magnitude > 0 then
        local targetPos = root.Position + move * 0.016
        root.CFrame = CFrame.new(root.Position:Lerp(targetPos, 0.3))
    end
    -- Only zero velocity while actively moving to stay afloat
    root.Velocity = Vector3.new(0, 0.1, 0)
    root.RotVelocity = Vector3.new(0, 0, 0)
end

-- ── Method 2: Velocity (physics-based) ──
local function DoFly_Velocity()
    if not Movement.State.Flying then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local move = GetFlyInput()
    if move.Magnitude > 0 then
        root.AssemblyLinearVelocity = move
        root.RotVelocity = Vector3.new(0, 0, 0)
    else
        root.AssemblyLinearVelocity = Vector3.new(0, 0.1, 0)
        root.RotVelocity = Vector3.new(0, 0, 0)
    end
end

-- ── Method 3: CFrame (fastest) ──
local function DoFly_CFrame()
    if not Movement.State.Flying then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local move = GetFlyInput()
    if move.Magnitude > 0 then
        root.CFrame = root.CFrame + move * 0.016
    end
    root.Velocity = Vector3.new(0, 0.1, 0)
    root.RotVelocity = Vector3.new(0, 0, 0)
end

-- ═════════════════════════════════════════════════════════════════════════════
-- FLY dispatcher
-- ═════════════════════════════════════════════════════════════════════════════

local function StartFly()
    if Movement.State.Flying then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
        hum.AutoRotate = false
    end
    Movement.State.Flying = true
end

local function DoFly()
    local Config = Movement.Config
    if not Config.Move_Fly then return end
    if not Movement.State.Flying then return end
    local method = Config.Move_FlyMethod or "Tween"
    if method == "Tween" then DoFly_Tween()
    elseif method == "Velocity" then DoFly_Velocity()
    elseif method == "CFrame" then DoFly_CFrame() end
end

local function StopFly()
    if not Movement.State.Flying then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            -- Give a tiny upward nudge so the humanoid state machine wakes up
            root.Velocity = Vector3.new(root.Velocity.X, math.max(root.Velocity.Y, 2), root.Velocity.Z)
        end
    end
    Movement.State.Flying = false
end

-- ═════════════════════════════════════════════════════════════════════════════
-- RENDER LOOP
-- ═════════════════════════════════════════════════════════════════════════════

local function OnRender()
    local Config = Movement.Config
    if not Config then return end

    if Config.Move_SpeedEnabled then
        DoSpeed()
    else
        ResetSpeed()
    end

    if Config.Move_HighJumpEnabled then
        DoHighJump()
    else
        ResetHighJump()
    end

    DoBunnyHop()
    DoInfiniteJump()
    DoFly()

    if Config.Move_NoClip then
        DoNoClip()
        Movement.State.NoClipping = true
    elseif Movement.State.NoClipping then
        ResetNoClip()
        Movement.State.NoClipping = false
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- INPUT
-- ═════════════════════════════════════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local Config = Movement.Config
    if not Config then return end

    local flyKey = Config.Move_FlyKey or Enum.KeyCode.F
    local matched = (input.KeyCode == flyKey) or (input.UserInputType == flyKey)
    if matched and Config.Move_Fly then
        if Movement.State.Flying then StopFly() else StartFly() end
    end
end)

-- ═════════════════════════════════════════════════════════════════════════════
-- LIFECYCLE
-- ═════════════════════════════════════════════════════════════════════════════

function Movement.Init()
    if Movement.Connection then return end
    Movement.Connection = RunService.RenderStepped:Connect(OnRender)

    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        Movement.OriginalValues.WalkSpeed = nil
        Movement.OriginalValues.JumpPower = nil
        Movement.State.Flying = false
        Movement.State.NoClipping = false
    end)
end

function Movement.Cleanup()
    if Movement.Connection then
        Movement.Connection:Disconnect()
        Movement.Connection = nil
    end
    StopFly()
    ResetNoClip()
    ResetSpeed()
    ResetHighJump()
    Movement.OriginalValues = {}
end

return Movement