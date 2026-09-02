local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Spam = {
    Config = nil,
    Connection = nil,
    Character = nil,
    HRP = nil,
}

function Spam.SetConfig(config)
    Spam.Config = config
end

function Spam.RefreshCharacter()
    Spam.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Spam.HRP = Spam.Character:WaitForChild("HumanoidRootPart")
end

function Spam.TeleportSpam()
    if not Spam.HRP or not Spam.HRP.Parent then return end
    if not Spam.Config or not Spam.Config.SpamEnabled then return end

    local Config = Spam.Config

    if Config.SpamRange == "Close" then
        local newPos = Vector3.new(
            math.random(-Config.SpamCloseRadius, Config.SpamCloseRadius),
            Config.SpamCloseHeight + math.random(-Config.SpamCloseVerticalJitter, Config.SpamCloseVerticalJitter),
            math.random(-Config.SpamCloseRadius, Config.SpamCloseRadius)
        )
        Spam.HRP.CFrame = CFrame.new(newPos)
    else
        local base = Config.SpamFarBase or Vector3.new(500000, 500000, 500000)
        local jitter = Config.SpamFarJitter or 5000
        local newPos = base + Vector3.new(
            math.random(-jitter, jitter),
            math.random(-jitter, jitter),
            math.random(-jitter, jitter)
        )
        Spam.HRP.CFrame = CFrame.new(newPos)
    end
end

function Spam.Start()
    if Spam.Connection then Spam.Connection:Disconnect() end
    --// Use RenderStepped to match zee-hvh's frame rate and avoid races
    Spam.Connection = RunService.RenderStepped:Connect(Spam.TeleportSpam)
end

function Spam.Stop()
    if Spam.Connection then
        Spam.Connection:Disconnect()
        Spam.Connection = nil
    end
end

function Spam.Reset()
    Spam.Stop()
    Spam.RefreshCharacter()
    if Spam.Config and Spam.Config.SpamEnabled then
        Spam.Start()
    end
end

--// Init
Spam.RefreshCharacter()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    Spam.RefreshCharacter()
    if Spam.Config and Spam.Config.SpamEnabled then
        Spam.Start()
    end
end)

return Spam