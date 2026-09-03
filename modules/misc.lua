local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

math.randomseed(tick())

local Misc = {
    Config = nil,
    SpamConnection = nil,
    HeartbeatConnection = nil,
    HealthChangedConnection = nil,
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
    AutoStompConnection = nil,
    AutoStompLastStomp = {},
    AutoStompMainRemote = nil,
}

--// ==================== NOTIFICATIONS ====================
function Misc.Notify(text, color)
    color = color or Color3.fromRGB(100, 200, 150)

    if not Misc.NotificationGui then
        local sg = Instance.new("ScreenGui")
        sg.Name = "StarsNotifications"
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
    Misc.EvaluateHealthHook()
    Misc.EvaluateHeartbeat()
end

function Misc.RefreshCharacter()
    Misc.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Misc.Humanoid = Misc.Character:WaitForChild("Humanoid")
    Misc.HRP = Misc.Character:WaitForChild("HumanoidRootPart")
    Misc.LastHealth = Misc.Humanoid.Health
    Misc.AntiStompTriggered = false
    Misc.EvaluateHealthHook()
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
        if not obj.Parent then continue end
        local parentPos = nil
        if obj.Parent:IsA("BasePart") then
            parentPos = obj.Parent.Position
        elseif obj.Parent:IsA("Model") and obj.Parent:FindFirstChild("HumanoidRootPart") then
            parentPos = obj.Parent.HumanoidRootPart.Position
        elseif obj.Parent:IsA("Model") and obj.Parent:FindFirstChild("Head") then
            parentPos = obj.Parent.Head.Position
        end

        if not parentPos then continue end
        if (parentPos - pos).Magnitude > 25 then continue end

        if obj:IsA("ClickDetector") then
            Misc.CachedClickDetector = obj
            print("[Stars] Cached ClickDetector for armor at " .. tostring(parentPos))
        elseif obj:IsA("ProximityPrompt") then
            Misc.CachedPrompt = obj
            print("[Stars] Cached ProximityPrompt for armor at " .. tostring(parentPos))
        elseif obj:IsA("TouchInterest") then
            Misc.CachedTouchPart = obj.Parent
            print("[Stars] Cached TouchInterest for armor at " .. tostring(parentPos))
        end
    end
end

