local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

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
    CachedPrompt = nil,
    NotificationGui = nil,
}

--// ==================== NOTIFICATIONS ====================
function Misc.Notify(text, color)
    color = color or Color3.fromRGB(100, 200, 150)
    
    if not Misc.NotificationGui then
        local sg = Instance.new("ScreenGui")
        sg.Name = "ENINotifications"
        sg.ResetOnSpawn = false
        sg.Parent = game.CoreGui
        Misc.NotificationGui = sg
    end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 36)
    frame.Position = UDim2.new(0.5, -140, 0, -40)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = Misc.NotificationGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(235, 235, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    --// Slide in
    frame:TweenPosition(UDim2.new(0.5, -140, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    
    --// Fade out and destroy
    task.delay(2.5, function()
        frame:TweenPosition(UDim2.new(0.5, -140, 0, -40), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
        task.wait(0.35)
        if frame then frame:Destroy() end
    end)
end

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
    Misc.CachedClickDetector = nil
    Misc.CachedPrompt = nil
    
    if not Misc.Config or not Misc.Config.AutoArmorPos then return end
    local pos = Misc.Config.AutoArmorPos
    
    --// Search for ClickDetector
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ClickDetector") and obj.Parent and obj.Parent:IsA("BasePart") then
            if (obj.Parent.Position - pos).Magnitude < 8 then
                Misc.CachedClickDetector = obj
                print("[ENI] Cached ClickDetector for armor")
                return
            end
        end
    end
    
    --// Search for ProximityPrompt
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent:IsA("BasePart") then
            if (obj.Parent.Position - pos).Magnitude < 8 then
                Misc.CachedPrompt = obj
                print("[ENI] Cached ProximityPrompt for armor")
                return
            end
        end
    end
    
    print("[ENI] No click detector or prompt found near armor position")
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
        
        local threshold = Misc.Config.AntiStompThreshold or 50
        
        --// AntiStomp: health drops BELOW threshold = instant death
        if Misc.Config and Misc.Config.AntiStomp and not Misc.AntiStompTriggered then
            if newHealth <= threshold then
                Misc.TriggerAntiStomp()
            end
        end
        
        --// AutoArmor: ANY damage = grab armor instantly
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

    local threshold = Misc.Config.AntiStompThreshold or 50
    local currentHealth = humanoid.Health

    --// Trigger: health below threshold
    if currentHealth > 0 and currentHealth <= threshold then
        Misc.TriggerAntiStomp()
        return
    end

    --// Fallback: Da Hood "Knocked" value
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
    if not Misc.Config.AutoArmorPos then 
        Misc.Notify("Armor position not set!", Color3.fromRGB(200, 60, 60))
        return 
    end
    
    local now = tick()
    local cooldown = Misc.Config.AutoArmorCooldown or 1
    if (now - Misc.LastArmorTime) < cooldown then return end
    
    local hrp = Misc.GetLiveHRP()
    if not hrp then return end
    
    Misc.LastArmorTime = now
    
    --// Pause spam briefly so we dont get teleported away
    local wasSpamming = Misc.Config.SpamEnabled
    if wasSpamming then
        Misc.StopSpam()
    end
    
    local origCF = hrp.CFrame
    local armorPos = Misc.Config.AutoArmorPos
    local cam = Workspace.CurrentCamera
    local origCam = cam.CFrame
    
    --// Teleport to armor position
    hrp.CFrame = CFrame.new(armorPos + Vector3.new(0, 2, 0))
    
    --// Look down at the button
    cam.CFrame = CFrame.new(armorPos + Vector3.new(0, 2, 0), armorPos)
    
    --// One frame for server to register position
    RunService.Heartbeat:Wait()
    
    local clicked = false
    
    --// Method 1: Executor native fireclickdetector
    if Misc.CachedClickDetector and fireclickdetector then
        local ok = pcall(function() fireclickdetector(Misc.CachedClickDetector) end)
        if ok then clicked = true end
    end
    
    --// Method 2: ProximityPrompt
    if not clicked and Misc.CachedPrompt then
        local ok = pcall(function() 
            Misc.CachedPrompt:InputHoldBegin()
            task.wait(0.1)
            Misc.CachedPrompt:InputHoldEnd()
        end)
        if ok then clicked = true end
    end
    
    --// Method 3: VirtualInputManager click at screen center
    if not clicked then
        local vim = game:GetService("VirtualInputManager")
        local screenSize = cam.ViewportSize
        vim:SendMouseButtonEvent(screenSize.X/2, screenSize.Y/2, 0, true, game, 1)
        task.wait(0.05)
        vim:SendMouseButtonEvent(screenSize.X/2, screenSize.Y/2, 0, false, game, 1)
        clicked = true
    end
    
    --// Notification
    if clicked then
        Misc.Notify("Armor grabbed!", Color3.fromRGB(100, 200, 150))
    else
        Misc.Notify("Failed to grab armor", Color3.fromRGB(200, 60, 60))
    end
    
    --// Snap back
    hrp.CFrame = origCF
    cam.CFrame = origCam
    
    --// Resume spam if it was on
    if wasSpamming then
        Misc.StartSpam()
    end
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