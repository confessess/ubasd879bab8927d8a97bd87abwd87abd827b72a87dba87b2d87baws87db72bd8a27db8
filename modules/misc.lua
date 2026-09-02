local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

math.randomseed(tick())

local Misc = {
    Config = nil,
    SpamConnection = nil,
    Character = nil,
    Humanoid = nil,
    HRP = nil,
    LastHealth = 100,
    AntiStompTriggered = false,
}

function Misc.SetConfig(config)
    Misc.Config = config
end

function Misc.RefreshCharacter()
    Misc.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Misc.Humanoid = Misc.Character:WaitForChild("Humanoid")
    Misc.HRP = Misc.Character:WaitForChild("HumanoidRootPart")
    Misc.LastHealth = Misc.Humanoid.Health
    Misc.AntiStompTriggered = false
end

--// ==================== LIVE REFS ====================
function Misc.GetLiveHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

function Misc.GetLiveHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

--// ==================== ANTI-STOMP ====================
function Misc.TriggerAntiStomp()
    if not Misc.Config or not Misc.Config.AntiStomp then return end
    if Misc.AntiStompTriggered then return end
    Misc.AntiStompTriggered = true

    local char = LocalPlayer.Character
    local humanoid = Misc.GetLiveHumanoid()
    local hrp = Misc.GetLiveHRP()

    if Misc.Config.AntiStompMode == "Void" then
        --// Teleport deep underground and die instantly
        if hrp then
            hrp.CFrame = CFrame.new(0, -50000, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        task.wait(0.05)
        --// Force death after teleport
        if humanoid then
            humanoid.Health = 0
        end
        --// Break joints as backup
        if char then
            pcall(function() char:BreakJoints() end)
        end

    elseif Misc.Config.AntiStompMode == "Force Reset" then
        --// Instant respawn — bypass death animation entirely
        pcall(function() LocalPlayer:LoadCharacter() end)
    end
end

function Misc.CheckAntiStomp()
    if not Misc.Config or not Misc.Config.AntiStomp then
        Misc.AntiStompTriggered = false
        return
    end

    local humanoid = Misc.GetLiveHumanoid()
    if not humanoid then return end

    local threshold = Misc.Config.AntiStompThreshold or 15
    local currentHealth = humanoid.Health

    --// Trigger 1: Health dropped below threshold (knocked)
    if currentHealth <= threshold and currentHealth > 0 then
        Misc.TriggerAntiStomp()
        return
    end

    --// Trigger 2: Health dropped hard in one frame (heavy damage)
    if Misc.LastHealth and currentHealth < Misc.LastHealth - 25 then
        Misc.TriggerAntiStomp()
        return
    end

    --// Trigger 3: Da Hood "Knocked" value check
    local char = LocalPlayer.Character
    if char then
        local knocked = char:FindFirstChild("Knocked")
        if knocked and (knocked:IsA("BoolValue") and knocked.Value == true or knocked:IsA("NumberValue") and knocked.Value > 0) then
            Misc.TriggerAntiStomp()
            return
        end
    end

    --// Trigger 4: Ragdoll / physics state
    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Physics or
       state == Enum.HumanoidStateType.GettingUp or
       state == Enum.HumanoidStateType.PlatformStanding then
        Misc.TriggerAntiStomp()
        return
    end

    --// Trigger 5: Someone is standing on you while low health
    if currentHealth <= threshold + 15 then
        local hrp = Misc.GetLiveHRP()
        if hrp then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local theirHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    if theirHRP then
                        local dist = (hrp.Position - theirHRP.Position).Magnitude
                        if dist < 6 then
                            Misc.TriggerAntiStomp()
                            return
                        end
                    end
                end
            end
        end
    end

    Misc.LastHealth = currentHealth
end

--// ==================== TELEPORT SPAM ====================
function Misc.TeleportSpam()
    if not Misc.HRP or not Misc.HRP.Parent then return end
    if not Misc.Config or not Misc.Config.SpamEnabled then return end

    local Config = Misc.Config
    local speed = math.clamp(Config.SpamSpeed or 1, 1, 10)

    for i = 1, speed do
        if Config.SpamRange == "Close" then
            local newPos = Vector3.new(
                math.random(-Config.SpamCloseRadius, Config.SpamCloseRadius),
                Config.SpamCloseHeight + math.random(-Config.SpamCloseVerticalJitter, Config.SpamCloseVerticalJitter),
                math.random(-Config.SpamCloseRadius, Config.SpamCloseRadius)
            )
            Misc.HRP.CFrame = CFrame.new(newPos)
        else
            local base = Config.SpamFarBase or Vector3.new(500000, 500000, 500000)
            local jitter = Config.SpamFarJitter or 5000
            local newPos = base + Vector3.new(
                math.random(-jitter, jitter),
                math.random(-jitter, jitter),
                math.random(-jitter, jitter)
            )
            Misc.HRP.CFrame = CFrame.new(newPos)
        end
    end
end

function Misc.StartSpam()
    if Misc.SpamConnection then Misc.SpamConnection:Disconnect() end
    Misc.SpamConnection = RunService.RenderStepped:Connect(Misc.TeleportSpam)
end

function Misc.StopSpam()
    if Misc.SpamConnection then
        Misc.SpamConnection:Disconnect()
        Misc.SpamConnection = nil
    end
end

function Misc.ToggleSpam(enabled)
    if not Misc.Config then return end
    Misc.Config.SpamEnabled = enabled
    if enabled then
        Misc.StartSpam()
    else
        Misc.StopSpam()
    end
end

--// ==================== MAIN LOOP ====================
function Misc.OnHeartbeat()
    Misc.CheckAntiStomp()
end

function Misc.Start()
    RunService.Heartbeat:Connect(Misc.OnHeartbeat)
    if Misc.Config and Misc.Config.SpamEnabled then
        Misc.StartSpam()
    end
end

function Misc.Reset()
    Misc.StopSpam()
    Misc.AntiStompTriggered = false
    Misc.LastHealth = 100
    Misc.RefreshCharacter()
    if Misc.Config and Misc.Config.SpamEnabled then
        Misc.StartSpam()
    end
end

--// ==================== INIT ====================
Misc.RefreshCharacter()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    Misc.RefreshCharacter()
    Misc.Reset()
end)

return Misc