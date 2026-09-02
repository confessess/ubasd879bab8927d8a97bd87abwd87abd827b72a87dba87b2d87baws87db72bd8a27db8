--// modules/combat.lua
--// Frame Teleport Shoot + Rapid Fire

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Targeting = require(script.Parent.targeting)
local Visuals = require(script.Parent.visuals)

local Config = require(game:GetService("ReplicatedFirst"):WaitForChild("ZeeHConfig", 5) or script.Parent.Parent.config)

local Combat = {
    ModifiedTools = {},
}

function Combat.SetupFullAuto(tool)
    if Combat.ModifiedTools[tool] or not tool:FindFirstChild("GunScript") then return end
    
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
    
    if success then
        Combat.ModifiedTools[tool] = true
    end
end

function Combat.FrameTeleportActivate(tool, isRapidFire)
    if not Config.FrameTP then
        tool:Activate()
        return
    end
    
    local target = Targeting.GetTarget()
    if not target then
        tool:Activate()
        return
    end
    
    local char = LocalPlayer.Character
    if not char then
        tool:Activate()
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        tool:Activate()
        return
    end
    
    local targetChar = target.Parent
    if not targetChar then
        tool:Activate()
        return
    end
    
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP then
        tool:Activate()
        return
    end
    
    local origHRP = hrp.CFrame
    local origCam = Camera.CFrame
    
    local targetCF = targetHRP.CFrame
    local shootPos = targetCF.Position + (targetCF.LookVector * 2) + Vector3.new(0, 0.5, 0)
    
    hrp.CFrame = CFrame.new(shootPos, targetCF.Position)
    hrp.Velocity = Vector3.new(0, 0, 0)
    Camera.CFrame = CFrame.new(shootPos + Vector3.new(0, 1.5, 0), target.Position)
    
    tool:Activate()
    
    if not isRapidFire then
        RunService.Heartbeat:Wait()
    elseif Config.OneFrameDelay then
        RunService.Heartbeat:Wait()
    end
    
    hrp.CFrame = origHRP
    hrp.Velocity = Vector3.new(0, 0, 0)
    Camera.CFrame = origCam
    
    Visuals.PlayHitmarker()
end

function Combat.Reset()
    Combat.ModifiedTools = {}
end

return Combat