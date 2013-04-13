
local SimpleInput = { }

local function GetKeyState(inputName)
    return (love.keyboard.isDown(inputName) and 1) or 0
end

local kKeyInputConfigs = { }
kKeyInputConfigs[1] = { }
kKeyInputConfigs[1]["X"] = { p = "a", n = "d" }
kKeyInputConfigs[1]["Y"] = { p = "w", n = "s" }
kKeyInputConfigs[1]["A"] = "lshift"
kKeyInputConfigs[1]["B"] = " "

kKeyInputConfigs[2] = { }
kKeyInputConfigs[2]["X"] = { p = "left", n = "right" }
kKeyInputConfigs[2]["Y"] = { p = "up", n = "down" }
kKeyInputConfigs[2]["A"] = "return"
kKeyInputConfigs[2]["B"] = "ralt"

kKeyInputConfigs[3] = { }
kKeyInputConfigs[3]["X"] = { p = "j", n = "l" }
kKeyInputConfigs[3]["Y"] = { p = "i", n = "k" }
kKeyInputConfigs[3]["A"] = "h"
kKeyInputConfigs[3]["B"] = "b"

kKeyInputConfigs[4] = { }
kKeyInputConfigs[4]["X"] = { p = "kp4", n = "kp6" }
kKeyInputConfigs[4]["Y"] = { p = "kp8", n = "kp2" }
kKeyInputConfigs[4]["A"] = "kp0"
kKeyInputConfigs[4]["B"] = "kpenter"

local function Axis(index, axis) return love.joystick.getAxis(index, axis) end
local function Button(index, button) return (love.joystick.isDown(index, button) and 1) or 0 end

local kJoyInputConfigs = { }
kJoyInputConfigs["X"] = function(index) return Axis(index, 0) end
kJoyInputConfigs["Y"] = function(index) return Axis(index, 1) end
kJoyInputConfigs["V"] = function(index) return Axis(index, 4) end
kJoyInputConfigs["W"] = function(index) return Axis(index, 3) end
kJoyInputConfigs["A"] = function(index) return Button(index, 0) end
kJoyInputConfigs["B"] = function(index) return Button(index, 1) end

local InputMetaTable = { }
InputMetaTable.__index = function(_, key) return InputMetaTable[key] end

--[[
 - Returns a value between -1 and 1 representing the input.
 --]]
function InputMetaTable:GetInputState(inputName)

    local state = 0
    
    local resolvedInputName = kKeyInputConfigs[self.index][inputName]
    if resolvedInputName then
    
        if type(resolvedInputName) == "table" then
        
            state = state - GetKeyState(resolvedInputName["p"])
            state = state + GetKeyState(resolvedInputName["n"])
            
        else
            state = state + GetKeyState(resolvedInputName)
        end
        
    end
    
    if love.joystick.isOpen(self.index) then
        state = state + kJoyInputConfigs[inputName](self.index)
    end
    
    return state
    
end

function SimpleInput.Create(index)

    assert(type(index) == "number")
    assert(index >= 1 and index <= 4)
    
    local createdInput = { }
    createdInput.index = index
    setmetatable(createdInput, InputMetaTable)
    
    return createdInput
    
end

return SimpleInput