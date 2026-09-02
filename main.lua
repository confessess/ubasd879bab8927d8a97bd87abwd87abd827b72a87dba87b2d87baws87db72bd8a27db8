local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// Load modules
local Config = require(game.ReplicatedStorage.Config)
local Targeting = require(game.ReplicatedStorage.Modules.Targeting)
local Combat = require(game.ReplicatedStorage.Modules.Combat)
local Misc = require(game.ReplicatedStorage.Modules.Misc)
local Visuals = require(game.ReplicatedStorage.Modules.Visuals)
local UI = require(game.ReplicatedStorage.Modules.UI)

--// Wire config to all modules
Targeting.SetConfig(Config)
Combat.SetConfig(Config)
Misc.SetConfig(Config)
Visuals.SetConfig(Config)
UI.SetConfig(Config)

--// Wire cross-module references
Combat.SetTargeting(Targeting)
Combat.SetVisuals(Visuals)
Visuals.SetTargeting(Targeting)
UI.SetTargeting(Targeting)
UI.SetCombat(Combat)
UI.SetMisc(Misc)

--// Build GUI
UI.Build()

--// Render loop
RunService.RenderStepped:Connect(function()
    Visuals.Update()

    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            Combat.SetupFullAuto(tool)
            if Config.RapidFire and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                Combat.FrameTeleportActivate(tool, true)
            end
        end
    end
end)

--// Manual click
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and not Config.RapidFire then
                Combat.FrameTeleportActivate(tool, false)
            end
        end
    end
end)

--// Reset on respawn
LocalPlayer.CharacterAdded:Connect(function()
    Combat.Reset()
    Targeting.SelectedTarget = nil
    Config.Spectate = false
    Targeting.StopSpectate()
end)

--// Start AntiStomp if enabled
if Config.AntiStomp then
    Misc.StartAntiStomp()
end

print("[ZeeHood] HvH Suite loaded.")
print("[ZeeHood] Toggle UI with " .. Config.ToggleKey.Name)