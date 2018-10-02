function love.load()
  local img = love.graphics.newImage('img.png')
  psystem = love.graphics.newParticleSystem(img, 500)--10k is about the limit
  psystem:setParticleLifetime(0.5,1)
  psystem:setEmissionRate(1000)
  psystem:setSizeVariation(1)
  psystem:setPosition(100,100)
  psystem:setColors(0.3,0.3,1,1,0.1,0.1,1,0.5,0,0,1,0)
  psystem:setSizes(0.2,0.1,0.05)
  psystem:setSpeed(2,2)
  psystem:setEmissionArea("normal",5,5,math.pi,true)

  psystem:setRadialAcceleration( 5, 5 )
  psystem:setTangentialAcceleration( 10, 20 )

  love.graphics.setBackgroundColor(0,0,0)
end
 
function love.draw()
  love.graphics.setBlendMode("add")
  love.graphics.draw(psystem, 0, 0)
end
 
function love.update(dt)
  psystem:setPosition(love.mouse.getX(),love.mouse.getY())
  psystem:update(dt)
end