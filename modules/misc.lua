local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Misc = {
    Config = nil,
}

function Misc.SetConfig(config)
    Misc.Config = config
end

--// AntiStomp
local antiStompConnections = {}

local function executeAntiStomp()
    local Config = Misc.Config
    if not Config or not Config.AntiStomp then return end
    local char = LocalPlayer.Character
    if not char then return end

    if Config.AntiStompMode == "Void" then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(0, -10000, 0)
        end
    elseif Config.AntiStompMode == "Force Reset" then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
    end
end

local function applyAntiStomp(char)
    local Config = Misc.Config
    if not Config or not Config.AntiStomp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local conn = hum.StateChanged:Connect(function(oldState, newState)
        if not Config.AntiStomp then return end
        if newState == Enum.HumanoidStateType.PlatformStanding or newState == Enum.HumanoidStateType.Physics then
            executeAntiStomp()
        end
    end)

    table.insert(antiStompConnections, conn)
end

function Misc.StartAntiStomp()
    local Config = Misc.Config
    if not Config or not Config.AntiStomp then return end

    for _, conn in ipairs(antiStompConnections) do
        conn:Disconnect()
    end
    antiStompConnections = {}

    if LocalPlayer.Character then
        applyAntiStomp(LocalPlayer.Character)
    end

    local conn = LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        applyAntiStomp(char)
    end)
    table.insert(antiStompConnections, conn)
end

function Misc.StopAntiStomp()
    for _, conn in ipairs(antiStompConnections) do
        conn:Disconnect()
    end
    antiStompConnections = {}
end

--// Future: Ragebot, AutoStomp, AntiAim, etc.

return Misc