local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Farm = {
    Config = nil,
    Targeting = nil,
    HeartbeatConn = nil,
    OriginalCFrame = nil,
    TargetHighlight = nil,
    NotificationGui = nil,
    RagebotConn = nil,
    RagebotKillInProgress = false,
    RagebotModifiedTools = {},
    RagebotKillCount = 0,
}

--// ==================== UTILS ====================
local function GetHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function GetTargetHRP(player)
    if not player then return nil end
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetTargetHead(player)
    if not player then return nil end
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("Head")
end

local function GetTargetHumanoid(player)
    if not player then return nil end
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function IsTargetAlive(player)
    if not player then return false end
    local hum = GetTargetHumanoid(player)
    if not hum then return false end
    return hum.Health > 0
end

local function IsTargetKnocked(player)
    if not player then return false end
    local char = player.Character
    if not char then return false end
    local be = char:FindFirstChild("BodyEffects")
    if not be then return false end
    local ko = be:FindFirstChild("K.O") or be:FindFirstChild("Knocked")
    return ko and ko.Value == true
end

--// ==================== NOTIFICATIONS ====================
function Farm.Notify(text, color)
    color = color or Color3.fromRGB(100, 200, 150)
    if not Farm.NotificationGui then
        local sg = Instance.new("ScreenGui")
        sg.Name = "ENIFarmNotifs"
        sg.ResetOnSpawn = false
        sg.Parent = game.CoreGui
        Farm.NotificationGui = sg
    end
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 32)
    frame.Position = UDim2.new(0.5, -130, 0, -40)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    frame.Parent = Farm.NotificationGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Parent = frame
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(235, 235, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    frame:TweenPosition(UDim2.new(0.5, -130, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    task.delay(2, function()
        frame:TweenPosition(UDim2.new(0.5, -130, 0, -40), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
        task.wait(0.35)
        if frame then frame:Destroy() end
    end)
end

--// ==================== TARGET MANAGEMENT ====================
function Farm.GetSelectedTarget()
    if Farm.Targeting and Farm.Targeting.SelectedTarget then
        local target = Farm.Targeting.SelectedTarget
        if typeof(target) == "Instance" then
            if target:IsA("Player") then
                return target
            elseif target:IsA("BasePart") and target.Parent then
                return Players:GetPlayerFromCharacter(target.Parent)
            end
        end
    end
    return nil
end

function Farm.SaveTargetPosition()
    local target = Farm.GetSelectedTarget()
    if not target then
        Farm.OriginalCFrame = nil
        return
    end
    local hrp = GetTargetHRP(target)
    if hrp then
        Farm.OriginalCFrame = hrp.CFrame
        Farm.HighlightTarget(target)
    end
end

function Farm.RestoreTarget()
    if Farm.OriginalCFrame then
        local target = Farm.GetSelectedTarget()
        if target then
            local hrp = GetTargetHRP(target)
            if hrp and hrp.Parent then
                hrp.CFrame = Farm.OriginalCFrame
            end
        end
    end
    Farm.OriginalCFrame = nil
    Farm.ClearHighlight()
end

function Farm.IsTargetAlive()
    local target = Farm.GetSelectedTarget()
    if not target then return false end
    local hum = GetTargetHumanoid(target)
    if not hum then return false end
    return hum.Health > 0
end

--// ==================== HIGHLIGHT ====================
function Farm.HighlightTarget(player)
    Farm.ClearHighlight()
    if not player then return end
    local char = player.Character
    if not char then return end
    local hl = Instance.new("Highlight")
    hl.Name = "Eni_FarmHighlight"
    hl.FillColor = Color3.fromRGB(145, 75, 255)
    hl.OutlineColor = Color3.fromRGB(255, 200, 255)
    hl.FillTransparency = 0.3
    hl.OutlineTransparency = 0
    hl.Parent = char
    hl.Adornee = char
    Farm.TargetHighlight = hl
end

function Farm.ClearHighlight()
    if Farm.TargetHighlight then
        Farm.TargetHighlight:Destroy()
        Farm.TargetHighlight = nil
    end
end

--// ==================== CORE FARM LOGIC ====================
function Farm.GetCrosshairWorldPos()
    local camPos = Camera.CFrame.Position
    local forward = Camera.CFrame.LookVector
    return camPos + (forward * (Farm.Config.FarmDistance or 12)) + Vector3.new(0, Farm.Config.FarmVerticalOffset or 0, 0)
end

function Farm.PullTarget()
    if not Farm.Config or not Farm.Config.FarmEnabled then return end
    local target = Farm.GetSelectedTarget()
    if not target then return end
    if not Farm.IsTargetAlive() then
        Farm.Notify("Target died", Color3.fromRGB(200, 150, 100))
        Farm.RestoreTarget()
        return
    end
    local targetHRP = GetTargetHRP(target)
    local targetHead = GetTargetHead(target)
    local myHRP = GetHRP()
    if not targetHRP or not myHRP then return end
    if not Farm.OriginalCFrame then
        Farm.OriginalCFrame = targetHRP.CFrame
        Farm.HighlightTarget(target)
    end
    local headTargetPos = Farm.GetCrosshairWorldPos()
    local headOffset = Vector3.new(0, 1.5, 0)
    if targetHead and targetHRP then
        headOffset = targetHead.Position - targetHRP.Position
    end
    local newHRPPos = headTargetPos - headOffset
    local fakeCF = CFrame.new(newHRPPos, myHRP.Position)
    local pullSpeed = Farm.Config.FarmPullSpeed or 1
    if pullSpeed <= 1 then
        targetHRP.CFrame = fakeCF
    else
        local current = targetHRP.CFrame
        local lerped = current:Lerp(fakeCF, 1 / pullSpeed)
        targetHRP.CFrame = lerped
    end
    targetHRP.Velocity = Vector3.new(0, 0, 0)
    targetHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    targetHRP.RotVelocity = Vector3.new(0, 0, 0)
end

--// ==================== RAGEBOT ====================
local function RagebotGetAllGuns()
    local guns = {}
    local myChar = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if myChar then
        local equipped = myChar:FindFirstChildOfClass("Tool")
        if equipped and equipped:FindFirstChild("GunScript") then
            table.insert(guns, equipped)
        end
    end
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("GunScript") then
                table.insert(guns, item)
            end
        end
    end
    return guns
end

local function RagebotEquipTool(tool)
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local current = myChar:FindFirstChildOfClass("Tool")
    if current then current.Parent = LocalPlayer.Backpack end
    tool.Parent = myChar
    return true
end

local function RagebotUnequipAll()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local current = myChar:FindFirstChildOfClass("Tool")
    if current then current.Parent = LocalPlayer.Backpack end
end

local function RagebotSetupFullAuto(tool)
    if Farm.RagebotModifiedTools[tool] or not tool:FindFirstChild("GunScript") then return end
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
    if success then Farm.RagebotModifiedTools[tool] = true end
end

local function RagebotForceAim(target)
    local targetHead = GetTargetHead(target)
    local myHRP = GetHRP()
    if not targetHead or not myHRP then return end
    local targetPos = targetHead.Position
    local myPos = myHRP.Position
    Camera.CFrame = CFrame.new(myPos + Vector3.new(0, 1.5, 0), targetPos)
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
        end
    end
end

local function RagebotPullTarget(target)
    local targetHRP = GetTargetHRP(target)
    local targetHead = GetTargetHead(target)
    local myHRP = GetHRP()
    if not targetHRP or not myHRP then return end
    local myPos = myHRP.Position
    local myLook = myHRP.CFrame.LookVector
    local headTargetPos = myPos + (myLook * 2) + Vector3.new(0, 0, 0)
    local headOffset = Vector3.new(0, 1.5, 0)
    if targetHead and targetHRP then
        headOffset = targetHead.Position - targetHRP.Position
    end
    local newHRPPos = headTargetPos - headOffset
    local fakeCF = CFrame.new(newHRPPos, myPos)
    targetHRP.CFrame = fakeCF
    targetHRP.Velocity = Vector3.new(0, 0, 0)
    targetHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    targetHRP.RotVelocity = Vector3.new(0, 0, 0)
end

local function RagebotShootTarget(target)
    local guns = RagebotGetAllGuns()
    if #guns == 0 then return false end
    local myHRP = GetHRP()
    if not myHRP then return false end
    for _, gun in pairs(guns) do
        if not Farm.Config.RagebotEnabled then return false end
        local targetHum = GetTargetHumanoid(target)
        if not targetHum or targetHum.Health <= 0 then return true end
        if IsTargetKnocked(target) then return true end
        RagebotEquipTool(gun)
        RagebotSetupFullAuto(gun)
        task.wait(0.15)
        local shootStart = tick()
        while tick() - shootStart < 1 do
            if not Farm.Config.RagebotEnabled then return false end
            targetHum = GetTargetHumanoid(target)
            if not targetHum or targetHum.Health <= 0 then return true end
            if IsTargetKnocked(target) then return true end
            RagebotPullTarget(target)
            RagebotForceAim(target)
            if gun and gun.Parent then
                gun:Activate()
                gun:Activate()
            end
            RunService.RenderStepped:Wait()
        end
    end
    local targetHum = GetTargetHumanoid(target)
    if not targetHum then return true end
    return targetHum.Health <= 0 or IsTargetKnocked(target)
end

local function RagebotConstantDeath(target)
    local maxWait = 20
    local startTime = tick()
    local deathCount = 0
    while tick() - startTime < maxWait do
        if not Farm.Config.RagebotEnabled then return false end
        if IsTargetAlive(target) and not IsTargetKnocked(target) then
            pcall(function() LocalPlayer:LoadCharacter() end)
            local char = LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart", 3)
            local hum = char:WaitForChild("Humanoid", 3)
            if hrp and hum then
                task.wait(0.2)
                return true
            end
            return false
        end
        local myHRP = GetHRP()
        local humanoid = GetHumanoid()
        if myHRP and humanoid and humanoid.Health > 0 then
            myHRP.CFrame = CFrame.new(0, -50000, 0)
            myHRP.Velocity = Vector3.new(0, 0, 0)
            myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            humanoid.Health = 0
            local char = LocalPlayer.Character
            if char then pcall(function() char:BreakJoints() end) end
            deathCount = deathCount + 1
        end
        if not myHRP or not humanoid or humanoid.Health <= 0 then
            pcall(function() LocalPlayer:LoadCharacter() end)
            task.wait(0.3)
            myHRP = GetHRP()
            humanoid = GetHumanoid()
            if myHRP and humanoid then
                myHRP.CFrame = CFrame.new(0, -50000, 0)
                humanoid.Health = 0
                pcall(function() 
                    local char = LocalPlayer.Character
                    if char then char:BreakJoints() end
                end)
            end
        end
        RunService.Heartbeat:Wait()
    end
    pcall(function() LocalPlayer:LoadCharacter() end)
    task.wait(0.5)
    return false
end

-- FrameTP method — TP inside target, shoot, return (invisible to them)
local function RagebotFrameTPStompKill(target)
    local guns = RagebotGetAllGuns()
    if #guns == 0 then return false end
    local myHRP = GetHRP()
    if not myHRP then return false end
    local originalCFrame = myHRP.CFrame
    local originalCam = Camera.CFrame

    for _, gun in pairs(guns) do
        if not Farm.Config.RagebotEnabled then 
            myHRP.CFrame = originalCFrame
            Camera.CFrame = originalCam
            return false 
        end
        local targetHum = GetTargetHumanoid(target)
        if not targetHum or targetHum.Health <= 0 then 
            myHRP.CFrame = originalCFrame
            Camera.CFrame = originalCam
            return true 
        end
        if IsTargetKnocked(target) then break end
        RagebotEquipTool(gun)
        RagebotSetupFullAuto(gun)
        task.wait(0.1)

        local shootStart = tick()
        while tick() - shootStart < 1 do
            if not Farm.Config.RagebotEnabled then 
                myHRP.CFrame = originalCFrame
                Camera.CFrame = originalCam
                return false 
            end
            targetHum = GetTargetHumanoid(target)
            if not targetHum or targetHum.Health <= 0 then 
                myHRP.CFrame = originalCFrame
                Camera.CFrame = originalCam
                return true 
            end
            if IsTargetKnocked(target) then break end

            local currentHead = GetTargetHead(target)
            local currentHRP = GetTargetHRP(target)
            if currentHead and currentHRP then
                -- Direction behind target
                local targetLook = currentHead.CFrame.LookVector
                local behindDirection = -targetLook

                -- TP 2 studs behind target
                local behindPos = currentHead.Position + (behindDirection * 2)
                myHRP.CFrame = CFrame.new(behindPos, currentHead.Position)
                myHRP.Velocity = Vector3.new(0, 0, 0)
                myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

                -- Camera 1.5 studs behind target — target head is between camera and our character
                -- This means bullets travel: camera -> target head -> our character
                local camPos = currentHead.Position + (behindDirection * 1.5)
                Camera.CFrame = CFrame.new(camPos, behindPos) -- Look back towards our character
            end

            if gun and gun.Parent then
                gun:Activate()
            end

            RunService.RenderStepped:Wait()
            -- Return to original (FrameTP — invisible to target)
            myHRP.CFrame = originalCFrame
            Camera.CFrame = originalCam
        end
    end

    -- Stomp phase — FrameTP inside target, stomp, return
    if IsTargetKnocked(target) then
        local mainRemote = ReplicatedStorage:FindFirstChild("MainRemotes") and ReplicatedStorage.MainRemotes:FindFirstChild("MainRemoteEvent")
        if mainRemote then
            local stompStart = tick()
            while tick() - stompStart < 5 do
                if not Farm.Config.RagebotEnabled then break end
                local targetChar = target.Character
                if not targetChar then break end
                local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                if not targetHum or targetHum.Health <= 0 then break end
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                if not targetHRP then break end

                -- FrameTP directly ONTO ragdolled player — track every frame
                myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 1, 0)
                myHRP.Velocity = Vector3.new(0, 0, 0)
                myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myHRP.RotVelocity = Vector3.new(0, 0, 0)

                pcall(function()
                    mainRemote:FireServer("Stomp")
                end)

                RunService.RenderStepped:Wait()
                -- Return
                myHRP.CFrame = originalCFrame
            end
        end
        myHRP.CFrame = originalCFrame
        Camera.CFrame = originalCam
        Farm.RagebotKillCount = Farm.RagebotKillCount + 1
        Farm.Notify("Ragebot kill #" .. Farm.RagebotKillCount, Color3.fromRGB(200, 50, 50))
        return true
    end

    myHRP.CFrame = originalCFrame
    Camera.CFrame = originalCam
    return false
end

local function RagebotKillLoop()
    if not Farm.Config or not Farm.Config.RagebotEnabled then return end
    if Farm.RagebotKillInProgress then return end
    Farm.RagebotKillInProgress = true
    local target = Farm.GetSelectedTarget()
    if not target then
        Farm.RagebotKillInProgress = false
        return
    end
    if not IsTargetAlive(target) or IsTargetKnocked(target) then
        Farm.RagebotKillInProgress = false
        return
    end
    local killed = false
    if Farm.Config.RagebotMethod == "FrameTPStomp" then
        killed = RagebotFrameTPStompKill(target)
    else
        killed = RagebotShootTarget(target)
    end
    if killed then
        RagebotConstantDeath(target)
    end
    Farm.RagebotKillInProgress = false
end

function Farm.StartRagebot()
    if Farm.RagebotConn then return end
    Camera.CameraType = Enum.CameraType.Scriptable
    Farm.RagebotConn = RunService.Heartbeat:Connect(RagebotKillLoop)
    Farm.Notify("Ragebot ON", Color3.fromRGB(200, 50, 50))
end

function Farm.StopRagebot()
    if Farm.RagebotConn then
        Farm.RagebotConn:Disconnect()
        Farm.RagebotConn = nil
    end
    Farm.RagebotKillInProgress = false
    RagebotUnequipAll()
    Camera.CameraType = Enum.CameraType.Custom
    Camera.FieldOfView = 70
    local myHRP = GetHRP()
    if myHRP then
        local camPos = myHRP.Position + Vector3.new(0, 1.5, 0) - (myHRP.CFrame.LookVector * 5)
        Camera.CFrame = CFrame.new(camPos, myHRP.Position)
    end
    Farm.Notify("Ragebot OFF", Color3.fromRGB(150, 150, 150))
end

function Farm.SetRagebotMethod(method)
    if not Farm.Config then return end
    Farm.Config.RagebotMethod = method
end

function Farm.SetRagebotEnabled(enabled)
    if not Farm.Config then return end
    Farm.Config.RagebotEnabled = enabled
    if enabled then
        Farm.StartRagebot()
    else
        Farm.StopRagebot()
    end
end

--// ==================== CONTROL ====================
function Farm.Start()
    if Farm.HeartbeatConn then Farm.HeartbeatConn:Disconnect() end
    Farm.SaveTargetPosition()
    Farm.HeartbeatConn = RunService.Heartbeat:Connect(Farm.PullTarget)
    local target = Farm.GetSelectedTarget()
    if target then
        Farm.Notify("Farming " .. target.DisplayName, Color3.fromRGB(145, 75, 255))
    else
        Farm.Notify("Farm ON — select a target in Target tab", Color3.fromRGB(145, 75, 255))
    end
end

function Farm.Stop()
    if Farm.HeartbeatConn then
        Farm.HeartbeatConn:Disconnect()
        Farm.HeartbeatConn = nil
    end
    Farm.RestoreTarget()
    print("[Stars Farm] STOPPED — Target restored")
end

function Farm.SetEnabled(enabled)
    if not Farm.Config then return end
    Farm.Config.FarmEnabled = enabled
    if enabled then Farm.Start() else Farm.Stop() end
end

function Farm.Toggle()
    if not Farm.Config then return end
    Farm.SetEnabled(not Farm.Config.FarmEnabled)
end

function Farm.SetConfig(config)
    Farm.Config = config
end

function Farm.SetTargeting(targeting)
    Farm.Targeting = targeting
end

LocalPlayer.CharacterAdded:Connect(function()
    if Farm.Config and Farm.Config.FarmEnabled then
        task.wait(0.5)
        Farm.SaveTargetPosition()
    end
end)

return Farm