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
    FlyInstances = {},
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

function Movement.SetSpeedEnabled(enabled)
    if Movement.Config then
        Movement.Config.Move_SpeedEnabled = enabled
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

function Movement.SetHighJumpEnabled(enabled)
    if Movement.Config then
        Movement.Config.Move_HighJumpEnabled = enabled
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- BUNNY HOP
-- ═════════════════════════════════════════════════════════════════════════════

local LastBhopJump = 0

local LastNoJumpCD = 0

local function DoNoJumpCooldown()
    local Config = Movement.Config
    if not Config.Move_NoJumpCooldown then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    if hum.Health <= 0 then return end

    -- Method 1: Force Running state every frame (prevents Landed state)
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Freefall then
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end

    -- Method 2: Set JumpPower every frame (resets internal cooldown)
    local currentJP = hum.JumpPower
    hum.JumpPower = currentJP

    -- Method 3: Look for and reset any cooldown values in character
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("NumberValue") then
            local name = obj.Name:lower()
            if name:find("jump") and name:find("cool") or name:find("cd") or name:find("delay") then
                obj.Value = 0
            end
        end
    end

    -- Method 4: Look in Humanoid for cooldown
    for _, obj in pairs(hum:GetDescendants()) do
        if obj:IsA("NumberValue") then
            local name = obj.Name:lower()
            if name:find("jump") or name:find("cool") or name:find("cd") then
                obj.Value = 0
            end
        end
    end
end

local function ForceJump()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    if hum.Health <= 0 then return end

    -- Check if on ground
    if hum.FloorMaterial == Enum.Material.Air then return end

    -- Method 1: Direct velocity impulse (always works)
    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, hum.JumpPower, root.AssemblyLinearVelocity.Z)

    -- Method 2: Also try state change as backup
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end

local function DoBunnyHop()
    local Config = Movement.Config
    if not Config.Move_BunnyHop then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    if hum.Health <= 0 then return end

    -- Check if moving (WASD pressed)
    local isMoving = UserInputService:IsKeyDown(Enum.KeyCode.W) 
        or UserInputService:IsKeyDown(Enum.KeyCode.A)
        or UserInputService:IsKeyDown(Enum.KeyCode.S)
        or UserInputService:IsKeyDown(Enum.KeyCode.D)

    if not isMoving then return end

    -- Auto jump when on ground — use velocity impulse (bypasses cooldown)
    if hum.FloorMaterial ~= Enum.Material.Air then
        local now = tick()
        if now - LastBhopJump > 0.05 then
            ForceJump()
            LastBhopJump = now
        end
    end

    -- Speed boost while bunny hopping
    local currentSpeed = hum.WalkSpeed
    local bhopSpeed = (Config.Move_Speed or 50) * 1.2 -- 20% faster than normal speed
    if currentSpeed < bhopSpeed then
        hum.WalkSpeed = bhopSpeed
    end
end

function Movement.SetNoJumpCooldown(enabled)
    if Movement.Config then
        Movement.Config.Move_NoJumpCooldown = enabled
    end
end

function Movement.SetBunnyHop(enabled)
    if Movement.Config then
        Movement.Config.Move_BunnyHop = enabled
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

function Movement.SetInfiniteJump(enabled)
    if Movement.Config then
        Movement.Config.Move_InfiniteJump = enabled
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- NOCLIP
-- ═════════════════════════════════════════════════════════════════════════════

local NoClipModifiedParts = {}

local function DoNoClip()
    local Config = Movement.Config
    if not Config.Move_NoClip then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not NoClipModifiedParts[part] then
            NoClipModifiedParts[part] = part.CanCollide
            part.CanCollide = false
        end
    end
end

local function ResetNoClip()
    for part, originalCanCollide in pairs(NoClipModifiedParts) do
        if part and part.Parent then
            part.CanCollide = originalCanCollide
        end
    end
    NoClipModifiedParts = {}
end

function Movement.SetNoClip(enabled)
    if Movement.Config then
        Movement.Config.Move_NoClip = enabled
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

-- ── Method 1: Tween ──
local function StartFly_Tween()
    if Movement.State.Flying then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
        hum.AutoRotate = false
    end
    Movement.State.Flying = true
end

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
    root.Velocity = Vector3.new(0, 0, 0)
    root.RotVelocity = Vector3.new(0, 0, 0)
end

local function StopFly_Tween()
    if not Movement.State.Flying then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
    end
    Movement.State.Flying = false
end

-- ── Method 2: Velocity ──
local function StartFly_Velocity()
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

local function StopFly_Velocity()
    if not Movement.State.Flying then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
    end
    Movement.State.Flying = false
end

-- ── Method 3: CFrame ──
local function StartFly_CFrame()
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
    root.Velocity = Vector3.new(0, 0, 0)
    root.RotVelocity = Vector3.new(0, 0, 0)
end

local function StopFly_CFrame()
    if not Movement.State.Flying then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
    end
    Movement.State.Flying = false
end

-- ═════════════════════════════════════════════════════════════════════════════
-- FLY dispatcher
-- ═════════════════════════════════════════════════════════════════════════════

local function StartFly()
    local Config = Movement.Config
    if Config.Move_FlyMethod == "Tween" then StartFly_Tween()
    elseif Config.Move_FlyMethod == "Velocity" then StartFly_Velocity()
    elseif Config.Move_FlyMethod == "CFrame" then StartFly_CFrame() end
end

local function DoFly()
    local Config = Movement.Config
    if not Config.Move_Fly then return end
    if Config.Move_FlyMethod == "Tween" then DoFly_Tween()
    elseif Config.Move_FlyMethod == "Velocity" then DoFly_Velocity()
    elseif Config.Move_FlyMethod == "CFrame" then DoFly_CFrame() end
end

local function StopFly()
    local Config = Movement.Config
    if Config.Move_FlyMethod == "Tween" then StopFly_Tween()
    elseif Config.Move_FlyMethod == "Velocity" then StopFly_Velocity()
    elseif Config.Move_FlyMethod == "CFrame" then StopFly_CFrame() end
end

function Movement.SetFly(enabled)
    if Movement.Config then
        Movement.Config.Move_Fly = enabled
        if enabled then
            StartFly()
        else
            StopFly()
        end
    end
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
    DoNoJumpCooldown()
    DoInfiniteJump()
    if Config.Move_Fly then
        DoFly()
    elseif Movement.State.Flying then
        StopFly()
    end

    if Config.Move_NoClip then
        DoNoClip()
    else
        ResetNoClip()
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