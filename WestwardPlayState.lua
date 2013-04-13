
local SimpleInput = require("SimpleInput")
local Sound = require("Sound")

require("DebugDrawer")

local kBuildPointDistance = 32
local kNumPrebuiltPoints = 7
local kScreenWidth = love.graphics.getWidth()
local kScreenHalfWidth = kScreenWidth / 2
local kScreenHeight = love.graphics.getHeight()
local kScreenHalfHeight = kScreenHeight / 2

local kWorldScrollSpeed = 32

local kGameProgressionTime = 100
local kGameProgressionMaxSpeed = 1.5

local kMaxTrainSpeed = 10
local kTrainAccelAmount = 0.75
local kTrainBrakeAmount = 2.5
local kTrainSpeedMod = 0.25
local kBuilderSpeed = 64

local kAddPassengerRate = 4
local kPassengerSpeed = 10
local kPassengerPickupDistance = 24
local kPassengerAttractDistance = 128
local kPassengerMaxPickupSpeed = 4
local kPassengerDropoffDistance = 64
local kPassengerMaxDropoffSpeed = 4
local kPassengerTypes = { }
table.insert(kPassengerTypes, { name = "red", color = color(150, 0, 0, 255) })
table.insert(kPassengerTypes, { name = "green", color = color(0, 150, 0, 255) })
table.insert(kPassengerTypes, { name = "blue", color = color(0, 0, 150, 255) })

local kAddDestinationRate = 5
local kDestinationTypes = { }
table.insert(kDestinationTypes, { name = "red", color = color(150, 0, 0, 255) })
table.insert(kDestinationTypes, { name = "green", color = color(0, 150, 0, 255) })
table.insert(kDestinationTypes, { name = "blue", color = color(0, 0, 150, 255) })

local kAddObstacleRate = 5
local kObstacleTypes = { }
table.insert(kObstacleTypes, { name = "cattle", image = "art/Cattle.png", direction = vec2(0, 1), speed = 25 })

local kHugeFont = love.graphics.newFont("art/press-start-2p/PressStart2P.ttf", 62)

local function CreateSprite(path, numRows, numCols)

    local newSprite = { }
    InitMixin(newSprite, MovableMixin)
    InitMixin(newSprite, SpriteMixin)

    newSprite:SetImage(path, numRows, numCols)

    return newSprite

end

local function AddTrainCar(train)

    local newCar = CreateSprite("art/TrainCar.png", 1, 1)
    
    newCar:SetScale(vec2(1.5, 1.5))

    table.insert(train.cars, newCar)

end

