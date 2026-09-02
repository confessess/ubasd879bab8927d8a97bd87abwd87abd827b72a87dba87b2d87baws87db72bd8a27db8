--// main.lua
--// Zee Hood HVH — Entry Point

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// Load modules
local Config = require(script.config)
local Targeting = require(script.modules.targeting)
local Visuals = require(script.modules.visuals)
local Combat = require(script.modules.combat)
local UI = require(script.modules.ui)

--// Build UI
UI.Build()

--// Render Loop
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

print("[ZeeHood] HvH Suite loaded.")
print("[ZeeHood] Toggle UI with " .. Config.ToggleKey.Name)