local BASE_URL = "https://raw.githubusercontent.com/confessess/zee-hvh/main/"

local function loadModule(path)
    return loadstring(game:HttpGet(BASE_URL .. path))()
end

local Auth = loadModule("modules/auth.lua")
local KeyGate = loadModule("modules/keygate.lua")

-- Update this to your backend URL
Auth.AuthURL = "https://your-server.com/api/validate"

KeyGate.Build(Auth, function(key, source)
    print("[ZeeHood] Key validated: " .. key .. " (" .. source .. ")")

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

    local Misc = loadModule("modules/misc.lua")
    Misc.SetConfig(Config)
    Misc.Start()

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

    -- Render Loop (same as before)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    RunService.RenderStepped:Connect(function()
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
                if Config.RapidFire then
                    Combat.SetupFullAuto(tool)
                end
                if Config.RapidFire and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    Combat.FrameTeleportActivate(tool, true)
                end
            end
        end
    end)

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

    LocalPlayer.CharacterAdded:Connect(function()
        local savedTarget = Targeting.SelectedTarget
        local savedPlayer = nil
        if savedTarget and savedTarget.Parent then
            savedPlayer = Players:GetPlayerFromCharacter(savedTarget.Parent)
        end

        Combat.Reset()
        Config.Spectate = false
        Targeting.StopSpectate()
        Misc.Reset()

        task.delay(0.5, function()
            if savedPlayer then
                if savedPlayer.Character then
                    local targetPart = savedPlayer.Character:FindFirstChild(Config.TargetPart or "Head")
                    if targetPart then
                        Targeting.SelectedTarget = targetPart
                    end
                end
            elseif savedTarget and savedTarget.Parent then
                Targeting.SelectedTarget = savedTarget
            end
        end)
    end)

    print("[ZeeHood] Stars.cc loaded")
    print("[ZeeHood] Toggle UI with " .. Config.ToggleKey.Name)
end)