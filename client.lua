lovernetlib = require('lovernet')
client = lovernetlib.new()

client:addOp('p')
client:addOp('q')

client.pushTimer = 0

function client.updateData(dt)

  client.pushTimer = client.pushTimer - dt

  if client.pushTimer < 0 and onlineGame then 
    client:pushData('q')
    client.pushTimer=20 --reduces frames/second but REDUCES INTERNET TRAFFIC
  end

  client:update(dt)

end

function client.draw()
  if client:getCache('q') then
    local encoded = client:getCache('q')
    local decoded = love.image.newImageData(love.graphics.getWidth(),love.graphics.getHeight(),encoded)
    love.graphics.setColor(255,255,255)
    love.graphics.draw(love.graphics.newImage(decoded))
  end
end

function love.keypressed(key)
   client:sendData('p',{
    key=key
  })
end