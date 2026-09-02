--// utils/drawing.lua
--// Clean Drawing API wrapper with lifecycle management

local Drawing = {}

local Objects = {}

function Drawing.New(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    table.insert(Objects, obj)
    return obj
end

function Drawing.Clear()
    for _, obj in ipairs(Objects) do
        pcall(function() obj:Remove() end)
    end
    Objects = {}
end

return Drawing