--// ==================== ANTI-STOMP ====================
function Misc.EvaluateHealthHook()
    if Misc.HealthChangedConnection then
        Misc.HealthChangedConnection:Disconnect()
        Misc.HealthChangedConnection = nil
    end

    local humanoid = Misc.GetLiveHumanoid()
    if not humanoid then return end
    if not Misc.Config then return end

    local needHook = Misc.Config.AntiStomp or (Misc.Config.AutoArmor and Misc.Config.AutoArmorOnDamage)
    if not needHook then return end

    Misc.HealthChangedConnection = humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth <= 0 then 
            Misc.LastHealth = newHealth
            return 
        end

        local threshold = Misc.Config.AntiStompThreshold or 50

        if Misc.Config.AntiStomp and not Misc.AntiStompTriggered then
            if newHealth <= threshold then
                Misc.TriggerAntiStomp()
            end
        end

        if Misc.Config.AutoArmor and Misc.Config.AutoArmorOnDamage then
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
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        if humanoid then
            humanoid.Health = 0
        end
        if char then
            pcall(function() char:BreakJoints() end)
        end
        task.wait(0.05)
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
    local humanoid = Misc.GetLiveHumanoid()
    if not hrp or not humanoid then return end
    if humanoid.Health <= 0 then return end

    Misc.LastArmorTime = now

    local wasSpamming = Misc.Config.SpamEnabled
    if wasSpamming then
        Misc.StopSpam()
    end

    local origCF = hrp.CFrame
    local armorPos = Misc.Config.AutoArmorPos
    local cam = Workspace.CurrentCamera
    local origCam = cam.CFrame

    task.spawn(function()
        Misc.CacheArmorDetector()

        hrp.CFrame = CFrame.new(armorPos + Vector3.new(0, 4, 0))
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

        cam.CFrame = CFrame.new(armorPos + Vector3.new(0, 6, 5), armorPos)

        for i = 1, 10 do
            RunService.Heartbeat:Wait()
        end

        local success = false

        if not success then
            if Misc.CachedPrompt then
                pcall(function()
                    if fireproximityprompt then
                        fireproximityprompt(Misc.CachedPrompt)
                        success = true
                    else
                        Misc.CachedPrompt:InputHoldBegin()
                        task.wait(Misc.CachedPrompt.HoldDuration + 0.1)
                        Misc.CachedPrompt:InputHoldEnd()
                        success = true
                    end
                end)
            end

            if not success then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        local parent = obj.Parent
                        if parent and parent:IsA("BasePart") then
                            if (parent.Position - armorPos).Magnitude <= 20 then
                                pcall(function()
                                    if fireproximityprompt then
                                        fireproximityprompt(obj)
                                    else
                                        obj:InputHoldBegin()
                                        task.wait(obj.HoldDuration + 0.1)
                                        obj:InputHoldEnd()
                                    end
                                    success = true
                                end)
                                if success then break end
                            end
                        end
                    end
                end
            end
        end

        if not success then
            if Misc.CachedClickDetector then
                pcall(function()
                    if fireclickdetector then
                        fireclickdetector(Misc.CachedClickDetector)
                    else
                        Misc.CachedClickDetector.MouseClick:Fire()
                    end
                    success = true
                end)
            end

            if not success then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ClickDetector") then
                        local parent = obj.Parent
                        if parent and parent:IsA("BasePart") then
                            if (parent.Position - armorPos).Magnitude <= 20 then
                                pcall(function()
                                    if fireclickdetector then
                                        fireclickdetector(obj)
                                    else
                                        obj.MouseClick:Fire()
                                    end
                                    success = true
                                end)
                                if success then break end
                            end
                        end
                    end
                end
            end
        end

        if not success and Misc.CachedTouchPart then
            pcall(function()
                local touchPart = Misc.CachedTouchPart
                if touchPart.Touched then
                    touchPart.Touched:Fire(hrp)
                    success = true
                end
            end)
        end

        if not success then
            local vim = game:GetService("VirtualInputManager")
            local screenSize = cam.ViewportSize

            for i = 1, 3 do
                pcall(function()
                    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.1)
                    vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)
                RunService.Heartbeat:Wait()
            end

            for i = 1, 3 do
                pcall(function()
                    vim:SendMouseButtonEvent(screenSize.X/2, screenSize.Y/2, 0, true, game, 1)
                    task.wait(0.05)
                    vim:SendMouseButtonEvent(screenSize.X/2, screenSize.Y/2, 0, false, game, 1)
                end)
                RunService.Heartbeat:Wait()
            end
            success = true
        end

        for i = 1, 8 do
            RunService.Heartbeat:Wait()
        end

        local char = LocalPlayer.Character
        local gotArmor = false
        if char then
            local armorVal = char:FindFirstChild("Armor") or char:FindFirstChild("BodyArmor") or char:FindFirstChild("BulletProof")
            if not armorVal and humanoid then
                armorVal = humanoid:FindFirstChild("Armor") or humanoid:FindFirstChild("BodyArmor")
            end
            if armorVal then
                if armorVal:IsA("NumberValue") and armorVal.Value > 0 then
                    gotArmor = true
                elseif armorVal:IsA("IntValue") and armorVal.Value > 0 then
                    gotArmor = true
                end
            end
            local armorBool = char:FindFirstChild("HasArmor") or char:FindFirstChild("WearingArmor")
            if armorBool and armorBool:IsA("BoolValue") and armorBool.Value then
                gotArmor = true
            end
        end

        if gotArmor then
            Misc.Notify("Armor grabbed!", Color3.fromRGB(100, 200, 150))
        elseif success then
            Misc.Notify("Armor interaction sent", Color3.fromRGB(150, 150, 200))
        else
            Misc.Notify("Failed to grab armor - set position closer to stand", Color3.fromRGB(200, 60, 60))
        end

        hrp.CFrame = origCF
        hrp.Velocity = Vector3.new(0, 0, 0)
        cam.CFrame = origCam

        if Misc.Config.SpamEnabled then
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


--// ==================== AUTO STOMP ====================

local function AutoStompFindRemote()
    local possible = {
        ReplicatedStorage:FindFirstChild("GameRemotes") and ReplicatedStorage.GameRemotes:FindFirstChild("MainGameEvent"),
        ReplicatedStorage:FindFirstChild("MainRemotes") and ReplicatedStorage.MainRemotes:FindFirstChild("MainRemoteEvent"),
        ReplicatedStorage:FindFirstChild("MainGameEvent", true),
        ReplicatedStorage:FindFirstChild("MainRemoteEvent", true),
    }

    for _, rem in pairs(possible) do
        if rem and rem:IsA("RemoteEvent") then
            return rem
        end
    end

    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("main") or v.Name:lower():find("game") or v.Name:lower():find("shoot")) then
            return v
        end
    end
    return nil
