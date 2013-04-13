
require("Utils")

local gameData = { file = "WestwardGame", caption = "Westward" }

function love.load()
    
    game = require(gameData.file)
    love.graphics.setCaption(gameData.caption)
    
    love.graphics.setBackgroundColor(0, 0, 0)
    
end

function love.keypressed(keyPressed)

    if keyPressed == "escape" then
    
        if not game.GetBlocksEscape or not game:GetBlocksEscape() then
            love.event.push("quit")
        end
        
    end
    
    if game.OnKeyPressed then
        game:OnKeyPressed(keyPressed)
    end
    
end

function love.keyreleased(keyReleased)

    if game.OnKeyReleased then
        game:OnKeyReleased(keyPressed)
    end
    
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end

function love.update(dt)
    game:Update(dt)
end

function love.draw()
    game:Draw()
end