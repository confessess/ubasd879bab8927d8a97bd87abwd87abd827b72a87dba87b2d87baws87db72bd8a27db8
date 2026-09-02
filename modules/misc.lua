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
    LastArmorTime = 0,
    CachedClickDetector = nil,
}

function Misc.SetConfig(config)
    Misc.Config = config
    Misc.CacheArmorClickDetector()
end

function Misc.RefreshCharacter()
    Misc.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Misc.Humanoid = Misc.Character:WaitForChild("Humanoid")
    Misc.HRP = Misc.Character:WaitForChild("HumanoidRootPart")
    Misc.LastHealth = Misc.Humanoid.Health
    Misc.AntiStompTriggered = false
    Misc.SetupAntiStompHook()
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

--// ==================== CLICK DETECTOR CACHE ====================
function Misc.CacheArmorClickDetector()
    if not Misc.Config or not Misc.Config.AutoArmorPos then return end
    local pos = Misc.Config.AutoArmorPos
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ClickDetector") and obj.Parent and obj.Parent:IsA("BasePart") then
            if (obj.Parent.Position - pos).Magnitude < 5 then
                Misc.CachedClickDetector = obj
                return
            end
        end
    end
end

--// ==================== ANTI-STOMP ====================
function Misc.SetupAntiStompHook()
    local humanoid = Misc.GetLiveHumanoid()
    if not humanoid then return end
    
    humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth <= 0 then 
            Misc.LastHealth = newHealth
            return 
        end
        
        --// AntiStomp: any damage = instant death
        if Misc.Config and Misc.Config.AntiStomp and not Misc.AntiStompTriggered then
            if newHealth < Misc.LastHealth then
                Misc.TriggerAntiStomp()
            end
        end
        
        --// AutoArmor: any damage = grab armor instantly
        if Misc.Config and Misc.Config.AutoArmor and Misc.Config.AutoArmorOnDamage then
            if newHealth < Misc.LastHealth then
                Misc.AutoArmorFast()
            end
        end
        
        Misc.LastHealth = newHealth
    end)
end

function Misc.TriggerAntiStomp()
    if not Misc.Config or not Misc.Config.AntiStomp then return end
    if Misc.AntiStompTriggered then return end
    Misc.AntiStompTriggered = true

    local char = LocalPlayer.Character
    local humanoid = Misc.GetLiveHumanoid()
    local hrp = Misc.GetLiveHRP()

    if Misc.Config.AntiStompMode == "Void" then
        if hrp then
            hrp.CFrame = CFrame.new(0, -50000, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        if humanoid then
            humanoid.Health = 0
        end
        if char then
            pcall(function() char:BreakJoints() end)
        end
        pcall(function() LocalPlayer:LoadCharacter() end)

    elseif Misc.Config.AntiStompMode == "Force Reset" then
        pcall(function() LocalPlayer:LoadCharacter() end)
    end
end

--// Fallback heartbeat
function Misc.CheckAntiStomp()
    if not Misc.Config or not Misc.Config.AntiStomp then
        Misc.AntiStompTriggered = false
        return
    end
    if Misc.AntiStompTriggered then return end

    local humanoid = Misc.GetLiveHumanoid()
    if not humanoid then return end

    local currentHealth = humanoid.Health

    if Misc.LastHealth and currentHealth < Misc.LastHealth and currentHealth > 0 then
        Misc.TriggerAntiStomp()
        return
    end

    local char = LocalPlayer.Character
    if char then
        local knocked = char:FindFirstChild("Knocked")
        if knocked and (knocked:IsA("BoolValue") and knocked.Value == true or knocked:IsA("NumberValue") and knocked.Value > 0) then
            Misc.TriggerAntiStomp()
            return
        end
    end

    Misc.LastHealth = currentHealth
end

--// ==================== AUTO ARMOR (FAST) ====================
function Misc.AutoArmorFast()
    if not Misc.Config or not Misc.Config.AutoArmor then return end
    if not Misc.Config.AutoArmorPos then return end
    
    local now = tick()
    local cooldown = Misc.Config.AutoArmorCooldown or 1
    if (now - Misc.LastArmorTime) < cooldown then return end
    
    local hrp = Misc.GetLiveHRP()
    if not hrp then return end
    
    Misc.LastArmorTime = now
    
    local origCF = hrp.CFrame
    local armorPos = Misc.Config.AutoArmorPos
    
    --// Teleport to armor position
    hrp.CFrame = CFrame.new(armorPos + Vector3.new(0, 2, 0))
    
    --// One frame for server to register position
    RunService.Heartbeat:Wait()
    
    --// Click the detector
    if Misc.CachedClickDetector then
        --// Try executor native function first (bypasses distance checks)
        if fireclickdetector then
            pcall(function() fireclickdetector(Misc.CachedClickDetector) end)
        else
            pcall(function() Misc.CachedClickDetector:FireServer() end)
        end
    end
    
    --// INSTANT snap back — no extra waits
    hrp.CFrame = origCF
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
    
    --// Auto Armor (threshold mode — only when OnDamage is OFF)
    if Misc.Config and Misc.Config.AutoArmor and not Misc.Config.AutoArmorOnDamage then
        local humanoid = Misc.GetLiveHumanoid()
        if humanoid then
            local triggerHealth = Misc.Config.AutoArmorTriggerHealth or 50
            if humanoid.Health < triggerHealth and humanoid.Health > 0 then
                Misc.AutoArmorFast()
            end
        end
    end
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