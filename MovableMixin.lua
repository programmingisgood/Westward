
MovableMixin = { type = "Movable" }

function MovableMixin:__initmixin()

    self.pos = vec2(0, 0)
    self.rot = 0
    self.scale = vec2(1, 1)
    
end

function MovableMixin:SetPosition(setPos)

    self.pos.x = setPos.x
    self.pos.y = setPos.y
    
end

function MovableMixin:GetPosition()
    return vec2(self.pos.x, self.pos.y)
end

function MovableMixin:SetRotation(setRot)
    self.rot = setRot
end

function MovableMixin:GetRotation()
    return self.rot
end

function MovableMixin:SetScale(setScale)

    self.scale.x = setScale.x
    self.scale.y = setScale.y
    
end

function MovableMixin:GetScale()
    return vec2(self.scale.x, self.scale.y)
end