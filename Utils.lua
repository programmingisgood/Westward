
-- Return a random number between -1 and 1.
function RandomClamped()
    return math.random() - math.random()
end

-- Return a random floating point number between the min and max
-- numbers passed in.
function RandomFloatBetween(min, max)
    return min + (math.random() * (max - min))
end

function RandomAngle()
    return math.random() * math.pi * 2
end

function RandomPoint(minX, maxX, minY, maxY)
    return vec2(RandomFloatBetween(minX, maxX), RandomFloatBetween(minY, maxY))
end

function RandomInArray(array)
    return array[math.random(1, #array)]
end

function Round(value)

    local left, right = math.modf(value)
    if right >= 0.5 then
        return left + 1
    else
        return left
    end
    
end

function Wrap(val, addAmount, min, max)

    local newVal = val + addAmount
    
    if newVal < min then
        newVal = max
    elseif newVal > max then
        newVal = min
    end
    
    return newVal
    
end

function CountKeys(ofTable)

    local count = 0
    for _, _ in pairs(ofTable) do
        count = count + 1
    end
    return count
    
end

-- Returns the passed in value from the passed in table.
-- Note: The table must be "array" like as opposed to a map.
function RemoveValue(fromTable, value)

    for i = 1, #fromTable do
    
        if fromTable[i] == value then
        
            table.remove(i)
            break
            
        end
        
    end
    
end

function Iterate(array, func)

    for i = 1, #array do
        func(array[i])
    end
    
end

function Clamp(num, min, max)
    return math.min(max, math.max(num, min))
end

function GetScreenDims()
    return love.graphics.getWidth(), love.graphics.getHeight()
end

function GetScreenCenter()

    local w, h = GetScreenDims()
    return vec2(w / 2, h / 2)
    
end

function GetScreenBoundingBox()
    return rect(GetScreenCenter(), vec2(GetScreenDims()))
end

function DrawFramerate()

    local dt = love.timer.getDelta()
    love.graphics.print(tostring(math.ceil(1 / dt)), 10, 10, 0, 1, 1)
    
end

function Now()
    return love.timer.getTime()
end

function CosAnim(speed)
    return ((math.cos(Now() * speed) + 1) / 2)
end

-- Pass in a function. Bind will return a function that can be called with the provided arguments.
-- Bind(function(a, b, c) print(a .. b .. c) end, 2, 3)(1)
-- will print "123"
function Bind(func, ...)

    local args = { ... }
    return function(...)
        return func(..., unpack(args))
    end
    
end

function vec2(setX, setY)

    assert(setX)
    assert(setY)
    
    local newVec = { x = setX, y = setY }
    
    function newVec:Add(addVec)
        return vec2(self.x + addVec.x, self.y + addVec.y)
    end
    
    function newVec:Sub(subVec)
        return vec2(self.x - subVec.x, self.y - subVec.y)
    end

    function newVec:SubNorm(subVec)
        return vec2(self.x - subVec.x, self.y - subVec.y):Normalize()
    end
    
    function newVec:Mul(scalar)
        return vec2(self.x * scalar, self.y * scalar)
    end
    
    function newVec:Length()
        return math.sqrt(self.x * self.x + self.y * self.y)
    end
    
    function newVec:LengthSquared()
        return self.x * self.x + self.y * self.y
    end
    
    function newVec:Distance(toPoint)
        return self:Sub(toPoint):Length()
    end
    
    function newVec:DistanceSquared(toPoint)
        return self:Sub(toPoint):LengthSquared()
    end
    
    function newVec:Normalize()
    
        local length = self:Length()
        return vec2(self.x / length, self.y / length)
        
    end
    
    function newVec:ToAngle()
    
        local normalVec = self:Normalize()
        return math.atan2(normalVec.x, -normalVec.y)
        
    end
    
    function newVec:Copy(srcVec)
    
        self.x = srcVec.x
        self.y = srcVec.y
        
    end
    
    function newVec:Equals(vec)
        return self.x == vec.x and self.y == vec.y
    end

    function newVec:unpack()
        return self.x, self.y
    end
    
    return newVec

end

function color(setR, setG, setB, setA)

    local newColor = { r = setR, g = setG, b = setB, a = setA }
    
    function newColor:unpack()
        return self.r, self.g, self.b, self.a
    end
    
    return newColor
    
end

White = color(255, 255, 255, 255)
Black = color(0, 0, 0, 255)

function rect(center, size)

    local newRect = { topLeft = center:Sub(size:Mul(0.5)), bottomRight = center:Add(size:Mul(0.5)) }
    
    function newRect:Overlaps(otherRect)
    
        if self.topLeft.x > otherRect.bottomRight.x or self.topLeft.y > otherRect.bottomRight.y or
           self.bottomRight.x < otherRect.topLeft.x or self.bottomRight.y < otherRect.topLeft.y then
           
           return false
           
        end
        
        return true
        
    end
    
    return newRect
    
end

local getTime = love.timer.getTime
function Animation(startVal, endVal, totalTime)

    local anim = { startVal = startVal, endVal = endVal, totalTime = totalTime, startTime = getTime() }
    
    function anim:GetValue()
        return self.startVal + (self.endVal - self.startVal) * ((getTime() - self.startTime) / self.totalTime)
    end

    function anim:GetIsComplete()
        return (getTime() - self.startTime) >= self.totalTime
    end

    return anim

end