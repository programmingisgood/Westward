
local function Add(self, object, tags)

    assert(object ~= nil)
    
    self.objects[object] = tags or { }
    
end

local function Remove(self, object)
    self.objects[object] = nil
end

local function Query(self, mixinType, position, range)

    local nearbyObjects = { }
    for object, _ in pairs(self.objects) do
    
        if HasMixin(object, mixinType) then
        
            if not position then
                table.insert(nearbyObjects, object)
            else
            
                assert(HasMixin(object, "Movable"))
                local lengthSq = position:Sub(object:GetPosition()):LengthSquared()
                if lengthSq <= range * range then
                    table.insert(nearbyObjects, object)
                end
                
            end
            
        end
        
    end
    
    if position then
    
        local function DistSorter(a, b)
        
            local lengthSq1 = position:Sub(a:GetPosition()):LengthSquared()
            local lengthSq2 = position:Sub(b:GetPosition()):LengthSquared()
            return lengthSq1 < lengthSq2
            
        end
        table.sort(nearbyObjects, DistSorter)
        
    end
    
    return nearbyObjects
    
end

local function QueryNumberWithTag(self, tag)

    local num = 0
    
    for _, tags in pairs(self.objects) do
    
        for t = 1, #tags do
        
            if tags[t] == tag then
                num = num + 1
            end
            
        end
        
    end
    
    return num
    
end

local function IterateTag(self, iterateTagName, func)

    for object, tags in pairs(self.objects) do
    
        local tagFound = false
        for t = 1, #tags do
        
            if tags[t] == iterateTagName then
            
                func(object)
                break
                
            end
            
        end
        
    end
    
end

local function CollectAllWithTag(self, tagName)

    local collection = { }
    IterateTag(self, tagName, function(object) table.insert(collection, object) end)
    return collection
    
end

local function Create()

    local world = { }
    
    world.Add = Add
    world.Remove = Remove
    world.Query = Query
    world.QueryNumberWithTag = QueryNumberWithTag
    world.IterateTag = IterateTag
    world.CollectAllWithTag = CollectAllWithTag
    
    world.objects = { }
    
    return world
    
end

return { Create = Create }