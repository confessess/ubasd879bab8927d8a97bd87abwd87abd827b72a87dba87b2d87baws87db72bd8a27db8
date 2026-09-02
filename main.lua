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

--// ENI's Misc Module — AntiStomp + Teleport Spam
local Misc = loadModule("modules/misc.lua")
Misc.SetConfig(Config)
Misc.Start()

local UI = loadModule("modules/ui.lua")
UI.SetConfig(Config)
UI.SetTargeting(Targeting)
UI.SetCombat(Combat)
UI.SetMisc(Misc)
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

--// Reset on respawn — keep target if they're still alive
LocalPlayer.CharacterAdded:Connect(function()
    local savedTarget = Targeting.SelectedTarget
    Combat.Reset()
    Config.Spectate = false
    Targeting.StopSpectate()
    Misc.Reset()
    --// Restore target after respawn if still valid
    task.delay(0.5, function()
        if savedTarget and savedTarget.Parent then
            local targetChar = savedTarget.Parent
            local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
            if targetHumanoid and targetHumanoid.Health > 0 then
                Targeting.SelectedTarget = savedTarget
            end
        end
    end)
end)

print("[ZeeHood] HvH Suite loaded with ENI Misc.")
print("[ZeeHood] Toggle UI with " .. Config.ToggleKey.Name)