end

local function AutoStompIsKnocked(plr)
    local char = plr and plr.Character
    if not char then return false end
    local be = char:FindFirstChild("BodyEffects")
    if not be then return false end
    local ko = be:FindFirstChild("K.O") or be:FindFirstChild("Knocked")
    return ko and ko.Value == true
end

local function AutoStompTryStomp()
    if not Misc.Config or not Misc.Config.AutoStompEnabled then return end
    if not Misc.AutoStompMainRemote then return end

    local myChar = LocalPlayer.Character
    if not myChar then return end

    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local now = tick()
    local myPos = myHRP.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local distance = (myPos - targetHRP.Position).Magnitude

                if AutoStompIsKnocked(plr) then
                    if Misc.AutoStompLastStomp[plr] and now - Misc.AutoStompLastStomp[plr] < 0.32 then
                        continue
                    end
                    Misc.AutoStompLastStomp[plr] = now

                    pcall(function()
                        if Misc.AutoStompMainRemote then
                            Misc.AutoStompMainRemote:FireServer("Stomp")
                            Misc.AutoStompMainRemote:FireServer("StompPlayer", plr.Character)
                            Misc.AutoStompMainRemote:FireServer("Stomp", plr.Character)
                        end
                    end)

                    break
                end
            end
        end
    end
end

function Misc.StartAutoStomp()
    if Misc.AutoStompConnection then return end
    Misc.AutoStompMainRemote = AutoStompFindRemote()
    Misc.AutoStompConnection = RunService.Heartbeat:Connect(AutoStompTryStomp)
end

function Misc.StopAutoStomp()
    if Misc.AutoStompConnection then
        Misc.AutoStompConnection:Disconnect()
        Misc.AutoStompConnection = nil
    end
    Misc.AutoStompLastStomp = {}
end

function Misc.SetAutoStompEnabled(enabled)
    if not Misc.Config then return end
    Misc.Config.AutoStompEnabled = enabled
    if enabled then
        Misc.StartAutoStomp()
    else
        Misc.StopAutoStomp()
    end
end

--// ==================== CONNECTION MANAGEMENT ====================
function Misc.EvaluateHeartbeat()
    local needHeartbeat = false
    if Misc.Config then
        if Misc.Config.AntiStomp then needHeartbeat = true end
        if Misc.Config.AutoArmor and not Misc.Config.AutoArmorOnDamage then needHeartbeat = true end
    end

    if needHeartbeat and not Misc.HeartbeatConnection then
        Misc.HeartbeatConnection = RunService.Heartbeat:Connect(Misc.OnHeartbeat)
    elseif not needHeartbeat and Misc.HeartbeatConnection then
        Misc.HeartbeatConnection:Disconnect()
        Misc.HeartbeatConnection = nil
    end
end

function Misc.OnHeartbeat()
    if Misc.Config and Misc.Config.AntiStomp then
        Misc.CheckAntiStomp()
    end

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

function Misc.SetAntiStomp(enabled)
    if not Misc.Config then return end
    Misc.Config.AntiStomp = enabled
    Misc.AntiStompTriggered = false
    Misc.EvaluateHealthHook()
    Misc.EvaluateHeartbeat()
end

function Misc.SetAutoArmor(enabled)
    if not Misc.Config then return end
    Misc.Config.AutoArmor = enabled
    Misc.EvaluateHealthHook()
    Misc.EvaluateHeartbeat()
end

function Misc.Start()
    Misc.EvaluateHeartbeat()
    if Misc.Config and Misc.Config.SpamEnabled then
        Misc.StartSpam()
    end
    if Misc.Config and Misc.Config.AutoStompEnabled then
        Misc.StartAutoStomp()
    end
end

function Misc.Reset()
    Misc.StopSpam()
    Misc.StopAutoStomp()
    Misc.AntiStompTriggered = false
    Misc.LastHealth = 100
    Misc.RefreshCharacter()
    if Misc.Config and Misc.Config.SpamEnabled then
        Misc.StartSpam()
    end
    if Misc.Config and Misc.Config.AutoStompEnabled then
        Misc.StartAutoStomp()
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