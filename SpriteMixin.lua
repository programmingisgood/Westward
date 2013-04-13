
SpriteMixin = { type = "Sprite" }

function SpriteMixin:__initmixin()

    self.image = nil
    self.anims = { }
    self.currentAnimName = nil
    self.currentAnim = nil
    self.currentAnimTime = 0
    self.currentAnimIndex = 1
    self.color = color(255, 255, 255, 255)
    self.anchorX = "center"
    self.anchorY = "center"
    
end

function SpriteMixin:SetImage(fileName, numRows, numCols)

    self.drawImage = love.graphics.newImage(fileName)
    self.drawImage:setFilter("nearest", "nearest")
    self.numRows = numRows
    self.numCols = numCols
    self.quadW = self.drawImage:getWidth() / numCols
    self.quadH = self.drawImage:getHeight() / numRows
    
    -- Initialize the drawQuad.
    self:ClearAnimation()
    
end

function SpriteMixin:SetAnchor(x, y)

    self.anchorX = x
    self.anchorY = y
    
end

function SpriteMixin:SetColor(setColor)
    self.color = setColor
end

function SpriteMixin:GetColor()
    return color(self.color:unpack())
end

function SpriteMixin:AddAnimation(animName, animDef)

    -- Format is:
    -- { { frame = 1, time = 0.5 }, { frame = 2, time = 1.2, callback = function() end } }
    -- Where frame is the frame number to display and time
    -- is how long to display the frame. The animation will loop.
    -- If a callback is specified on a frame, it will be called when the frame it is on is complete.
    
    assert(self.drawImage)
    assert(type(animName) == "string")
    assert(type(animDef) == "table")
    
    self.anims[animName] = animDef
    
end

local function UpdateDrawQuad(self)

    if self.currentAnim then
    
        local frameNumber = self.currentAnim[self.currentAnimIndex].frame
        local frameX = ((frameNumber - 1) % self.numCols) * self.quadW
        local frameY = math.floor((frameNumber - 1) / self.numCols) * self.quadH
        self.drawQuad = love.graphics.newQuad(frameX, frameY, self.quadW, self.quadH, self.drawImage:getWidth(), self.drawImage:getHeight())
        
    else
        self.drawQuad = love.graphics.newQuad(0, 0, self.quadW, self.quadH, self.drawImage:getWidth(), self.drawImage:getHeight())
    end
    
end

function SpriteMixin:SetAnimation(animName)

    assert(self.drawImage)
    assert(type(self.anims[animName]) == "table")
    
    -- Don't change anything if this is the same animation.
    if self.currentAnim ~= self.anims[animName] then
    
        self.currentAnimName = animName
        self.currentAnim = self.anims[animName]
        self.currentAnimTime = 0
        self.currentAnimIndex = 1
        UpdateDrawQuad(self)
        
    end
    
end

function SpriteMixin:GetAnimation()
    return self.currentAnimName
end

function SpriteMixin:ClearAnimation()

    assert(self.drawImage)
    
    self.currentAnimName = nil
    self.currentAnim = nil
    UpdateDrawQuad(self)
    
end

function SpriteMixin:GetWidth()

    assert(self.drawImage)
    return self.quadW * self:GetScale().x
    
end

function SpriteMixin:GetHeight()

    assert(self.drawImage)
    return self.quadH * self:GetScale().y
    
end

function SpriteMixin:GetSize()
    return vec2(self:GetWidth(), self:GetHeight())
end

function SpriteMixin:GetBoundingBox()
    return rect(self:GetPosition(), self:GetSize())
end

function SpriteMixin:Update(dt)

    if self.currentAnim then
    
        self.currentAnimTime = self.currentAnimTime + dt
        if self.currentAnimTime >= self.currentAnim[self.currentAnimIndex].time then
        
            local callback = self.currentAnim[self.currentAnimIndex].callback
            if callback then
                callback()
            end
            
            -- Progress the animation.
            if self.currentAnim[self.currentAnimIndex + 1] then
                self.currentAnimIndex = self.currentAnimIndex + 1
            else
                self.currentAnimIndex = 1
            end
            
            self.currentAnimTime = 0
            
            UpdateDrawQuad(self)
            
        end
        
    end
    
end

local function CalcAnchor(size, anchor)

    local point = size / 2
    
    if anchor == "min" then
        point = 0
    elseif anchor == "max" then
        point = size
    end
    
    return point
    
end

function SpriteMixin:Draw()

    assert(self.drawImage)
    
    love.graphics.setColorMode("modulate")
    love.graphics.setColor(self.color:unpack())
    
    local pos = self:GetPosition()
    local rot = self:GetRotation()
    local scale = self:GetScale()
    local anchorPointX = CalcAnchor(self.quadW, self.anchorX)
    local anchorPointY = CalcAnchor(self.quadH, self.anchorY)
    love.graphics.drawq(self.drawImage, self.drawQuad, pos.x, pos.y, rot, scale.x, scale.y, anchorPointX, anchorPointY)
    
    if self.OnDrawComplete then
        self:OnDrawComplete()
    end
    
end