local function Init(self)

    math.randomseed(os.time())
    
    self.builder = CreateSprite("art/Builder.png", 1, 1)

    self.builtPoints = { }
    for p = 0, kNumPrebuiltPoints - 1 do
        table.insert(self.builtPoints, vec2(kScreenHalfWidth - kBuildPointDistance * p, kScreenHalfHeight))
    end

    self.builder:SetScale(vec2(3, 3))
    self.builder.lastBuiltPoint = self.builtPoints[#self.builtPoints]
    self.builder:SetPosition(self.builder.lastBuiltPoint)

    self.builder.input = SimpleInput.Create(1)

    self.train = CreateSprite("art/Train.png", 1, 1)
    
    self.train:SetScale(vec2(3, 3))
    self.train:SetPosition(vec2(kScreenHalfWidth, kScreenHalfHeight))

    self.train.input = SimpleInput.Create(2)

    self.train.speed = 0
    self.train.prevPoint = 3
    self.train.percentToNextPoint = 0
    self.train.cars = { }

    AddTrainCar(self.train)
    AddTrainCar(self.train)
    AddTrainCar(self.train)

    self.worldScroll = vec2(0, 0)

    self.startAnim = Animation(kScreenWidth - 100, -kScreenWidth, 2.4)

    self.passengers = { }
    self.destinations = { }
    self.obstacles = { }

    self.numPassengersDelivered = 0
    self.gameTime = 0
    self.gameOver = false
    
end

local function OnKeyPressed(self, keyPressed)

    if keyPressed == "escape" then
    
    elseif keyPressed == "o" then
        self.fastMode = true
    end
    
end

local function OnKeyReleased(self, keyReleased)

    if keyReleased == "f" then
        self.fastMode = false
    end

end

local function GetClampedInput(input)

    local controls = vec2(0, 0)
    controls.x = input:GetInputState("X")
    controls.y = input:GetInputState("Y")
    controls.x = math.abs(controls.x) < 0.2 and 0 or controls.x
    controls.y = math.abs(controls.y) < 0.2 and 0 or controls.y
    return controls

end

local function UpdateBuilderMovement(self, builder, dt)

    local controls = GetClampedInput(builder.input)

    local moving = math.abs(controls.x) > 0 or math.abs(controls.y) > 0

    if moving then
    
        local pos = builder:GetPosition()
        pos = pos:Add(controls:Mul(dt * kBuilderSpeed))
        pos.x = math.max(pos.x, -self.worldScroll.x)
        pos.y = math.max(math.min(pos.y, kScreenHeight), 0)
        builder:SetPosition(pos)
        
    else
        
    end
    
end

local function UpdateTrainSpeed(train, dt)
    
    local accel = train.input:GetInputState("A")
    if accel > 0 then
        train.speed = train.speed + accel * dt * kTrainAccelAmount
    else
        train.speed = train.speed - dt * kTrainAccelAmount
    end

    local brake = train.input:GetInputState("B")
    if brake > 0 then
        train.speed = train.speed - dt * kTrainBrakeAmount
    end

    train.speed = math.min(math.max(train.speed, 0), kMaxTrainSpeed)
    DebugDrawer.DrawText("speed: " .. train.speed, vec2(5, 5), 0, color(0, 0, 0, 0))

end

local function UpdateBuildTrack(self)

    local builder = self.builder
    local builderPos = builder:GetPosition()

    if builderPos:Distance(builder.lastBuiltPoint) >= kBuildPointDistance then

        table.insert(self.builtPoints, builderPos)
        builder.lastBuiltPoint = builderPos

    end

end

local function GetPointOnTracks(self, builtPointIndex, percentToNextPoint)

    if builtPointIndex < #self.builtPoints then

        local prevPoint = self.builtPoints[builtPointIndex]
        local nextPoint = self.builtPoints[builtPointIndex + 1]
        local travelLine = nextPoint:Sub(prevPoint)
        return prevPoint:Add(travelLine:Mul(percentToNextPoint))

    end

    return nil

end

local function UpdateTrainPosition(self, dt)

    self.train.percentToNextPoint = self.train.percentToNextPoint + self.train.speed * dt * kTrainSpeedMod
    if self.train.percentToNextPoint >= 1 then

        self.train.prevPoint = self.train.prevPoint + 1
        self.train.percentToNextPoint = self.train.percentToNextPoint - 1

    end

    local trainPos = GetPointOnTracks(self, self.train.prevPoint, self.train.percentToNextPoint)
    if trainPos then
        self.train:SetPosition(trainPos)
    end

end

local function GetRandomPointInWorld(self)

    local minX = -kScreenWidth - self.worldScroll.x
    local maxX = -self.worldScroll.x
    return RandomPoint(minX, maxX, 64, kScreenHeight - 64)

end

local function SameTypeName(pointType)
    return function(point, obj) return pointType.name ~= obj.type.name end
end


local function CheckPointAwayFrom(point, array, minDistance, condition)

    for a = 1, #array do

        if point:Distance(array[a]:GetPosition()) <= minDistance then

            if not condition or not condition(point, array[a]) then
                return false
            end

        end

    end

    return true

end


local function UpdateAddPassengers(self, dt)

    self.lastTimeAddedPassenger = self.lastTimeAddedPassenger or 0
    local now = Now()
    if now - self.lastTimeAddedPassenger >= kAddPassengerRate then

        local randomType = RandomInArray(kPassengerTypes)
        local randomPoint = GetRandomPointInWorld(self)
        if CheckPointAwayFrom(randomPoint, self.destinations, 128, SameTypeName(randomType)) then

            local newPassenger = CreateSprite("art/Passenger.png", 1, 1)

            newPassenger.type = randomType

            newPassenger:SetScale(vec2(2, 2))
            newPassenger:SetColor(newPassenger.type.color)
            
            newPassenger:SetPosition(randomPoint)

            table.insert(self.passengers, newPassenger)

            self.lastTimeAddedPassenger = now

        end

    end

end

local function UpdateAddDestinations(self, dt)

    self.lastTimeAddedDestination = self.lastTimeAddedDestination or 0
    local now = Now()
    if now - self.lastTimeAddedDestination >= kAddDestinationRate then

        local randomType = RandomInArray(kDestinationTypes)
        local randomPoint = GetRandomPointInWorld(self)
        if CheckPointAwayFrom(randomPoint, self.destinations, 128) and
           CheckPointAwayFrom(randomPoint, self.passengers, 128, SameTypeName(randomType)) then

            local newDestination = CreateSprite("art/Destination.png", 1, 1)

            newDestination.type = randomType

            newDestination:SetScale(vec2(1, 1))
            newDestination:SetColor(newDestination.type.color)
            newDestination:SetPosition(randomPoint)

            table.insert(self.destinations, newDestination)

            self.lastTimeAddedDestination = now

        end

    end

end

local function UpdateAddObstacles(self, dt)

    self.lastTimeAddedObstacle = self.lastTimeAddedObstacle or 0
    local now = Now()
    if now - self.lastTimeAddedObstacle >= kAddObstacleRate then

        local obstacleType = RandomInArray(kObstacleTypes)
        local newObstacle = CreateSprite(obstacleType.image, 1, 1)

        newObstacle.type = obstacleType

        newObstacle:SetScale(vec2(2, 2))
        local minX = -kScreenWidth - self.worldScroll.x
        local maxX = -self.worldScroll.x
        newObstacle:SetPosition(RandomPoint(minX, maxX, -264, -64))

        table.insert(self.obstacles, newObstacle)

        self.lastTimeAddedObstacle = now

    end

end

local function CheckCollision(obj1, obj2)
    return obj1:GetBoundingBox():Overlaps(obj2:GetBoundingBox())
end

local function UpdateObstacles(self, dt)

    for o = 1, #self.obstacles do

        local obstacle = self.obstacles[o]
        local pos = obstacle:GetPosition()

        if CheckCollision(obstacle, self.builder) or CheckCollision(obstacle, self.train) then
            self.gameOver = true
        end

        obstacle:SetPosition(pos:Add(obstacle.type.direction:Mul(obstacle.type.speed * dt)))

    end

end

local function AddPassengerToTrain(passenger, train)

    for c = 1, #train.cars do

        local car = train.cars[c]
        if car.passenger == nil then

            car.passenger = passenger
            return true

        end

    end

    return false

end

local function GetTrainIsFull(train)

    for c = 1, #train.cars do
    
        if not train.cars[c].passenger then
            return false
        end

    end

    return true

end

local function UpdatePassengers(self, train, dt)

    local trainPos = train:GetPosition()
    for p = #self.passengers, 1, -1 do

        local passenger = self.passengers[p]

        local passengerColor = passenger:GetColor()
        if passenger.attracted then
            passengerColor.a = 255--(math.floor(self.gameTime) % 0.25 == 1) and 255 or 0
        else
            passengerColor.a = 255
        end
        passenger:SetColor(passengerColor)

        local passengerPos = passenger:GetPosition()
        if passenger.destination then

            local destPos = passenger.destination:GetPosition()
            local newPos = passengerPos:Add(destPos:SubNorm(passengerPos):Mul(dt * kPassengerSpeed))
            passenger:SetPosition(newPos)

            if passenger.destination:GetPosition():Distance(passengerPos) <= 16 then

                self.numPassengersDelivered = self.numPassengersDelivered + 1
                table.remove(self.passengers, p)

            end

        else

            local trainFull = GetTrainIsFull(train)
            local distToPassenger = trainPos:Distance(passengerPos)
            if not trainFull and train.speed <= kPassengerMaxPickupSpeed and
               distToPassenger <= kPassengerAttractDistance then

                passenger.attracted = true
                local newPos = passengerPos:Add(trainPos:SubNorm(passengerPos):Mul(dt * kPassengerSpeed))
                passenger:SetPosition(newPos)

                if distToPassenger <= kPassengerPickupDistance then

                    if AddPassengerToTrain(passenger, train) then

                        passenger.attracted = false
                        table.remove(self.passengers, p)

                    end

                end

            else
                passenger.attracted = false
            end

        end

    end

end

local function UpdateDropoffPassengers(self, train, dt)

    if train.speed > kPassengerMaxDropoffSpeed then
        return
    end

    for c = 1, #train.cars do

        local car = train.cars[c]
        if car.passenger then

            for d = 1, #self.destinations do

                local destination = self.destinations[d]
                if destination.type.name == car.passenger.type.name then

                    local destDist = car.passenger:GetPosition():Distance(destination:GetPosition())
                    if destDist <= kPassengerDropoffDistance then

                        table.insert(self.passengers, car.passenger)
                        car.passenger.destination = destination
                        car.passenger = nil
                        break

                    end

                end

            end

        end

    end

end

local function CheckOffScreen(self, point)

    local diff = self.worldScroll.x - -point.x
    return diff > kScreenWidth

end

local function CheckGameOver(self)

    if CheckOffScreen(self, self.train:GetPosition()) or
       CheckOffScreen(self, self.builder:GetPosition()) then
        self.gameOver = true
    end

end

local function Update(self, dt)

    if self.fastMode then
        dt = dt * 5
    end

    if self.gameOver then

    else

        self.gameTime = self.gameTime + dt

        -- Update based on controls.
        UpdateBuilderMovement(self, self.builder, dt)
        UpdateTrainSpeed(self.train, dt)

        UpdateBuildTrack(self)
        UpdateTrainPosition(self, dt)
        
        self.builder:Update(dt)

        if self.startAnim:GetIsComplete() then

            DebugDrawer.DrawText(tostring((math.min(1, self.gameTime / kGameProgressionTime) * kGameProgressionMaxSpeed)), vec2(5, 65), 0, color(0, 0, 0, 0))
            local moddedDt = math.max(dt, dt * (math.min(1, self.gameTime / kGameProgressionTime) * kGameProgressionMaxSpeed))
            self.worldScroll = self.worldScroll:Add(vec2(kWorldScrollSpeed * moddedDt, 0))
            UpdateAddPassengers(self, moddedDt)
            UpdateAddDestinations(self, moddedDt)
            UpdateAddObstacles(self, moddedDt)

            UpdateObstacles(self, dt)
            UpdatePassengers(self, self.train, dt)
            UpdateDropoffPassengers(self, self.train, dt)

            CheckGameOver(self)

        end

    end
    
end

local function DrawUI(self)

    love.graphics.setFont(kHugeFont)
    local startAnimVal = self.startAnim:GetValue()
    if not self.startAnim:GetIsComplete() then

        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.print("Westward HO!!!", self.startAnim:GetValue(), kScreenHalfHeight)

    end

    if self.gameOver then

        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.printf("GAME OVER", kScreenHalfWidth, kScreenHalfHeight, 0, "center")

    end

    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.printf(tostring(self.numPassengersDelivered), kScreenHalfWidth, 10, 0, "center")

end

local function DrawWorld(self)

    love.graphics.setLine(4, "smooth")
    love.graphics.setColor(40, 40, 0, 255)
    for b = 1, #self.builtPoints - 1 do

        local b1 = self.builtPoints[b]
        local b2 = self.builtPoints[b + 1]
        love.graphics.line(b1.x, b1.y, b2.x, b2.y)

    end

    local lastBuilt = self.builtPoints[#self.builtPoints]
    local builderPos = self.builder:GetPosition()
    local redAmount = builderPos:Distance(self.builder.lastBuiltPoint) / kBuildPointDistance
    love.graphics.setColor(80 + (170 * redAmount), 80, 0, 255)
    love.graphics.line(lastBuilt.x, lastBuilt.y, builderPos.x, builderPos.y)

end

local function DrawTrainCars(self, train)

    for c = 1, #train.cars do

        local car = train.cars[c]
        local prevPoint = train.prevPoint
        local percentToNextPoint = train.percentToNextPoint

        local carPrevPoint = prevPoint
        local carPercentToNextPoint = percentToNextPoint - (0.35 * c)
        while carPercentToNextPoint < 0 do

            carPrevPoint = carPrevPoint - 1
            carPercentToNextPoint = carPercentToNextPoint + 1

        end
        local carPos = GetPointOnTracks(self, carPrevPoint, carPercentToNextPoint)
        if carPos then
            car:SetPosition(carPos)
        end
        car:Draw()

    end

end

local function DrawTrainPassengers(train)

    for c = 1, #train.cars do

        local car = train.cars[c]
        if car.passenger then

            car.passenger:SetPosition(car:GetPosition())
            car.passenger:Draw()

        end

    end

end

local function DrawArray(array)

    for p = 1, #array do
        array[p]:Draw()
    end

end

local function DrawEntities(self)

    DrawTrainCars(self, self.train)
    DrawTrainPassengers(self.train)
    self.train:Draw()
    DrawArray(self.obstacles)
    DrawArray(self.passengers)
    DrawArray(self.destinations)
    self.builder:Draw()

end

local function Draw(self)

    love.graphics.setBackgroundColor(190, 170, 0, 255)
    love.graphics.clear()

    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.push()
    
    love.graphics.translate(self.worldScroll.x, self.worldScroll.y)

    DrawWorld(self)
    DrawEntities(self)
    
    DebugDrawer.Draw("world")

    love.graphics.pop()

    love.graphics.push()

    DrawUI(self)

    love.graphics.pop()

    DebugDrawer.Draw("screen")

end

local function Create(useFont, client, server)

    local state = { }
    
    state.font = useFont
    state.OnKeyPressed = OnKeyPressed
    state.OnKeyReleased = OnKeyReleased
    state.Update = Update
    state.Draw = Draw
    state.GetBlocksEscape = function() return false end
    Init(state)
    
    return state
    
end

return { Create = Create }