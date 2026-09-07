local Auth = {
    Validated = false,
    Key = nil,
    HWID = nil,
    AuthURL = "https://your-server.com/api/validate", -- CHANGE THIS
    FallbackKeys = {},
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Auth.GenerateHWID()
    local hwid = nil
    
    -- Executor-specific HWID methods
    if syn and syn.get_hwid then hwid = syn.get_hwid()
    elseif krnl and krnl.get_hwid then hwid = krnl.get_hwid()
    elseif gethwid then hwid = gethwid()
    elseif fluxus and fluxus.get_hwid then hwid = fluxus.get_hwid()
    elseif codex and codex.get_hwid then hwid = codex.get_hwid()
    elseif delta and delta.get_hwid then hwid = delta.get_hwid()
    elseif electron and electron.get_hwid then hwid = electron.get_hwid()
    elseif oxy and oxy.get_hwid then hwid = oxy.get_hwid()
    elseif trigon and trigon.get_hwid then hwid = trigon.get_hwid()
    elseif vega and vega.get_hwid then hwid = vega.get_hwid()
    elseif hydrogen and hydrogen.get_hwid then hwid = hydrogen.get_hwid()
    elseif arceus and arceus.get_hwid then hwid = arceus.get_hwid()
    elseif celery and celery.get_hwid then hwid = celery.get_hwid()
    elseif macsploit and macsploit.get_hwid then hwid = macsploit.get_hwid()
    elseif solara and solara.get_hwid then hwid = solara.get_hwid()
    elseif xeno and xeno.get_hwid then hwid = xeno.get_hwid()
    end
    
    -- Fallback composite fingerprint
    if not hwid or #hwid < 8 then
        local fingerprint = tostring(LocalPlayer.UserId)
        
        pcall(function()
            local version = game:HttpGet("https://setup.rbxcdn.com/version")
            if version then fingerprint = fingerprint .. version:sub(1, 20) end
        end)
        
        local hash = 0
        for i = 1, #fingerprint do
            hash = ((hash << 5) - hash) + string.byte(fingerprint, i)
            hash = hash & 0xFFFFFFFF
        end
        
        hwid = string.format("FALLBACK-%08X-%08X", hash & 0xFFFFFFFF, LocalPlayer.UserId)
    end
    
    Auth.HWID = hwid
    return hwid
end

function Auth.ValidateKey(inputKey)
    local hwid = Auth.GenerateHWID()
    
    if Auth.FallbackKeys[inputKey] then
        Auth.Validated = true
        Auth.Key = inputKey
        return true, "fallback"
    end
    
    local success, response = pcall(function()
        local payload = HttpService:JSONEncode({ key = inputKey, hwid = hwid })
        return game:HttpPost(Auth.AuthURL, payload, false, "application/json")
    end)
    
    if success and response then
        local parsed = HttpService:JSONDecode(response)
        if parsed and parsed.valid then
            Auth.Validated = true
            Auth.Key = inputKey
            return true, parsed.hwid_status or "remote"
        else
            return false, parsed.reason or "unknown"
        end
    end
    
    return false, "connection_failed"
end

function Auth.IsValidated() return Auth.Validated end
function Auth.GetKey() return Auth.Key end
function Auth.GetHWID()
    if not Auth.HWID then Auth.GenerateHWID() end
    return Auth.HWID
end

return Auth