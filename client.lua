lovernetlib = require('lovernet')
client = lovernetlib.new()

client:addOp('p')
client:addOp('q')

pressed=false

function client.updateData(dt)
  client:pushData('q')

  client:update(dt)

end

function client.draw()
  if client:getCache('q') then
    circle = lovernet:getCache('q')
    love.graphics.setColor(circle.c.r,circle.c.b,circle.c.g)
    love.graphics.circle("fill",circle.x,circle.y,20)
  end
end

function love.keypressed(key)
   client:sendData('p',{
    key=key
  })
end