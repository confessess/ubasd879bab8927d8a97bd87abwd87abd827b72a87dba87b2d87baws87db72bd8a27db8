local BASE_URL = "https://raw.githubusercontent.com/confessess/zee-hvh/main/"

local function loadModule(path)
    return loadstring(game:HttpGet(BASE_URL .. path))()
end

local Config = loadModule("config.lua")

local Targeting = loadModule("modules/targeting.lua")
Targeting.SetConfig(Config)

local Visuals = loadModule("modules/visuals.lua")
Visuals.SetConfig(Config)
Visuals.SetTargeting(Targeting)

local Combat = loadModule("modules/combat.lua")
Combat.SetConfig(Config)
Combat.SetTargeting(Targeting)
Combat.SetVisuals(Visuals)

local UI = loadModule("modules/ui.lua")
UI.SetConfig(Config)
UI.SetTargeting(Targeting)
UI.SetCombat(Combat)
UI.Build()

--// Render Loop
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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