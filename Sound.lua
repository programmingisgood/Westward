
local cachedSoundDatas = { }
local function GetCachedSoundData(path)

    local cachedSoundData = cachedSoundDatas[path]
    if not cachedSoundData then
    
        cachedSoundData = love.sound.newSoundData(path)
        cachedSoundDatas[path] = cachedSoundData
        
    end
    
    return cachedSoundData
    
end

local function Preload(path)
    GetCachedSoundData(path)
end

local function Play(path, volume)

    local source = love.audio.newSource(GetCachedSoundData(path))
    source:setVolume(volume or 1)
    love.audio.play(source)
    
end

local function Create(path, streaming)

    local newSound = { }
    if streaming then
        newSound.source = love.audio.newSource(path, "stream")
    else
        newSound.source = love.audio.newSource(GetCachedSoundData(path))
    end
    
    function newSound:Play()
        self.source:play()
    end
    
    function newSound:Pause()
        self.source:pause()
    end
    
    function newSound:Stop()
        self.source:stop()
    end
    
    function newSound:SetVolume(volume)
        self.source:setVolume(volume)
    end
    
    function newSound:SetLooping(looping)
        self.source:setLooping(looping)
    end
    
    function newSound:SetPitch(pitch)
        self.source:setPitch(pitch)
    end
    
    return newSound
    
end

return { Preload = Preload, Play = Play, Create = Create }