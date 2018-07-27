require "logic"
animate = {}

function animate.draw(sprite,x,y,percent,r,spriteLength,continuous,horisontal)
	if not continuous then
		spriteNum = math.floor((percent/100)*spriteLength,0)
		quad=love.graphics.newQuad(spriteNum*120,0,120,120,120*spriteLength,120)
	else
		if not horisontal then
			quad=love.graphics.newQuad((sprite:getWidth()-120)*percent/100,0,120,120,sprite:getWidth(),120)
		else
			quad=love.graphics.newQuad(0,(sprite:getHeight()-120)*percent/100,120,120,120,sprite:getHeight())
		end
	end
	love.graphics.draw(p.image,quad,x,y,r,1,1,60,60)
end

function animate.update(dt)
	animate.updateAnimations(dt)
end

function animate.updateAnimations(dt)
	for i=1,#projectiles do
		p=projectiles[i]
		if p.percent then 
			p.percent = p.percent + dt*100*p.aSpeed
			if p.percent > 100 then p.percent = p.percent-100 end
		end
	end
end