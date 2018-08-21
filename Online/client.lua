love.window.setFullscreen(true)
love.mouse.setVisible(false)

lovernetlib = require('Online/lovernet')
client = lovernetlib.new()

client:addOp('p') --point (recieve keyPresses)
client:addOp('q') --query (send gameState to client)

client.pushTimer = 0

clientData={x=1,y=1}

function client.updateData(dt)

    client.pushTimer = client.pushTimer - dt

    client:pushData('q')

    client:update(dt)

end

function client.draw()
    
    if client:getCache('q') then

        local encoded = client:getCache('q')
        print(encoded)
        local decoded = love.image.newImageData(love.graphics.getWidth(),love.graphics.getHeight(),"rgba8",encoded)
        love.graphics.setColor(255,255,255)
        love.graphics.draw(love.graphics.newImage(decoded))

    end

end

function client.keyInput(key)
    client:sendData('p',{key=key})
end