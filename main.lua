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

--// ENI's Misc Module — AntiStomp + Teleport Spam + Auto Armor
local Misc = loadModule("modules/misc.lua")
Misc.SetConfig(Config)
Misc.Start()

--// ENI Farm Module — Pull target to crosshair
local Farm = loadModule("modules/farm.lua")
Farm.SetConfig(Config)
Farm.SetTargeting(Targeting)

local UI = loadModule("modules/ui.lua")
UI.SetConfig(Config)
UI.SetTargeting(Targeting)
UI.SetCombat(Combat)
UI.SetMisc(Misc)
UI.SetFarm(Farm)
UI.Build()

--// Render Loop
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

RunService.RenderStepped:Connect(function()
    --// Only run visuals if any visual feature is enabled
    local anyVisuals = Config.FOV_Enabled or Config.Tracers or Config.Highlights or Config.Spectate or Config.Hitmarkers
    if anyVisuals then
        Visuals.Update()
    else
        Visuals.Clear()
    end

    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            --// Only patch fire-rate when RapidFire is toggled on
            if Config.RapidFire then
                Combat.SetupFullAuto(tool)
            end
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

--// Reset on respawn — KEEP TARGET even if they died and respawned
LocalPlayer.CharacterAdded:Connect(function()
    --// Save the target PLAYER, not just the part
    local savedTarget = Targeting.SelectedTarget
    local savedPlayer = nil
    if savedTarget and savedTarget.Parent then
        savedPlayer = Players:GetPlayerFromCharacter(savedTarget.Parent)
    end

    Combat.Reset()
    Config.Spectate = false
    Targeting.StopSpectate()
    Misc.Reset()

    --// Restore target after respawn
    task.delay(0.5, function()
        if savedPlayer then
            --// Target is a player — find their new character after respawn
            if savedPlayer.Character then
                local targetPart = savedPlayer.Character:FindFirstChild(Config.TargetPart or "Head")
                if targetPart then
                    Targeting.SelectedTarget = targetPart
                end
            end
        elseif savedTarget and savedTarget.Parent then
            --// Fallback: target part still exists (they didn't die)
            Targeting.SelectedTarget = savedTarget
        end
    end)
end)

print("[ZeeHood] Stars.cc loaded")
print("[ZeeHood] Toggle UI with " .. Config.ToggleKey.Name)