
DebugDrawer = { drawTypes = { rects = { }, texts = { }, lines = { } } }

function DebugDrawer.DrawRect(center, size, duration, useColor, space)

    table.insert(DebugDrawer.drawTypes.rects, { center = center, size = size, now = Now(),
                                                duration = duration, color = useColor, space = space or "world" })

end

function DebugDrawer.DrawText(text, pos, duration, useColor, space)

    table.insert(DebugDrawer.drawTypes.texts, { text = text, pos = pos, now = Now(),
                                                duration = duration, color = useColor, space = space or "screen" })

end

function DebugDrawer.DrawLine(startPos, endPos, duration, useColor, space)

    table.insert(DebugDrawer.drawTypes.lines, { startPos = startPos, endPos = endPos, now = Now(),
                                                duration = duration, color = useColor, space = space or "world" })

end

local kFont = love.graphics.newFont(12)
function DebugDrawer.Draw(drawSpace)

    assert(type(drawSpace) == "string")

    love.graphics.setFont(kFont)

    for r = 1, #DebugDrawer.drawTypes.rects do
    
        local drawRect = DebugDrawer.drawTypes.rects[r]
        if drawRect.space == drawSpace then

            love.graphics.setColor(drawRect.color and drawRect.color:unpack() or 128, 128, 128, 128)
            love.graphics.rectangle("line", drawRect.center.x - drawRect.size.x / 2,
                                    drawRect.center.y - drawRect.size.y / 2,
                                    drawRect.size.x, drawRect.size.y)
            love.graphics.reset()

        end
        
    end
    
    for t = 1, #DebugDrawer.drawTypes.texts do
    
        local drawText = DebugDrawer.drawTypes.texts[t]
        if drawText.space == drawSpace then

            love.graphics.setColor(drawText.color and drawText.color:unpack() or 128, 128, 128, 128)
            love.graphics.print(drawText.text, drawText.pos.x, drawText.pos.y)
            love.graphics.reset()

        end
        
    end

    for l = 1, #DebugDrawer.drawTypes.lines do

        local drawLine = DebugDrawer.drawTypes.lines[l]
        if drawLine.space == drawSpace then

            love.graphics.setColor(drawLine.color and drawLine.color:unpack() or 128, 128, 128, 128)
            love.graphics.setLineWidth(2)
            love.graphics.setLineStyle("rough")
            love.graphics.line(drawLine.startPos.x, drawLine.startPos.y, drawLine.endPos.x, drawLine.endPos.y)
            love.graphics.reset()

        end

    end
    
    -- Clear out old debug drawing.
    for _, drawType in pairs(DebugDrawer.drawTypes) do
    
        for t = #drawType, 1, -1 do
        
            local drawItem = drawType[t]
            if drawItem.space == drawSpace and (drawItem.duration == nil or (Now() - drawItem.now) > drawItem.duration) then
                table.remove(drawType, t)
            end
            
        end
        
    end
    
end