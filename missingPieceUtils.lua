--loadstring
-- local utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/bluescorpian/missingPieceUtils/main/missingPieceUtils.lua"))()
local VERSION = "0.1"
local genv = getgenv()
if type(genv.missingPieceUtils) == "table" and type(genv.missingPieceUtils[VERSION]) == "table" then return genv.missingPieceUtils[VERSION] end
local module = {}

local function createArgsString(nArgs)
    str = ""
    for i=1, nArgs, 1 do
        if i ~= 1 then 
            str = str .. ", "
        end
        str = str .. "arg" .. i
    end
    return str
end

function module.tostring(v, maxDepth)
    local tables = {}
    local function _tostring(value)
        local valueType = type(value)
        if valueType == "string" then
            return value
        elseif valueType == "function" then
            local info = debug.getinfo(value)
            return "f " .. ((info and info.name) or "") .. "(" .. ((info and info.numparams and createArgsString(info.numparams)) or "?") .. ")"
        elseif valueType == "table" then
            local str = ""
            local i = 1
            for k, v in pairs(value) do
                -- adds leading comma unless 1
                if i ~= 1 then
                    str = str .. ",\n"
                else
                    str = str .. "\n"
                end
                
                local kType = type(k)
                if kType == "string" then
                    str = str .. k
                elseif kType == "number" then
                    str = str .. "[" .. k .. "]"
                else
                    str = str .. _tostring(k)
                end
                str = str .. " = "
                -- add "string" arround string
                local vType = type(v)
                if vType == "string" then
                    str = str .. '"' .. v .. '"'
                elseif vType == "table" then
                    if k == "__index" then
                        str = str .. "(index table)"
                    elseif table.find(tables, v) then
                        str = str .. "(incursion)"
                    elseif maxDepth and #tables > maxDepth then
                        str = str .. "(max depth reached)"
                    else
                        tables[#tables+1] = v 
                        str = str .. _tostring(v)
                        tables[#tables] = nil
                    end
                else
                    str = str .. _tostring(v)
                end
                i = i + 1
            end
            if i ~= 1 then
                str = string.gsub(str, "\n+", "\n  ")
                str = str .. "\n"
            end
            str = "{" .. str .. "}"
            return str
        else
            return tostring(value)
        end
    end
    return _tostring(v)
end

function module.print(...)
    local args = {...}
    local stringedArgs = {}
    for i, v in ipairs(args) do
        stringedArgs[i] = module.tostring(v)
    end
    return print(table.unpack(stringedArgs))
end

function module.rconsoleprint(...)
    local args = {...}
    local str = ""
    for i, v in ipairs(args) do
        if i ~= 1 then
            str = str .. "  "
        end
        str = str .. module.tostring(v)
    end
    return rconsoleprint(str .. "\n")
end

function module.concatObject(tb1, tb2)
    local newTb = {}
    for i, v in pairs(tb1) do
        newTb[i] = v
    end
    for i, v in pairs(tb2) do
        newTb[i] = v
    end
    return newTb
end

function module.findFuncInGC(funcName)
    for _, v in pairs(getgc()) do
        if type(v) == "function" and not is_synapse_function(v) then
            local name = debug.getinfo(v, "n").name
            if name == funcName then 
                return v
            end
        end
    end    
end

function module.retryUntil(try, maxAttempts, retryWait)
    maxAttempts = maxAttempts or 10
    if retryWait == nil then retryWait = 0.1 end
    local attempts = 0
    while (maxAttempts == 0 or attempts < 2) do
        local success, value = pcall(function()
            return try()
        end)
        if success and value then
            return true, attempts, value
        end
        attempts += 1
        if retryWait ~= 0 then
            task.wait(retryWait)
        end
    end
    return false, attempts
end
-- function module.filterObj(tb, filter)
--     local newTb = {}
--     for i, v in pairs(tb) do
--         if not filter(i, v) then newTb[i] = v end
--     end
-- end

-- function module.findAllTools()
--     local LocalPlayer = game:GetService("Players").LocalPlayer
--     local Character = module.waitForCharacter(LocalPlayer)

--     local unfilteredBackpack = LocalPlayer.Backpack:GetChildren()
--     local trueI = 1
--     for 
-- end

-- function module.waitForCharacter(player)
--     if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
--         return player.Character
--     else
--         return player.CharacterAdded:Wait(60)
--     end
-- end

if type(genv.missingPieceUtils) ~= "table" then genv.missingPieceUtils = {} end
genv.missingPieceUtils[VERSION] = module
return module