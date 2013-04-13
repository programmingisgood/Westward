
local function AddFunctionToCallerList(classInstance, classFunction, addFunction, functionName)

    local functionsTable = classInstance[functionName .. "__functions"]
    if functionsTable == nil then
        
        local allFunctionsTable = { }
        -- Insert existing function.
        table.insert(allFunctionsTable, classFunction)
        -- Then insert the new Mixin function.
        table.insert(allFunctionsTable, addFunction)
        
        -- Return values are ignored.
        local function CallAllFunctions(ignoreSelf, ...)
        
            local returnValues = nil
            for i = 1, #allFunctionsTable do
            
                local callFunc = allFunctionsTable[i]
                if returnValues then
                    callFunc(classInstance, ...)
                else
                    returnValues = { callFunc(classInstance, ...) }
                end
                
            end
            
            if returnValues then
                return unpack(returnValues)
            else
                return nil
            end
            
        end
        
        classInstance[functionName .. "__functions"] = allFunctionsTable
        classInstance[functionName] = CallAllFunctions
        
    else
        table.insert(functionsTable, addFunction)
    end
    
end

function InitMixin(classInstance, theMixin, ...)

    assert(classInstance)
    assert(theMixin)
    assert(type(theMixin.type) == "string")
    
    -- Don't add the mixin to the class instance again.
    if not HasMixin(classInstance, theMixin) then
    
        for k, v in pairs(theMixin) do
        
            if type(v) == "function" and k ~= "__initmixin" then
            
                -- Directly set the function for this class instance.
                -- Only affects this instance.
                local classFunction = classInstance[k]
                if classFunction == nil then
                    classInstance[k] = v
                
                -- If the function already exists then it is added to a list of functions to call.
                -- The return values from the last called function in this list is returned.
                else
                    AddFunctionToCallerList(classInstance, classFunction, v, k)
                end
                
            end
            
        end
        
        -- Keep track that this mixin has been added to the class instance.
        if classInstance.__mixinlist == nil then
            classInstance.__mixinlist = { }
        end
        
        assert(classInstance.__mixinlist[theMixin.type] == nil or
               classInstance.__mixinlist[theMixin.type] == theMixin,
               "Different Mixin with the same type name already exists in table!")
        
        classInstance.__mixinlist[theMixin.type] = theMixin
        
    end
    
    -- Finally, initialize the mixin on this class instance.
    -- This can be done multiple times for a class instance.
    if theMixin.__initmixin then
        theMixin.__initmixin(classInstance, ...)
    end
    
end

function HasMixin(classInstance, mixinTypeName)

    if classInstance.__mixinlist then
    
        if classInstance.__mixinlist[mixinTypeName] ~= nil then
            return true
        end
        
    end
    return false
    
end