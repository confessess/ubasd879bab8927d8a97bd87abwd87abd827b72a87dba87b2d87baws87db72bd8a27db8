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
    CachedTouchPart = nil,
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
    
    frame:TweenPosition(UDim2.new(0.5, -140, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    
    task.delay(2.5, function()
        frame:TweenPosition(UDim2.new(0.5, -140, 0, -40), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
        task.wait(0.35)
        if frame then frame:Destroy() end
    end)
end

function Misc.SetConfig(config)
    Misc.Config = config
    Misc.CacheArmorDetector()
end

function Misc.RefreshCharacter()
    Misc.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Misc.Humanoid = Misc.Character:WaitForChild("Humanoid")
    Misc.HRP = Misc.Character:WaitForChild("HumanoidRootPart")
    Misc.LastHealth = Misc.Humanoid.Health
    Misc.AntiStompTriggered = false
    Misc.SetupAntiStompHook()
end

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

--// ==================== ARMOR DETECTOR CACHE ====================
function Misc.CacheArmorDetector()
    Misc.CachedClickDetector = nil
    Misc.CachedPrompt = nil
    Misc.CachedTouchPart = nil
    
    if not Misc.Config or not Misc.Config.AutoArmorPos then return end
    local pos = Misc.Config.AutoArmorPos
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if not obj.Parent or not obj.Parent:IsA("BasePart") then continue end
        local partPos = obj.Parent.Position
        if (partPos - pos).Magnitude > 15 then continue end
        
        if obj:IsA("ClickDetector") then
            Misc.CachedClickDetector = obj
            print("[ENI] Cached ClickDetector for armor at " .. tostring(partPos))
        elseif obj:IsA("ProximityPrompt") then
            Misc.CachedPrompt = obj
            print("[ENI] Cached ProximityPrompt for armor at " .. tostring(partPos))
        elseif obj:IsA("TouchInterest") then
            Misc.CachedTouchPart = obj.Parent
            print("[ENI] Cached TouchInterest for armor at " .. tostring(partPos))
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
        
        local threshold = Misc.Config.AntiStompThreshold or 50
        
        if Misc.Config and Misc.Config.AntiStomp and not Misc.AntiStompTriggered then
            if newHealth <= threshold then
                Misc.TriggerAntiStomp()
            end
        end
        
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

    if currentHealth > 0 and currentHealth <= threshold then
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

--// ==================== AUTO ARMOR (ROBUST) ====================
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
    
    --// Pause spam
    local wasSpamming = Misc.Config.SpamEnabled
    if wasSpamming then
        Misc.StopSpam()
    end
    
    local origCF = hrp.CFrame
    local armorPos = Misc.Config.AutoArmorPos
    local cam = Workspace.CurrentCamera
    local origCam = cam.CFrame
    
    task.spawn(function()
        --// Teleport DIRECTLY onto the button
        hrp.CFrame = CFrame.new(armorPos)
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        
        --// Look at the button
        cam.CFrame = CFrame.new(armorPos + Vector3.new(0, 3, 0), armorPos)
        
        --// Wait for server to register position (CRITICAL — 5 heartbeats)
        for i = 1, 5 do
            RunService.Heartbeat:Wait()
        end
        
        local success = false
        
        --// Method 1: fireclickdetector (executor native)
        if not success and Misc.CachedClickDetector then
            if fireclickdetector then
                for i = 1, 3 do
                    pcall(function() fireclickdetector(Misc.CachedClickDetector, 0) end)
                    RunService.Heartbeat:Wait()
                end
                success = true
            else
                --// Fallback: Fire the event directly
                for i = 1, 3 do
                    pcall(function() Misc.CachedClickDetector.MouseClick:Fire() end)
                    RunService.Heartbeat:Wait()
                end
                success = true
            end
        end
        
        --// Method 2: ProximityPrompt
        if not success and Misc.CachedPrompt then
            if fireproximityprompt then
                pcall(function() fireproximityprompt(Misc.CachedPrompt) end)
                success = true
            else
                pcall(function()
                    Misc.CachedPrompt:InputHoldBegin()
                    RunService.Heartbeat:Wait()
                    Misc.CachedPrompt:InputHoldEnd()
                end)
                success = true
            end
        end
        
        --// Method 3: TouchInterest (walk into the part)
        if not success and Misc.CachedTouchPart then
            pcall(function()
                local touchPart = Misc.CachedTouchPart
                if touchPart.Touched then
                    touchPart.Touched:Fire(hrp)
                end
            end)
            success = true
        end
        
        --// Method 4: VirtualInputManager (last resort)
        if not success then
            local vim = game:GetService("VirtualInputManager")
            local screenSize = cam.ViewportSize
            for i = 1, 3 do
                vim:SendMouseButtonEvent(screenSize.X/2, screenSize.Y/2, 0, true, game, 1)
                RunService.Heartbeat:Wait()
                vim:SendMouseButtonEvent(screenSize.X/2, screenSize.Y/2, 0, false, game, 1)
                RunService.Heartbeat:Wait()
            end
            success = true
        end
        
        --// Wait for server to process
        for i = 1, 3 do
            RunService.Heartbeat:Wait()
        end
        
        --// Notification
        if success then
            Misc.Notify("Armor grabbed!", Color3.fromRGB(100, 200, 150))
        else
            Misc.Notify("Failed to grab armor", Color3.fromRGB(200, 60, 60))
        end
        
        --// Snap back
        hrp.CFrame = origCF
        hrp.Velocity = Vector3.new(0, 0, 0)
        cam.CFrame = origCam
        
        --// Resume spam
        if wasSpamming then
            Misc.StartSpam()
        end
    end)
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