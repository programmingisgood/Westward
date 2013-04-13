
local function TransformWorldPosition(self, worldPos)

    local viewPortSize = vec2(GetScreenDims())
    local halfViewPortSize = viewPortSize:Mul(0.5)
    local adjustedPos = worldPos:Sub(halfViewPortSize)
    
    -- Clamp to world extents
    adjustedPos.x = adjustedPos.x > 0 and adjustedPos.x or 0
    adjustedPos.y = adjustedPos.y > 0 and adjustedPos.y or 0
    
    if halfViewPortSize.x + worldPos.x >= self.worldExtents.x then
        adjustedPos.x = self.worldExtents.x - viewPortSize.x
    end
    if halfViewPortSize.y + worldPos.y >= self.worldExtents.y then
        adjustedPos.y = self.worldExtents.y - viewPortSize.y
    end
    
    return adjustedPos
    
end

local function Draw(self)

    assert(self.focusObject)
    
    local adjustedPos = TransformWorldPosition(self, self.focusObject:GetPosition())
    love.graphics.translate(-adjustedPos.x, -adjustedPos.y)
    
end

local function GetScreenPosition(self, worldPos)

    local adjustedPos = TransformWorldPosition(self, worldPos)
    return worldPos:Sub(adjustedPos)
    
end

local function SetWorldExtents(self, maxX, maxY)
    self.worldExtents = vec2(maxX, maxY)
end

local function SetFocusObject(self, focusObject)

    assert(HasMixin(focusObject, "Movable"))
    
    self.focusObject = focusObject
    
end

local function Create()

    local camera = { }
    
    camera.Draw = Draw
    camera.GetScreenPosition = GetScreenPosition
    camera.SetWorldExtents = SetWorldExtents
    camera.SetFocusObject = SetFocusObject
    
    return camera
    
end

return { Create = Create }